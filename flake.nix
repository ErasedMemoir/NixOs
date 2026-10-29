# ==============================================================================
# ENTRYPOINT: flake.nix
# Description: Defines the core inputs and outputs for the declarative system.
# Ensures absolute reproducibility by locking dependencies to specific commits.
# ==============================================================================
{
  inputs = {
    # Core system repositories
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Utilities and system structure management
    preservation.url = "github:nix-community/preservation";
    import-tree.url = "github:denful/import-tree";

    # User environment manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-compiled database for dynamic execution
    nix-index = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      modules = [ (inputs.import-tree ./modules/nixos) ];
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
    };
  };
}
