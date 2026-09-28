# Roadmap

## Next up
- [ ] **Syncthing** — sync folders between laptop, phone, and server
- [ ] **ntfy failure alerts** — `OnFailure=` hook sends a notification when a
      service fails; reuse the ntfy token via `LoadCredential`

## Media
- [ ] **Jellyfin + torrent client**
  - LAN only (`openFirewall`), not public; no Tailscale on the TV
  - Hardware transcoding via Intel Quick Sync (H.264/HEVC, no AV1)
  - Open questions: media storage (separate drive?), VPN for torrent client
  - Maybe later: Sonarr, Radarr, Prowlarr, Jellyseerr

## Parked
- [ ] **Backups** — Hetzner Storage Box BX11 (€3.20/mo) + restic; enable
      automatic snapshots. Required before Vaultwarden, Immich, etc.
- [ ] **Hairpin fix for home Wi-Fi** — dnsmasq on homelab answering `*.luis.vi`
      with Tailscale IP + Tailscale split DNS for `luis.vi` (free).
      Requires Tailscale always on. Replaces `/etc/hosts` and `networking.hosts`
- [ ] **Receipt printer** — `lp` group, udev rule for `/dev/receipt_printer`,
      package Perl script with `writePerlBin`. No CUPS needed
- [ ] **OpenClaw** — isolated (container/microVM/separate machine), gateway
      private, vetted skills only. Only after backups and sops-nix

## Later (once reliability matters)
- [ ] SSD health monitoring (`services.smartd`)
- [ ] Clean shutdown on low battery
- [ ] Forgejo Actions runner
- [ ] Automated `flake.lock` update PRs
- [ ] GitOps deployment (comin)
- [ ] Host this repo on Forgejo, push-mirror to GitHub
- [ ] fail2ban/CrowdSec for public services
- [ ] sops-nix for secrets

## Ideas
Vaultwarden, Tailscale exit node, RSS reader (Miniflux), Immich,
Paperless-ngx, Audiobookshelf, Radicale, code-server

## Habits
- Monthly: `nix flake update`, `make`, commit `flake.lock`
