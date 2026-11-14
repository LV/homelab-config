{ inputs, pkgs, ... }:

{
  home.packages = [ inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  # Only AGENTS.md: Pi writes to settings.json itself (deviceId, changelog version).
  home.file.".pi/agent/AGENTS.md".source = inputs.dotfiles + "/config/pi/AGENTS.md";
}
