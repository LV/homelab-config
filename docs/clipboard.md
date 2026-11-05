# Clipboard

`modules/home/clipboard.nix` provides `copy`, `pasta`, and Neovim clipboard
registers. Activate configuration changes with `make switch`; restart Neovim to
load its new provider.

## Shell

```bash
printf 'hello from the homelab\n' | copy
copy < some-file.txt
pasta
```

- `copy` reads text from stdin and strips all trailing newline characters.
- It always saves the text to `${XDG_STATE_HOME:-$HOME/.local/state}/clipboard`.
  The file is written atomically with mode `0600`. **It is unencrypted and remains
  on disk**, so avoid treating it as a secret store.
- In a capable terminal, `copy` also sends OSC 52 to the controlling terminal.
  This does not require a local graphical session or an extra SSH connection.
  It writes no text or escape sequences to stdout.
- With `TERM=linux`, `TERM=dumb`, an unset/empty `TERM`, or no controlling terminal,
  only the local file is updated. No terminal clipboard is required.
- `pasta` prints the saved file without adding a newline. Before the first copy,
  it reports an error. It **does not read the client's current clipboard**.
- These are text tools, not binary-file transfer tools.

The client terminal must support and permit OSC 52 clipboard writes. Sending the
sequence cannot confirm whether the client accepted it. Payload limits vary
between terminals and tmux versions; the saved file is still available if the
terminal rejects a large copy.

## Neovim

The same commands back the explicit `+` and `*` registers:

- `"+yy`: copy the current line.
- `"+y` with a visual selection: copy the selection.
- `"+p`: paste the server's saved clipboard text.

Normal `y`, `p`, and deletes remain unchanged. The provider never queries the
client clipboard, avoiding terminal permission prompts and OSC 52 read timeouts.
To paste something copied on your laptop or phone into Neovim, use that client's
normal terminal paste action instead. The saved clipboard contains text only,
not Neovim's blockwise/linewise register metadata.

## tmux

The existing `set -g set-clipboard on` accepts OSC 52 from pane applications and
forwards clipboard updates to capable attached clients. No DCS passthrough or
client-specific bindings are needed.

With multiple attached clients, tmux can send a clipboard update to more than one
client. Do not assume a copy is private to the terminal where you typed it.
Neovim and shell commands share a single per-user saved clipboard across sessions.

## Manual verification

After `make switch`, check the following on the actual clients:

1. **Plain SSH:** in Ghostty and Termius, run
   `printf 'clipboard check\n' | copy`, then paste into a local app. Expect
   `clipboard check`. Check `pasta` on the server too.
2. **tmux:** repeat inside tmux. Check `tmux show-options -gv set-clipboard`
   returns `on` if forwarding fails. The terminal must advertise clipboard
   support to tmux and allow clipboard writes.
3. **Two clients:** attach Ghostty and Termius to the same session, copy from each
   in turn, and check both client clipboards. Record any prompts or differences.
4. **Neovim:** try `"+yy`, paste into a local app, then use `"+p` in Neovim. Run a
   separate shell copy and confirm `"+p` reads the updated saved text.
5. **Large payload:** try an expendable text file of roughly 100–250 KiB through
   `copy`, then verify the pasted content. Test clients separately and together;
   a successful local save does not prove terminal delivery.
6. **Physical console:** outside tmux with `TERM=linux`, copy text, then run
   `pasta; printf '\n'`. There should be no visible escape sequences. Verify
   Neovim's explicit clipboard registers also work via the saved file.

## Automated smoke tests

New files must be tracked by Git before ordinary `.#…` flake commands can see
this module. Alternatively use the explicit `path:.` flake reference while
working on untracked files.

```bash
copy_pkg=$(nix build --no-link --print-out-paths --impure --expr '
  let flake = builtins.getFlake ("path:" + toString ./.);
  in builtins.head (builtins.filter (p: p.name == "copy")
    flake.nixosConfigurations.homelab.config.home-manager.users.v.home.packages)')
pasta_pkg=$(nix build --no-link --print-out-paths --impure --expr '
  let flake = builtins.getFlake ("path:" + toString ./.);
  in builtins.head (builtins.filter (p: p.name == "pasta")
    flake.nixosConfigurations.homelab.config.home-manager.users.v.home.packages)')
init=$(mktemp --suffix=.lua)
nix eval --raw \
  'path:.#nixosConfigurations.homelab.config.home-manager.users.v.programs.neovim.initLua' \
  > "$init"
python3 tests/clipboard.py "$copy_pkg/bin/copy" "$pasta_pkg/bin/pasta" "$init"
rm -f "$init"
```

Tests use temporary state directories and isolated pseudo-terminals, not your
real clipboard. They cover local save/read, permissions, newline stripping,
Unicode, empty input, missing state, console/no-terminal fallback, OSC 52 output
including a 256 KiB payload, and Neovim register integration with captured UI
clipboard messages. Actual terminal acceptance and multi-client forwarding still require the manual checks above.
