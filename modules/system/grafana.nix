{ pkgs, ... }:

let
  port = 3001;
  host = "lap-t480-01.gentoo-fahrenheit.ts.net";
  secretsDir = "/var/lib/secrets";

  # Creates each secret once; never overwrite the secret key, or Grafana
  # can no longer decrypt what it stored with the old one
  generateSecrets = pkgs.writeShellApplication {
    name = "grafana-secrets";
    runtimeInputs = [ pkgs.openssl ];
    text = ''
      install -d -m 700 ${secretsDir}
      umask 077
      for name in grafana-admin-password grafana-secret-key; do
        file="${secretsDir}/$name"
        if [ ! -s "$file" ]; then
          openssl rand -hex 32 > "$file"
          echo "Generated $file"
        fi
      done
    '';
  };
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1"; # exposed only through tailscale serve
        http_port = port;
        domain = host;
        root_url = "https://${host}:${toString port}/";
      };
      security = {
        # Applied only when Grafana first creates the admin user
        admin_user = "v";
        cookie_secure = true;
        admin_password = "$__file{/run/credentials/grafana.service/admin-password}";
        secret_key = "$__file{/run/credentials/grafana.service/secret-key}";
      };
      "auth.anonymous".enabled = false;
      users.allow_sign_up = false;
      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
        check_for_plugin_updates = false;
      };
      news.news_feed_enabled = false;
    };
  };

  homelab.tailscaleServe.grafana = port;

  systemd.services = {
    grafana-secrets = {
      description = "Generate Grafana's admin password and secret key";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${generateSecrets}/bin/grafana-secrets";
      };
    };

    grafana = {
      requires = [ "grafana-secrets.service" ];
      after = [ "grafana-secrets.service" ];
      serviceConfig.LoadCredential = [
        "admin-password:${secretsDir}/grafana-admin-password"
        "secret-key:${secretsDir}/grafana-secret-key"
      ];
    };
  };
}
