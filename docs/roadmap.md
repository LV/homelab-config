# Roadmap

## Principles
- bash must render on the homelab console (TERM=linux: 16 colors, no Nerd
  Fonts); gate fancy bits on TERM != linux
- tmux is SSH-only and client-agnostic: no Nerd Font icons or
  client-specific settings; console tmux is unsupported

## Quick wins
- [ ] Enable 2FA on Forgejo admin account
- [ ] **Clipboard client checks** (`docs/clipboard.md`) — Ghostty on MacBook
      and Termius on phone, plain SSH and tmux; both attached at once, large
      payloads, console without tmux

## Next up
- [ ] **End-to-end *arr test** — add *Night of the Living Dead* (1968) in Radarr
      via Internet Archive; confirm qBittorrent → hardlink import → Jellyfin
- [ ] **ntfy failure alerts** — `OnFailure=` hook notifies when a service fails;
      reuse ntfy token via `LoadCredential`
- [ ] **Backups** — Hetzner Storage Box BX11 (€3.20/mo) + restic; enable
      automatic snapshots. Now urgent: server holds irreplaceable data.
      Include: `/home/v` (Obsidian vault), Forgejo, Jellyfin, Sonarr, Radarr,
      Prowlarr, qBittorrent, Syncthing, Grafana, ntfy (user DB) state, and
      `/var/lib/secrets` (Grafana's secret key can't be regenerated).
      Exclude: `/srv/media`
- [ ] **AI usage monitoring**
  - Collect Claude and Codex credit usage (a `/status`-style check) into
    Prometheus; graph it in Grafana
  - Window starter: once usage refreshes, send a minimal prompt ("Say
    hello") so the 4-hour window starts right away and resets sooner
    after heavy use. Currently done by hand
- [ ] **Immich** (self-hosted Google Photos) — `services.immich`, iPhone
      auto-upload, library on its own path under `/srv`. Only after backups:
      photos are irreplaceable. Add its library + Postgres dump to restic

## Media
- [ ] **Indexer access through VPN**
  - 1337x and EZTV fail from the Mullvad namespace; Internet Archive works
  - FlareSolverr solves 1337x's challenge, but Prowlarr's follow-up is rejected
  - Theory: sites block/challenge Mullvad IPs
  - Next test: `sudo ip netns exec mullvad curl -sS -o /dev/null -w '%{http_code}\n' https://<site>`
    vs the same `curl` without `ip netns exec mullvad`
  - Possible fix: move Prowlarr + FlareSolverr out of the VPN; qBittorrent stays in.
    Tradeoff: indexer sites see home IP
- [ ] **Bazarr** (subtitles) and **Jellyseerr** (request page) — optional
- [ ] **Document web-UI-managed settings** (qBittorrent, Jellyfin, Sonarr,
      Radarr, Prowlarr, Syncthing) in `docs/`

## Parked
- [ ] **Receipt printer** — `lp` group, udev rule for `/dev/receipt_printer`,
      package Perl script with `writePerlBin`. No CUPS needed

## Later (once reliability matters)
- [ ] SSD health monitoring (`services.smartd`)
- [ ] Clean shutdown on low battery
- [ ] CI workflow for this repo (lint/build on push)
- [ ] Automated `flake.lock` update PRs
- [ ] GitOps deployment (comin)
- [ ] sops-nix for secrets

## Ideas
Vaultwarden (after backups), Tailscale exit node, RSS reader (Miniflux),
Paperless-ngx, Audiobookshelf, Radicale, code-server, bat-extras
(batman, batgrep, batdiff) + MANPAGER via bat

## Habits
- Monthly: `nix flake update`, `make`, commit `flake.lock`
