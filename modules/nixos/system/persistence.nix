# NOTE: /home is a persistent subvolume and is not
# managed by preservation.
# system/persistence.nix - Impermanence state definitions
{
  preservation = {
    enable = true;
    preserveAt."/data" = {
      commonMountOptions = [
        "x-gvfs-hide"
        "x-gdu.hide"
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];

      directories = [
        {
          directory = "/etc/nixos";
          user = "erased";
        }
        "/var/lib/bluetooth"
        "/etc/NetworkManager"
        "/var/lib/netbird"
        "/var/lib/nixos"
        "/var/lib/sbctl"
        "/var/cache"
        "/var/log"
      ];
    };
  };

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
