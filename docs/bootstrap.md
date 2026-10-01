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
- **Settings:** managed by the `claude-code` module
  (`/etc/claude-code/managed-settings.json`)

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude   # sign in on first run
```

## Plannotator

- **Path:** `~/.local/bin/plannotator`
- **Updates:** rerun the install command
- **Claude Code plugin:** installed automatically via managed settings, so only
  the binary is needed (`--minimal`)

```bash
curl -fsSL https://plannotator.ai/install.sh | bash -s -- --minimal
```

Plannotator's ntfy notifications also need the ntfy token; see
[secrets](secrets.md#ntfy-token-for-notify).

## Verify

```bash
which claude plannotator   # both in ~/.local/bin
claude --version
plannotator --version
```

In Claude Code, `/status` should list "Enterprise managed settings" under
setting sources, and `/plugin` should show Plannotator installed and enabled.
