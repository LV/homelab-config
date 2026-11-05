{ lib, ... }:

{
  # Listens only on the VPN bridge, where Prowlarr (inside the namespace)
  # calls it; the tailnet reaches it through Serve
  services.radarr = {
    enable = true;
    settings.server.bindaddress = "192.168.15.5";
  };

  homelab.tailscaleServe.radarr = {
    port = 7878;
    target = "http://192.168.15.5:7878";
  };

  networking.firewall.interfaces.mullvad-br.allowedTCPPorts = [ 7878 ];

  users.users.radarr.extraGroups = [ "media" ];
  systemd.services.radarr = {
    # The bridge address must exist before it can bind to it
    after = [ "mullvad.service" ];
    wants = [ "mullvad.service" ];
    serviceConfig.UMask = lib.mkForce "0002";
  };
}
