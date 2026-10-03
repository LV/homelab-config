# Bootstrap

_Manual steps on a fresh install, for tools that install themselves outside
Nix. Everything else comes from `make switch`._

## Before you start

Run `make switch` once, then log out and back in. The `nix-ld` module puts
`~/.local/bin` on PATH, which only takes effect at login. If tmux is running,
`tmux kill-server` first, since it keeps the old environment.

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
