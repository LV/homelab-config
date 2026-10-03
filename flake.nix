{
  description = "NixOS server infrastructure";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    pi = {
      url = "github:earendil-works/pi/stable";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-darwin-x64.follows = "nixpkgs";
    };
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

      formatter.${system} = pkgs.nixfmt-tree.override {
        settings.formatter.nixfmt.options = [ "--strict" ];
      };
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
