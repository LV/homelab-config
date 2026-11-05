{ pkgs, ... }:

{
  # Jellyfin's listen address lives in its UI (Dashboard > Networking), not
  # here: it must be set to 127.0.0.1, or Serve can't take port 8096
  homelab.tailscaleServe.jellyfin = 8096;

  services.jellyfin.enable = true;

  users.users.jellyfin.extraGroups = [
    "media"
    "render"
    "video"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };
}
