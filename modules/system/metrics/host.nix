{ config, pkgs, ... }:

# Host telemetry: node_exporter reads CPU, memory, disk, network, sensors and
# systemd unit states; Prometheus scrapes it; Grafana shows it under "Hosts"
let
  nodeExporter = config.services.prometheus.exporters.node;

  dashboards = pkgs.linkFarm "grafana-hosts-dashboards" {
    # "Node Exporter Full", grafana.com dashboard 1860
    "node-exporter-full.json" = pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/1860/revisions/46/download";
      hash = "sha256-5Y3cXcU11MkB+U2pZIvD49Wue2946Y4YW86LKJlhzqM=";
    };
  };
in
{
  services.prometheus = {
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      enabledCollectors = [ "systemd" ]; # unit states, on top of the defaults
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString nodeExporter.port}" ];
            # Show the hostname in Grafana instead of 127.0.0.1:9100
            labels.instance = config.networking.hostName;
          }
        ];
      }
    ];

    ruleFiles = [
      (pkgs.writeText "host-rules.json" (
        builtins.toJSON {
          groups = [
            {
              name = "host";
              rules = [
                {
                  alert = "SystemdUnitFailed";
                  expr = ''node_systemd_unit_state{state="failed"} == 1'';
                  for = "1m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "Unit failed: {{ $labels.name }}";
                    description = "{{ $labels.name }} is in the failed state on {{ $labels.instance }}.";
                  };
                }
                {
                  alert = "DiskAlmostFull";
                  expr = ''node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.15'';
                  for = "15m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "Disk almost full on {{ $labels.instance }}";
                    description = "Only {{ $value | humanizePercentage }} free on /.";
                  };
                }
                {
                  alert = "OnBattery";
                  expr = ''node_power_supply_online{power_supply="AC"} == 0'';
                  for = "2m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "On battery: {{ $labels.instance }}";
                    description = "AC power has been lost for over 2 minutes.";
                  };
                }
                {
                  alert = "CpuHot";
                  # The CPU's critical temperature is 100 (node_hwmon_temp_crit_celsius)
                  expr = ''max by (instance) (node_hwmon_temp_celsius{chip="platform_coretemp_0"}) > 90'';
                  for = "10m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "CPU hot on {{ $labels.instance }}";
                    description = "CPU at {{ $value }}°C for over 10 minutes.";
                  };
                }
              ];
            }
          ];
        }
      ))
    ];
  };

  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "hosts";
      folder = "Hosts";
      options.path = dashboards;
    }
  ];
}
