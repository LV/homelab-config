_:

{
  services.tailscale = {
    enable = true;
    openFirewall = true; # lets devices connect directly instead of through a relay
  };
}
