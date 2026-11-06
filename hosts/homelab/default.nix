_:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/forgejo.nix
    ../../modules/system/grafana.nix
    ../../modules/system/homepage.nix
    ../../modules/system/jellyfin.nix
    ../../modules/system/lid.nix
    ../../modules/system/media.nix
    ../../modules/system/ntfy.nix
    ../../modules/system/prometheus.nix
    ../../modules/system/prowlarr.nix
    ../../modules/system/qbittorrent.nix
    ../../modules/system/radarr.nix
    ../../modules/system/sonarr.nix
    ../../modules/system/syncthing.nix
    ../../modules/system/tailscale-serve.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    configurationLimit = 10;
  };

  networking.hostName = "lap-t480-01";

  time.timeZone = "America/New_York";

  # Set to the FIRST NixOS release installed on this machine. Never change it.
  system.stateVersion = "26.05";
}
