_:

{
  homelab.tailscaleServe.forgejo = 3000;

  services = {
    forgejo = {
      enable = true;
      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1"; # exposed only through tailscale serve
          HTTP_PORT = 3000;
          DOMAIN = "lap-t480-01.gentoo-fahrenheit.ts.net";
          ROOT_URL = "https://lap-t480-01.gentoo-fahrenheit.ts.net:3000/";
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };
  };
}
