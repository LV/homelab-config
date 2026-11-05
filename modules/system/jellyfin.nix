{ pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    # Closed to the LAN; reached directly over tailscale0, which is trusted.
    # Its listen address is managed in Jellyfin's UI, so it can't be pinned
    # to 127.0.0.1 here for tailscale serve.
    openFirewall = false;
  };

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
