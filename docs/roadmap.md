# Roadmap

## Principles
- bash must render on the homelab console (TERM=linux: 16 colors, no Nerd
  Fonts); gate fancy bits on TERM != linux
- tmux is SSH-only and client-agnostic: no Nerd Font icons or
  client-specific settings; console tmux is unsupported

## Quick wins
- [ ] Enable 2FA on Forgejo admin account

## Next up
- [ ] **Backups** — Hetzner Storage Box BX11 (€3.20/mo) + restic; enable
      automatic snapshots. Now urgent: server holds irreplaceable data.
      Include: `/home/v` (Obsidian vault), Forgejo, Jellyfin, Sonarr, Radarr,
      Prowlarr, qBittorrent, Syncthing, Grafana, ntfy (user DB) state, and
      `/var/lib/secrets` (Grafana's secret key can't be regenerated).
      Exclude: `/srv/media`
      Alert (ntfy) when the last successful backup is over 2 days old.
      Test a restore after setup (one service's state + some vault files to a
      scratch path, compare), then a few times a year
- [ ] **Dead-man's switch** — always-firing `Watchdog` alert, routed by
      Alertmanager to healthchecks.io, which alerts when pings stop. Covers
      the box, network, Prometheus and Alertmanager; the box's own alerts go
      silent if any of those fail
- [ ] **Low-battery shutdown**
  - UPower powers off cleanly at a critical battery level
  - `BatteryLow` alert before that, so the shutdown isn't a surprise
  - Check by hand: does coreboot power the laptop back on when AC returns?
    If not, a long outage leaves it off until someone presses power
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
- [ ] **Service uptime checks** — blackbox exporter probes each service URL;
      alert when one is running but broken (e.g. Jellyfin returning 502s)
- [ ] Automated `flake.lock` update PRs
- [ ] GitOps deployment (comin)
- [ ] sops-nix for secrets

## Ideas
Vaultwarden (after backups), Tailscale exit node, RSS reader (Miniflux),
Paperless-ngx, Audiobookshelf, Radicale, code-server, bat-extras
(batman, batgrep, batdiff) + MANPAGER via bat

## Habits
- Monthly: `nix flake update`, `make`, commit `flake.lock`
