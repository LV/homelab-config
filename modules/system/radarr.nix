{ lib, ... }:

{
  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.radarr.extraGroups = [ "media" ];
  systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";
}
