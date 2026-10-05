{ inputs, pkgs, ... }:

{
  home.packages = [ inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  # The binary lives in the read-only Nix store; updates come from `nix flake update`.
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";
}
