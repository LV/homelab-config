{
  config,
  lib,
  pkgs,
  ...
}:

let
  # The runner is created in Forgejo's UI (Site administration → Actions →
  # Runners), which hands out a UUID and a token. The UUID isn't secret; the
  # token lives in /var/lib/secrets and reaches the unit as a credential.
  # (nixpkgs' gitea-actions-runner module still uses the deprecated
  # `register` flow, which needs a registration token instead.)
  configFile = (pkgs.formats.yaml { }).generate "forgejo-runner.yaml" {
    server.connections.forgejo = {
      url = "http://127.0.0.1:3000/"; # Forgejo listens only on localhost
      uuid = "3ee00a0d-466e-4cf4-ae5d-d0987849806c";
      token_url = "file:$CREDENTIALS_DIRECTORY/token";
      # Jobs run directly on the host (no containers) and share its Nix store.
      # Fine while only my own repos use this runner.
      labels = [ "native:host" ];
    };
  };
in
{
  services.forgejo.settings.actions.ENABLED = true;

  systemd.services.forgejo-runner = {
    description = "Forgejo Actions runner";
    after = [
      "forgejo.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    # Tools available to jobs
    path = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gitMinimal
      gnused
      nodejs # JS actions like actions/checkout
      wget
      config.nix.package
    ];
    environment.HOME = "/var/lib/forgejo-runner";
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.forgejo-runner} daemon --config ${configFile}";
      DynamicUser = true;
      StateDirectory = "forgejo-runner";
      WorkingDirectory = "/var/lib/forgejo-runner";
      LoadCredential = "token:/var/lib/secrets/forgejo-runner-token";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
