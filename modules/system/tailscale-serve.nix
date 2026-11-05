{
  config,
  lib,
  pkgs,
  ...
}:

let
  tailscale = "${config.services.tailscale.package}/bin/tailscale";
  # Units take turns: concurrent `tailscale serve` calls fail with an
  # etag mismatch, since each overwrites the config the other just read
  locked = "${pkgs.util-linux}/bin/flock /run/tailscale-serve.lock ${tailscale}";

  serveType = lib.types.submodule (
    { config, ... }: {
      options = {
        port = lib.mkOption {
          type = lib.types.port;
          description = "Port served over HTTPS on the node's tailnet address.";
        };
        target = lib.mkOption {
          type = lib.types.str;
          default = "http://127.0.0.1:${toString config.port}";
          defaultText = lib.literalExpression ''"http://127.0.0.1:''${toString port}"'';
          description = "Where Serve forwards requests to.";
        };
      };
    }
  );
in
{
  options.homelab.tailscaleServe = lib.mkOption {
    type = lib.types.attrsOf (lib.types.coercedTo lib.types.port (port: { inherit port; }) serveType);
    default = { };
    example = {
      grafana = 3001;
      sonarr = {
        port = 8989;
        target = "http://192.168.15.5:8989";
      };
    };
    description = ''
      Applications to expose on the tailnet (Tier 2) over HTTPS with the
      node's Tailscale certificate. Each one gets a tailscale-serve-<name>
      unit that maps the same port on the node's tailnet address to its
      target, leaving other apps' mappings alone. A bare port means
      http://127.0.0.1:<port>.
    '';
  };

  config.systemd.services = lib.mapAttrs' (
    name: serve:
    lib.nameValuePair "tailscale-serve-${name}" {
      description = "Expose ${name} on the tailnet with Tailscale Serve";
      after = [ "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = "${tailscale} wait";
        ExecStart = "${locked} serve --bg --yes --https=${toString serve.port} ${serve.target}";
        ExecStop = "${locked} serve --https=${toString serve.port} off";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    }
  ) config.homelab.tailscaleServe;
}
