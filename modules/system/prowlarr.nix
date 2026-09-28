_:

{
  services.prowlarr.enable = true;

  systemd.services.prowlarr.vpnConfinement = {
    enable = true;
    vpnNamespace = "mullvad";
  };

  vpnNamespaces.mullvad = {
    portMappings = [
      {
        from = 9696;
        to = 9696;
      }
    ];
    allowedEgress = [ "192.168.15.5" ];
  };
}
