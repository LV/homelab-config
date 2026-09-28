{
  description = "NixOS server infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./common/configuration.nix
          ./hosts/homelab
        ];
      };

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt
          statix
          deadnix
          nil
        ];
      };
    };
}
