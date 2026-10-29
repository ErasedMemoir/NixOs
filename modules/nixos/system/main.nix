# system/main.nix - Main config aggregator, bootstraps HM & Nix daemon
{ inputs, config, ... }:
{
  imports = with inputs; [
    preservation.nixosModules.preservation
    home-manager.nixosModules.home-manager
    nix-index.nixosModules.nix-index
    disko.nixosModules.disko
  ];

  # ----------------------------------------------------------------------------
  # Home Manager Subsystem
  # ----------------------------------------------------------------------------
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    overwriteBackup = true;
    backupFileExtension = "hmBackup";
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ { home.stateVersion = config.system.stateVersion; } ];
    users.erased.imports = [ (inputs.import-tree "${inputs.self}/modules/home") ];
  };

  # ----------------------------------------------------------------------------
  # Nix Daemon Configuration
  # ----------------------------------------------------------------------------
  nix = {
    channel.enable = false;
    optimise.automatic = true;
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs = {
    config.allowUnfree = true;
    # Unstable overlay for newer versions of packages;
    # ex: pkgs.unstable.vim instead of pkgs.vim;
    overlays = [
      (final: _: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (final) overlays config;
        };
      })
    ];
  };

  system.stateVersion = "26.05";
}
