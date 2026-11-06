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
  };

  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "hosts";
      folder = "Hosts";
      options.path = dashboards;
    }
  ];
}
