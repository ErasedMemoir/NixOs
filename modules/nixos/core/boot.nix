# Bootloader, Secure Boot and kernel.
{ lib, pkgs, ... }:
{
  boot = {
    loader = {
      timeout = 1;
      efi.canTouchEfiVariables = true;

      limine = {
        enable = true;
        style.wallpapers = [ ];

        # Keys are created and enrolled on first install (firmware in Setup
        # Mode), together with the Microsoft keys.
        secureBoot = {
          enable = true;
          autoGenerateKeys = true;
          autoEnrollKeys.enable = true;
        };
      };
    };

    # mkDefault: hardware/nvidia.nix switches to LTS.
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    kernelParams = [ "preempt=full" ];

    zswap.enable = true;

    # No swap readahead, pages mostly come from zswap.
    kernel.sysctl."vm.page-cluster" = 0;
  };

  environment.systemPackages = [ pkgs.sbctl ];

  preservation.preserveAt."/data".directories = [ "/var/lib/sbctl" ];
}
