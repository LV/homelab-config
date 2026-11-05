{ lib, ... }:

{
  # Listens only on the VPN bridge, where Prowlarr (inside the namespace)
  # calls it; the tailnet reaches it through Serve
  services.sonarr = {
    enable = true;
    settings.server.bindaddress = "192.168.15.5";
  };

  homelab.tailscaleServe.sonarr = {
    port = 8989;
    target = "http://192.168.15.5:8989";
  };

  networking.firewall.interfaces.mullvad-br.allowedTCPPorts = [ 8989 ];

  users.users.sonarr.extraGroups = [ "media" ];
  systemd.services.sonarr = {
    # The bridge address must exist before it can bind to it
    after = [ "mullvad.service" ];
    wants = [ "mullvad.service" ];
    serviceConfig.UMask = lib.mkForce "0002";
  };
}
