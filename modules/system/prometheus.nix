_:

# Prometheus server only. What it collects lives in metrics/*.nix, each of
# which adds its own scrape job and Grafana folder.
let
  port = 9090;
in
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1"; # exposed only through tailscale serve
    inherit port;
    retentionTime = "1y";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s"; # check rules on every scrape (default 1m)
    };
  };

  homelab.tailscaleServe.prometheus = port;

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Prometheus";
      type = "prometheus";
      uid = "prometheus";
      url = "http://127.0.0.1:${toString port}";
      isDefault = true;
    }
  ];
}
