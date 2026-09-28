{ inputs, ... }:

{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = "/var/lib/secrets/mullvad-wg.conf";
    accessibleFrom = [
      "192.168.1.0/24" # home network
      "100.64.0.0/10" # Tailscale
    ];
    portMappings = [
      {
        from = 8080;
        to = 8080;
      }
    ];
  };

  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    extraArgs = [ "--confirm-legal-notice" ];
  };

  systemd.services.qbittorrent = {
    vpnConfinement = {
      enable = true;
      vpnNamespace = "mullvad";
    };
    serviceConfig.UMask = "0002";
  };

  users.users.qbittorrent.extraGroups = [ "media" ];
}
