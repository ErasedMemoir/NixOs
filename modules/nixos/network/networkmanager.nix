{
  networking.networkmanager.enable = true;

  systemd.services.NetworkManager-wait-online.enable = false;

  preservation.preserveAt."/data".directories = [
    "/etc/NetworkManager/system-connections"

    "/var/lib/NetworkManager"
  ];
}
