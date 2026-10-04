# Bootstrap

_Manual steps on a fresh install, for tools that install themselves outside
Nix. Everything else comes from `make switch`._

## Before you start

Run `make switch` once; it applies NixOS and Home Manager together. Then log
out and back in: Home Manager adds `~/.local/bin` to your login PATH, while
NixOS provides `nix-ld` for prebuilt Linux binaries. Existing tmux servers keep
the old environment; save your work before restarting them with `tmux kill-server`.

See [users.md](users.md) for user configuration and dotfile conflict handling.

## Claude Code

- **Path:** `~/.local/bin/claude`
- **Updates:** itself, in the background

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude   # sign in on first run
```

## Verify

```bash
which claude   # in ~/.local/bin
claude --version
```
