# The password hash is read from /data/secrets/erased.hash,
# outside this repository.
# system/system.nix - System params, users, networking, kernel
{ pkgs, ... }:
{
  users = {
    mutableUsers = false;
    users.erased = {
      uid = 1000;
      isNormalUser = true;
      description = "Erased";
      extraGroups = [ "wheel" ];
      hashedPasswordFile = "/data/secrets/erased.hash";
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  boot = {
    loader = {
      limine = {
        enable = true;
        style.wallpapers = [ ];
        secureBoot = {
          enable = true;
          autoGenerateKeys = true;
          autoEnrollKeys.enable = true;
        };
      };
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.max_map_count" = 2147483642;
    };
    zswap.enable = true;
    kernelPackages = pkgs.linuxPackages_zen;
  };

  time.timeZone = "Europe/Rome";
  systemd.services.NetworkManager-wait-online.enable = false;
  security.sudo.extraConfig = "Defaults lecture=never,pwfeedback";
}
