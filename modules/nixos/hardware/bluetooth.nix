# Bluetooth off. To enable it, remove this file and the override in
# facter.nix, and persist /var/lib/bluetooth.
{
  hardware.bluetooth.enable = false;

  boot.blacklistedKernelModules = [ "btusb" ];
}
