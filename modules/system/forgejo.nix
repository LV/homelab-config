_:

{
  services = {
    forgejo = {
      enable = true;
      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          DOMAIN = "git.luis.vi";
          ROOT_URL = "https://git.luis.vi/";
        };
        service.DISABLE_REGISTRATION = true;
      };
    };

    caddy.virtualHosts."git.luis.vi".extraConfig = ''
      reverse_proxy 127.0.0.1:3000
    '';
  };
}
