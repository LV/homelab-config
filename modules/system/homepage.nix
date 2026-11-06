{ lib, ... }:

let
  host = "lap-t480-01.gentoo-fahrenheit.ts.net";
in
{
  homelab.tailscaleServe.homepage = 8082;

  # Next.js reads its listen address from HOSTNAME
  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";

  services.homepage-dashboard = {
    enable = true;
    openFirewall = false; # exposed only through tailscale serve
    # Homepage rejects requests whose Host header isn't listed here
    allowedHosts = lib.concatStringsSep "," [
      "localhost:8082"
      "127.0.0.1:8082"
      "${host}:8082"
    ];
    settings.title = "homelab";
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
    ];
    # Links use the full Tailscale name, so they work at home and away
    services = [
      {
        Media = [
          {
            Jellyfin = {
              href = "https://${host}:8096";
              icon = "jellyfin.png";
              description = "Media server";
            };
          }
          {
            Sonarr = {
              href = "https://${host}:8989";
              icon = "sonarr.png";
              description = "TV shows";
            };
          }
          {
            Radarr = {
              href = "https://${host}:7878";
              icon = "radarr.png";
              description = "Movies";
            };
          }
          {
            Prowlarr = {
              href = "https://${host}:9696";
              icon = "prowlarr.png";
              description = "Indexer manager";
            };
          }
          {
            qBittorrent = {
              href = "https://${host}:8090";
              icon = "qbittorrent.png";
              description = "Torrent client";
            };
          }
        ];
      }
      {
        Tools = [
          {
            Forgejo = {
              href = "https://${host}:3000";
              icon = "forgejo.png";
              description = "Git hosting";
            };
          }
          {
            Grafana = {
              href = "https://${host}:3001";
              icon = "grafana.png";
              description = "Dashboards";
            };
          }
          {
            Syncthing = {
              href = "https://${host}:8384";
              icon = "syncthing.png";
              description = "File sync";
            };
          }
          {
            ntfy = {
              href = "https://${host}:2586";
              icon = "ntfy.png";
              description = "Push notifications";
            };
          }
        ];
      }
    ];
  };
}
