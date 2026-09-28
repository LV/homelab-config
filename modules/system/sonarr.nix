{ lib, ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.sonarr.extraGroups = [ "media" ];
  systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";
}
