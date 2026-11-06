_:

{
  services.ntfy-sh = {
    enable = true;
    environmentFile = "/var/lib/secrets/ntfy.env";
    settings = {
      base-url = "https://lap-t480-01.gentoo-fahrenheit.ts.net:2586";
      listen-http = "127.0.0.1:2586"; # exposed only through tailscale serve
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      auth-default-access = "deny-all";
    };
  };

  homelab.tailscaleServe.ntfy = 2586;
}
