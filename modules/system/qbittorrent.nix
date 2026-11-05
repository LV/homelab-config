{ inputs, ... }:

{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = "/var/lib/secrets/mullvad-wg.conf";
    namespaceAddress = "192.168.15.1";
    bridgeAddress = "192.168.15.5";
    # No outside sources: the host reaches the namespace over the bridge, and
    # the tailnet goes through Serve
    accessibleFrom = [ ];
    # A mapping is the only way to open its `to` port in the namespace's own
    # firewall, which the host (Serve, Sonarr, Radarr) needs. Its `from` port
    # is deliberately unused: a host-side forward on 8090 would catch
    # tailnet traffic before Serve sees it
    portMappings = [
      {
        from = 18090;
        to = 8090;
      }
    ];
  };

  homelab.tailscaleServe.qbittorrent = {
    port = 8090;
    target = "http://192.168.15.1:8090";
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
