_:

{
  services = {
    ntfy-sh = {
      enable = true;
      environmentFile = "/var/lib/secrets/ntfy.env";
      settings = {
        base-url = "https://ntfy.luis.vi";
        listen-http = "127.0.0.1:2586";
        behind-proxy = true;
        upstream-base-url = "https://ntfy.sh";
        auth-default-access = "deny-all";
      };
    };

    caddy.virtualHosts."ntfy.luis.vi".extraConfig = ''
      reverse_proxy 127.0.0.1:2586
    '';
  };
}
