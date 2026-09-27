{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/system/tailscale.nix
    ../modules/system/tmux.nix
  ];

  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.v = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      claude-code
      git
      gnumake
      lazygit
      tree
    ];
  };

  environment.shellAliases = {
    gg = "lazygit";
    t = "tmux";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  services.openssh.enable = true;
}
