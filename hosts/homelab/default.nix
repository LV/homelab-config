{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/caddy.nix
    ../../modules/system/forgejo.nix
    ../../modules/system/hetzner-ddns.nix
    ../../modules/system/lid.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
  };

  networking.hostName = "homelab";

  time.timeZone = "America/New_York";

  # Set to the FIRST NixOS release installed on this machine. Never change it.
  system.stateVersion = "26.05";
}
