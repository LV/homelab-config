{ config, lib, ... }:

let
  tailscale = "${config.services.tailscale.package}/bin/tailscale";
in
{
  options.homelab.tailscaleServe = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = { };
    example = {
      grafana = 3001;
    };
    description = ''
      Applications to expose on the tailnet (Tier 2). Each one gets a
      tailscale-serve-<name> unit that maps the same port on the node's tailnet
      address to 127.0.0.1:<port>, leaving other apps' mappings alone.
    '';
  };

  config.systemd.services = lib.mapAttrs' (
    name: port:
    lib.nameValuePair "tailscale-serve-${name}" {
      description = "Expose ${name} on the tailnet with Tailscale Serve";
      after = [ "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = "${tailscale} wait";
        # HTTP until Tailscale HTTPS works; then switch to --https
        ExecStart = "${tailscale} serve --bg --yes --http=${toString port} http://127.0.0.1:${toString port}";
        ExecStop = "${tailscale} serve --http=${toString port} off";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    }
  ) config.homelab.tailscaleServe;
}
