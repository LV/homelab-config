{ pkgs, ... }:

{
  imports = [
    ../modules/system/nix-ld.nix
    ../modules/system/notify.nix
    ../modules/system/pi.nix
    ../modules/system/tailscale.nix
    ../modules/system/tmux.nix
  ];

  networking.networkmanager.enable = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise.automatic = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.v = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGsWJgncIoAVKioYVVMfqn7g0mSnpLORTgZg3UNNDxJ" # laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKphnA9IH9KO8cKi7ZzX+zZzb74aU7UrVliw8vq4id6w" # phone
    ];
    packages = with pkgs; [
      git
      delta
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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
