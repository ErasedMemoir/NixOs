# CAUTION: defines disk partitioning; a mistake can
# make the system unbootable.
# system/disk.nix - Disko disk layout and formatting
{ pkgs, ... }:
{
  disko.devices.disk.main = {
    device = "/dev/diskoTarget";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "4096M";
          type = "EF00";
          content = {
            format = "vfat";
            type = "filesystem";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        system.content = {
          type = "btrfs";
          subvolumes = {
            "root" = {
              mountpoint = "/";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "data" = {
              swap.swapfile.size = "16G";
              mountpoint = "/data";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "home" = {
              mountpoint = "/home";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
          };
        };
      };
    };
  };

  fileSystems."/data".neededForBoot = true;
  services.btrfs.autoScrub.enable = true;

  # Ensure the root subvolume is reset on each boot to maintain a clean state
  boot.initrd.systemd.services.reset-root = {
    requiredBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];

    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";

    after = [
      "systemd-hibernate-resume.service"
      "initrd-root-device.target"
    ];

    path = with pkgs; [
      util-linuxMinimal
      btrfs-progs
    ];

    script = ''
      mount -t btrfs /dev/disk/by-partlabel/disk-main-system /tmp
      btrfs subvolume delete --recursive /tmp/root
      btrfs subvolume create /tmp/root
    '';
  };
}
