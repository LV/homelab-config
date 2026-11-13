{ config, pkgs, ... }:

# SSD health: smartctl_exporter reads SMART/NVMe health (wear, spare, media
# errors, temperature); Prometheus scrapes it; Grafana shows it under "Hosts"
let
  smartctlExporter = config.services.prometheus.exporters.smartctl;

  # "SMARTctl Exporter Dashboard", grafana.com dashboard 22604. It's an export
  # with a ${DS_PROMETHEUS} input that file provisioning doesn't fill in, so
  # point it at our datasource uid ourselves
  dashboard = pkgs.fetchurl {
    url = "https://grafana.com/api/dashboards/22604/revisions/4/download";
    hash = "sha256-ah36BdFIcaprUz39hRzuYVzfp3diEBckmalMaOls5kY=";
  };

  dashboards = pkgs.runCommand "grafana-smart-dashboards" { } ''
    mkdir $out
    substitute ${dashboard} $out/smartctl.json \
      --replace-fail '${"$"}{DS_PROMETHEUS}' prometheus
  '';
in
{
  services.prometheus = {
    exporters.smartctl = {
      enable = true;
      listenAddress = "127.0.0.1";
      # devices left empty = autodiscover via smartctl --scan
    };

    scrapeConfigs = [
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString smartctlExporter.port}" ];
            # Show the hostname in Grafana instead of 127.0.0.1:9633
            labels.instance = config.networking.hostName;
          }
        ];
      }
    ];
  };

  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "smart";
      folder = "Hosts";
      options.path = dashboards;
    }
  ];
}
