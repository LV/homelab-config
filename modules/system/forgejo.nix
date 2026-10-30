_:

{
  services = {
    forgejo = {
      enable = true;
      settings = {
        server = {
          HTTP_ADDR = "0.0.0.0"; # firewall only exposes it on tailscale0
          HTTP_PORT = 3000;
          DOMAIN = "lap-t480-01.gentoo-fahrenheit.ts.net";
          ROOT_URL = "http://lap-t480-01.gentoo-fahrenheit.ts.net:3000/";
        };
        service.DISABLE_REGISTRATION = true;
      };
    };
  };
}
