{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/hetzner-ddns.nix
    ../../modules/system/lid.nix
  ];
}
