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
          # One host, few rules: little to batch, so notify fast
          group_wait = "10s"; # first notification (default 30s)
          group_interval = "1m"; # updates and resolved notices (default 5m)
          # Alerts that stay on (e.g. SSD wear) remind twice a day
          repeat_interval = "12h";
          routes = [
            {
              # Dead-man's switch: ping healthchecks.io every minute; it
              # alerts from outside this box when the pings stop
              matchers = [ ''alertname="Watchdog"'' ];
              receiver = "healthchecks";
              group_wait = "0s";
              # Repeats are only checked on group_interval ticks, and 1m/1m
              # lands just short of due, so pings came every 2m
              group_interval = "15s";
              repeat_interval = "1m";
            }
          ];
        };
        receivers = [
          {
            name = "ntfy";
            webhook_configs = [ { url = "http://${bridgeAddr}/hook"; } ];
          }
          {
            name = "healthchecks";
            webhook_configs = [
              {
                url_file = "/run/credentials/alertmanager.service/healthchecks-url";
                # A resolved notice would count as a ping, masking a dead Prometheus
                send_resolved = false;
              }
            ];
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
                  # Always fires; routed to healthchecks.io as a heartbeat
                  alert = "Watchdog";
                  expr = "vector(1)";
                  labels.severity = "none";
                  annotations.summary = "Alerting pipeline heartbeat";
                }
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

  # healthchecks.io ping URL; see docs/secrets.md
  systemd.services.alertmanager.serviceConfig.LoadCredential = [
    "healthchecks-url:/var/lib/secrets/healthchecks-url"
  ];

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
