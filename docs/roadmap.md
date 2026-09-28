# Roadmap

## Quick wins
- [ ] Enable 2FA on Forgejo admin account

## Next up
- [ ] **End-to-end *arr test** — add *Night of the Living Dead* (1968) in Radarr
      via Internet Archive; confirm qBittorrent → hardlink import → Jellyfin
- [ ] **ntfy failure alerts** — `OnFailure=` hook notifies when a service fails;
      reuse ntfy token via `LoadCredential`
- [ ] **Backups** — Hetzner Storage Box BX11 (€3.20/mo) + restic; enable
      automatic snapshots. Now urgent: server holds irreplaceable data.
      Include: `/home/v` (Obsidian vault), Forgejo, Jellyfin, Sonarr, Radarr,
      Prowlarr, qBittorrent, Syncthing state. Exclude: `/srv/media`

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
- [ ] **Hairpin fix for home Wi-Fi** — dnsmasq answering `*.luis.vi` with the
      Tailscale IP + Tailscale split DNS for `luis.vi` (free). Requires
      Tailscale always on. Replaces laptop `/etc/hosts` and `networking.hosts`
- [ ] **Receipt printer** — `lp` group, udev rule for `/dev/receipt_printer`,
      package Perl script with `writePerlBin`. No CUPS needed
- [ ] **OpenClaw** — isolated (container/microVM/separate machine), gateway
      private, vetted skills only. Only after backups and sops-nix

## Later (once reliability matters)
- [ ] SSD health monitoring (`services.smartd`)
- [ ] Clean shutdown on low battery
- [ ] Forgejo Actions runner (lint/build this repo on push)
- [ ] Automated `flake.lock` update PRs
- [ ] GitOps deployment (comin)
- [ ] fail2ban/CrowdSec for public services
- [ ] sops-nix for secrets

## Ideas
Vaultwarden (after backups), Tailscale exit node, RSS reader (Miniflux),
Immich, Paperless-ngx, Audiobookshelf, Radicale, code-server

## Done
- [x] Forgejo at `git.luis.vi` (Caddy, HTTPS, registration off, localhost-only)
- [x] Hetzner DNS updater (`git`, `ntfy`)
- [x] Tailscale + doom coding (Termius, Claude Code, tmux)
- [x] Tailscale key expiry disabled for `homelab`
- [x] Key-only SSH (MacBook, iPhone)
- [x] Automatic Nix GC + store optimisation
- [x] ntfy at `ntfy.luis.vi` + `notify` command
- [x] Config repo on Forgejo; push mirrors to GitHub
- [x] Syncthing (Obsidian vault: iPhone ↔ homelab ↔ MacBook)
- [x] Jellyfin (LAN + Tailscale, VA-API transcoding, trickplay)
- [x] qBittorrent in Mullvad VPN namespace (leak-tested)
- [x] Prowlarr (in VPN), Sonarr, Radarr — connected via `192.168.15.x`

## Habits
- Monthly: `nix flake update`, `make`, commit `flake.lock`
