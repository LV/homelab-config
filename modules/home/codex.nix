{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  programs.codex = {
    enable = true;
    package = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # Every 5 min, start Codex's 5-hour window if none is running; see scripts/codex-kickstart.pl.
  systemd.user.services.codex-kickstart = {
    Unit.Description = "Start the Codex 5-hour window if none is running";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.perl}/bin/perl ${../../scripts/codex-kickstart.pl}";
      Environment = "PATH=${lib.makeBinPath [ config.programs.codex.package ]}";
    };
  };
  systemd.user.timers.codex-kickstart = {
    Timer = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
