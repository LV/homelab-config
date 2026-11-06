{ pkgs, ... }:

{
  imports = [
    ../../modules/home/notify.nix
    ../../modules/home/clipboard.nix
    ../../modules/home/claude-code.nix
    ../../modules/home/codex.nix
    ../../modules/home/pi.nix
    ../../modules/home/tmux.nix
    ../../modules/home/neovim.nix
  ];

  home = {
    # First Home Manager release used for this home. Do not bump on updates.
    stateVersion = "26.05";

    packages = with pkgs; [
      delta
      gnumake
      glow
      go
      lazygit
      nodejs
      python3
      ripgrep
      tree
      uv
    ];

    shellAliases = {
      cat = "bat";
      gg = "lazygit";
      t = "tmux";
      v = "nvim";
    };
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs = {
    bash = {
      enable = true;
      # Keep NixOS's existing Bash package, completion, and history/shopt defaults.
      package = null;
      enableCompletion = false;
      historySize = null;
      historyFileSize = null;
      shellOptions = [ ];
      initExtra = ''
        # Keep bat within the Linux console's 16-color palette.
        if [[ "$TERM" == linux ]]; then
          export BAT_THEME=ansi
        fi

        mkcdir () {
            mkdir -p -- "$1" &&
               cd -P -- "$1"
        }
      '';
    };

    bat = {
      enable = true;
      config = {
        theme = "Monokai Extended";
        paging = "never";
        style = "default";
      };
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    gh.enable = true;

    git = {
      enable = true;
      settings.init.defaultBranch = "main";
    };
  };
}
