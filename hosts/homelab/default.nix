_:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/caddy.nix
    ../../modules/system/forgejo.nix
    ../../modules/system/hetzner-ddns.nix
    ../../modules/system/lid.nix
    ../../modules/system/ntfy.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    configurationLimit = 10;
  };

  networking.hostName = "homelab";
  networking.hosts."127.0.0.1" = [
    "git.luis.vi"
    "ntfy.luis.vi"
  ];

  time.timeZone = "America/New_York";

  # Set to the FIRST NixOS release installed on this machine. Never change it.
  system.stateVersion = "26.05";
}
