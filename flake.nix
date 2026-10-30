{
  description = "Modular, impermanent NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Exposed as pkgs.unstable.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    import-tree.url = "github:denful/import-tree";

    preservation.url = "github:nix-community/preservation";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, import-tree, ... }:
    let
      inherit (nixpkgs) lib;

      # One configuration per directory in ./hosts.
      hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts));

      mkHost =
        name:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            (import-tree ./modules/nixos)
            ./hosts/${name}
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hosts mkHost;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
