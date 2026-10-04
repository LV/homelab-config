{ inputs, pkgs, ... }:

{ home.packages = [ inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.default ]; }
