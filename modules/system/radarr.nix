{ lib, ... }:

{
  services.radarr = {
    enable = true;
    # Closed to the LAN; reached directly over tailscale0, which is trusted.
    # Listens on all interfaces because Prowlarr calls it from the VPN
    # namespace through the bridge (192.168.15.5).
    openFirewall = false;
  };

  networking.firewall.interfaces.mullvad-br.allowedTCPPorts = [ 7878 ];

  users.users.radarr.extraGroups = [ "media" ];
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";
}
