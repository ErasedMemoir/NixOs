# Recreates an empty root subvolume on every boot.
# Partition label and subvolume name must match disko.nix.
{ pkgs, ... }:
{
  boot.initrd.systemd.services.reset-root = {
    requiredBy = [ "initrd.target" ];

    after = [
      "systemd-hibernate-resume.service"
      "initrd-root-device.target"
    ];
    before = [ "sysroot.mount" ];

    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";

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
