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

    ruleFiles = [
      (pkgs.writeText "smart-rules.json" (
        builtins.toJSON {
          groups = [
            {
              name = "smart";
              rules = [
                {
                  # NVMe's own "something is wrong" bitmask: spare below
                  # threshold, temperature, reliability, read-only, backup power
                  alert = "SsdCriticalWarning";
                  expr = "smartctl_device_critical_warning != 0";
                  labels.severity = "critical";
                  annotations = {
                    summary = "SSD critical warning: {{ $labels.device }}";
                    description = "{{ $labels.device }} on {{ $labels.instance }} reports critical_warning={{ $value }}.";
                  };
                }
                {
                  alert = "SsdSmartFailed";
                  expr = "smartctl_device_smart_status == 0";
                  labels.severity = "critical";
                  annotations = {
                    summary = "SSD SMART failed: {{ $labels.device }}";
                    description = "{{ $labels.device }} on {{ $labels.instance }} fails its SMART self-assessment.";
                  };
                }
                {
                  # The counter never resets, so alert on new errors only
                  alert = "SsdMediaErrors";
                  expr = "increase(smartctl_device_media_errors[1h]) > 0";
                  labels.severity = "warning";
                  annotations = {
                    summary = "SSD media errors: {{ $labels.device }}";
                    description = "{{ $labels.device }} on {{ $labels.instance }} logged new media errors in the last hour.";
                  };
                }
                {
                  alert = "SsdWearHigh";
                  expr = "smartctl_device_percentage_used >= 80";
                  labels.severity = "warning";
                  annotations = {
                    summary = "SSD wear high: {{ $labels.device }}";
                    description = "{{ $labels.device }} on {{ $labels.instance }} has used {{ $value }}% of its rated endurance.";
                  };
                }
                {
                  # Exporter up but sees no drive (e.g. no access to the
                  # device); 30m covers its 10m rescan after boot
                  alert = "SsdDataMissing";
                  expr = "absent(smartctl_device)";
                  for = "30m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "No SSD health data";
                    description = "smartctl_exporter reports no drives; check its journal.";
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
      name = "smart";
      folder = "Hosts";
      options.path = dashboards;
    }
  ];
}
