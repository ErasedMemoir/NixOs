# Home Manager as a NixOS module.
{ inputs, config, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    backupFileExtension = "hmBackup";
    overwriteBackup = true;

    extraSpecialArgs = { inherit inputs; };

    sharedModules = [ { home.stateVersion = config.system.stateVersion; } ];

    users.erased.imports = [ (inputs.import-tree "${inputs.self}/modules/home") ];
  };
}
