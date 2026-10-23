{ lib, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true; # home network; Tailscale is already trusted
    # Homepage rejects requests whose Host header isn't listed here
    allowedHosts = lib.concatStringsSep "," [
      "localhost:8082"
      "127.0.0.1:8082"
      "homelab:8082"
      "homelab.gentoo-fahrenheit.ts.net:8082"
      "100.66.148.66:8082"
      "192.168.1.13:8082"
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
    # Links use the Tailscale MagicDNS name, so they work at home and away
    services = [
      {
        Media = [
          {
            Jellyfin = {
              href = "http://homelab:8096";
              icon = "jellyfin.png";
              description = "Media server";
            };
          }
          {
            Sonarr = {
              href = "http://homelab:8989";
              icon = "sonarr.png";
              description = "TV shows";
            };
          }
          {
            Radarr = {
              href = "http://homelab:7878";
              icon = "radarr.png";
              description = "Movies";
            };
          }
          {
            Prowlarr = {
              href = "http://homelab:9696";
              icon = "prowlarr.png";
              description = "Indexer manager";
            };
          }
          {
            qBittorrent = {
              href = "http://homelab:8090";
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
              href = "https://git.luis.vi";
              icon = "forgejo.png";
              description = "Git hosting";
            };
          }
          {
            ntfy = {
              href = "https://ntfy.luis.vi";
              icon = "ntfy.png";
              description = "Push notifications";
            };
          }
        ];
      }
    ];
  };
}
