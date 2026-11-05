_:

{
  services.prowlarr.enable = true;

  systemd.services.prowlarr.vpnConfinement = {
    enable = true;
    vpnNamespace = "mullvad";
  };

  vpnNamespaces.mullvad = {
    # Calls Sonarr and Radarr on the bridge
    allowedEgress = [ "192.168.15.5" ];
    # Opens 9696 in the namespace firewall; the unused 19696 keeps the
    # host-side forward off Serve's port (see qbittorrent.nix)
    portMappings = [
      {
        from = 19696;
        to = 9696;
      }
    ];
  };

  # The tailnet reaches it through Serve, which talks to the namespace over
  # the bridge
  homelab.tailscaleServe.prowlarr = {
    port = 9696;
    target = "http://192.168.15.1:9696";
  };
}
