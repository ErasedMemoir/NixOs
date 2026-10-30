# Features Facter would enable but that are handled elsewhere.
{
  hardware.facter.detected = {
    # NetworkManager handles DHCP.
    dhcp.enable = false;

    bluetooth.enable = false;

    # The GPU driver is loaded after the root mount, in parallel with the rest
    # of the boot. In the initrd it delays the boot by about a second.
    boot.graphics.kernelModules = [ ];
  };
}
