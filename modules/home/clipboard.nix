{ lib, pkgs, ... }:

let
  copy = pkgs.writeShellApplication {
    name = "copy";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      if (( $# != 0 )); then
        echo "usage: command | copy" >&2
        exit 1
      fi

      # Clipboard contents are private, but stored unencrypted on disk.
      umask 077
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
      mkdir -p -- "$state_dir"
      tmp=$(mktemp "$state_dir/.clipboard.XXXXXX")
      trap 'rm -f -- "$tmp"' EXIT

      # Like the dotfiles command, strip trailing newlines. Text only, not binary.
      contents=$(cat)
      printf '%s' "$contents" > "$tmp"
      mv -f -- "$tmp" "$state_dir/clipboard"

      # No clipboard on the Linux console, dumb terminals, or without a terminal.
      case "''${TERM:-}" in
        linux|dumb|"") exit 0 ;;
      esac
      if { exec 3>/dev/tty; } 2>/dev/null; then
        # Write to the controlling terminal without polluting stdout/pipelines.
        # tmux consumes OSC 52 and forwards it with set-clipboard on.
        printf '\033]52;c;%s\a' "$(printf '%s' "$contents" | base64 --wrap=0)" >&3
      fi
    '';
  };

  pasta = pkgs.writeShellApplication {
    name = "pasta";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      if (( $# != 0 )); then
        echo "usage: pasta" >&2
        exit 1
      fi

      clipboard="''${XDG_STATE_HOME:-$HOME/.local/state}/clipboard"
      if [[ ! -f "$clipboard" ]]; then
        echo "pasta: no saved clipboard; send some text to copy first" >&2
        exit 1
      fi
      cat -- "$clipboard"
    '';
  };
in
{
  home.packages = [
    copy
    pasta
  ];

  programs.neovim.initLua = ''
    -- Explicit "+ / "* registers only: ordinary yanks/deletes stay local to Neovim.
    -- Paste reads our saved file, never an OSC 52 clipboard query to the client.
    local function copy_clipboard(lines)
      local text = table.concat(lines, "\n"):gsub("\n+$", "")
      local output = vim.fn.system({ "${lib.getExe copy}" }, text)
      if vim.v.shell_error ~= 0 then
        error("copy failed: " .. output)
      end
      -- Neovim jobs have no controlling terminal. Send OSC 52 through its UI,
      -- while the command above handles the shared local save.
      local term = vim.env.TERM or ""
      if term ~= "linux" and term ~= "dumb" and term ~= "" then
        require("vim.ui.clipboard.osc52").copy("+")(vim.split(text, "\n", { plain = true }))
      end
    end

    vim.g.clipboard = {
      name = "OSC 52 with local fallback",
      copy = {
        ["+"] = copy_clipboard,
        ["*"] = copy_clipboard,
      },
      paste = {
        ["+"] = { "${lib.getExe pasta}" },
        ["*"] = { "${lib.getExe pasta}" },
      },
      cache_enabled = 0,
    }
  '';
}
