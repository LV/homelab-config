{ inputs, ... }:

{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = "/var/lib/secrets/mullvad-wg.conf";
    namespaceAddress = "192.168.15.1";
    bridgeAddress = "192.168.15.5";
    accessibleFrom = [
      "192.168.1.0/24" # home network
      "100.64.0.0/10" # Tailscale
    ];
    portMappings = [
      {
        from = 8090;
        to = 8090;
      }
    ];
  };

  services.qbittorrent = {
    enable = true;
    webuiPort = 8090;
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
