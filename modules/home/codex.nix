{ inputs, pkgs, ... }:

{
  programs.codex = {
    enable = true;
    package = inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
