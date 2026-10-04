{ inputs, lib, ... }:

let
  userNames = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.)
  );
in
{
  users.users = lib.genAttrs userNames (
    name: _: {
      imports = [ (./. + "/${name}/default.nix") ];
      isNormalUser = true;
    }
  );

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users = lib.genAttrs userNames (name: {
      imports = [ (./. + "/${name}/home.nix") ];
    });
  };
}
