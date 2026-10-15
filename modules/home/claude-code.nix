{ inputs, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      tui = "fullscreen";
      theme = "dark";
      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };
    };
  };
  # The binary lives in the read-only Nix store; updates come from `nix flake update`.
  home.sessionVariables.DISABLE_AUTOUPDATER = "1";
}
