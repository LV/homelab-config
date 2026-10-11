{ pkgs, ... }:

{
  # Terminfo for terminals I SSH in from, so `TERM` resolves on this host.
  environment.systemPackages = [ pkgs.ghostty.terminfo ];
}
