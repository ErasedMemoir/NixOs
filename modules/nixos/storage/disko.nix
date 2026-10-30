# Disk layout. Running disko with it (install.sh) erases the target disk.
# /dev/diskoTarget is a symlink created by install.sh; at runtime partitions
# are mounted by label.
{ inputs, ... }:
let
  mountOptions = [
    "compress=zstd"
    "noatime"
  ];
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices.disk.main = {
    device = "/dev/diskoTarget";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "4096M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        system.content = {
          type = "btrfs";
          subvolumes = {
            "root" = {
              mountpoint = "/";
              inherit mountOptions;
            };
            "nix" = {
              mountpoint = "/nix";
              inherit mountOptions;
            };
            "data" = {
              mountpoint = "/data";
              inherit mountOptions;
              swap.swapfile.size = "16G";
            };
            "home" = {
              mountpoint = "/home";
              inherit mountOptions;
            };
          };
        };
      };
    };
  };

  services.btrfs.autoScrub.enable = true;
}
