{ ... }:

{
  services.forgejo = {
    enable = true;
    settings.server = {
      HTTP_PORT = 3000;
      DOMAIN = "192.168.1.50";
      ROOT_URL = "http://192.168.1.13:3000/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
