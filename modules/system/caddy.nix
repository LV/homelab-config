{ ... }:

{
  services.caddy = {
    enable = true;
    email = "v@luis.vi"; # Let's Encrypt sends certificate expiry notices here
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
