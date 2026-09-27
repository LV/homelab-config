{
  description = "NixOS server infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./common/configuration.nix
        ./hosts/homelab
      ];
    };
  };
}
