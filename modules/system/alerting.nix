{ config, pkgs, ... }:

# Alerting: Prometheus evaluates the rules each metrics/*.nix module adds,
# Alertmanager groups and repeats them, alertmanager-ntfy forwards them to
# ntfy (topic "homelab"). Grafana shows active alerts and silences
let
  alertmanager = config.services.prometheus.alertmanager;
  bridgeAddr = "127.0.0.1:8000";
in
{
  services.prometheus = {
    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      configuration = {
        route = {
          receiver = "ntfy";
          group_by = [
            "alertname"
            "instance"
          ];
          # Alerts that stay on (e.g. SSD wear) remind twice a day
          repeat_interval = "12h";
        };
        receivers = [
          {
            name = "ntfy";
            webhook_configs = [ { url = "http://${bridgeAddr}/hook"; } ];
          }
        ];
      };
    };

    alertmanagers = [
      { static_configs = [ { targets = [ "127.0.0.1:${toString alertmanager.port}" ]; } ]; }
    ];

    alertmanager-ntfy = {
      enable = true;
      settings = {
        http.addr = bridgeAddr;
        ntfy = {
          # Local ntfy, so alerts don't depend on Tailscale
          baseurl = "http://127.0.0.1:2586";
          notification.topic = "homelab";
        };
      };
      # ntfy.auth.token; see docs/secrets.md
      extraConfigFiles = [ "/var/lib/secrets/alertmanager-ntfy.yml" ];
    };

    ruleFiles = [
      (pkgs.writeText "prometheus-rules.json" (
        builtins.toJSON {
          groups = [
            {
              name = "prometheus";
              rules = [
                {
                  alert = "TargetDown";
                  expr = "up == 0";
                  for = "5m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "Scrape target down: {{ $labels.job }}";
                    description = "Prometheus can't scrape {{ $labels.job }} on {{ $labels.instance }}.";
                  };
                }
              ];
            }
          ];
        }
      ))
    ];
  };

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Alertmanager";
      type = "alertmanager";
      uid = "alertmanager";
      url = "http://127.0.0.1:${toString alertmanager.port}";
      jsonData = {
        implementation = "prometheus";
        handleGrafanaManagedAlerts = false;
      };
    }
  ];
}
