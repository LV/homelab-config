{ config, pkgs, ... }:

let
  port = 9090;
  nodePort = config.services.prometheus.exporters.node.port;

  # Community "Node Exporter Full" dashboard; its datasource variable
  # picks the default Prometheus datasource, so no UID rewriting needed
  dashboards = pkgs.linkFarm "grafana-dashboards" {
    "node-exporter-full.json" = pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/1860/revisions/46/download";
      hash = "sha256-5Y3cXcU11MkB+U2pZIvD49Wue2946Y4YW86LKJlhzqM=";
    };
  };
in
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1"; # exposed only through tailscale serve
    inherit port;
    retentionTime = "1y";
    globalConfig.scrape_interval = "15s";

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
            targets = [ "127.0.0.1:${toString nodePort}" ];
            # Show the hostname in Grafana instead of 127.0.0.1:9100
            labels.instance = config.networking.hostName;
          }
        ];
      }
    ];
  };

  homelab.tailscaleServe.prometheus = port;

  services.grafana.provision = {
    enable = true;
    datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        uid = "prometheus";
        url = "http://127.0.0.1:${toString port}";
        isDefault = true;
      }
    ];
    dashboards.settings.providers = [
      {
        name = "homelab";
        options.path = dashboards;
      }
    ];
  };
}
