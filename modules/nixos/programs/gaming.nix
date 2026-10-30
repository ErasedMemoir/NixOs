# Steam, Proton-GE and GameMode.
{ pkgs, ... }:
{
  boot = {
    # Used by Proton when available, not loaded on demand.
    kernelModules = [ "ntsync" ];

    # Some Windows games use split locks; the default penalty slows them down.
    kernel.sysctl."kernel.split_lock_mitigate" = 0;
  };

  programs = {
    steam = {
      enable = true;
      # unstable follows new GE releases, stable does not.
      extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
    };

    gamemode.enable = true;
  };
}
