{ ... }:

{
  services = {
    forgejo = {
      enable = true;
      settings = {
        server = {
          HTTP_PORT = 3000;
          DOMAIN = "git.luis.vi";
          ROOT_URL = "https://git.luis.vi/";
        };
        service.DISABLE_REGISTRATION = true;
      };
    };

    caddy.virtualHosts."git.luis.vi".extraConfig = ''
      reverse_proxy localhost:3000
    '';
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
