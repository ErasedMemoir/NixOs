# Firmware and fwupd.
{
  hardware.enableAllFirmware = true;

  services.fwupd.enable = true;

  preservation.preserveAt."/data".directories = [ "/var/lib/fwupd" ];
}
