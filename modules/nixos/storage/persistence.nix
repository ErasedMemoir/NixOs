# System state kept across reboots. Feature-specific state is declared in
# the module of that feature. /home is a separate subvolume.
{ inputs, ... }:
{
  imports = [ inputs.preservation.nixosModules.preservation ];

  fileSystems."/data".neededForBoot = true;

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

        # Must be a symlink, systemd creates it on first boot.
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];

      directories = [
        {
          directory = "/etc/nixos";
          user = "erased";
        }

        "/var/lib/nixos"
        "/var/lib/systemd/timers"
        "/var/lib/systemd/backlight"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/coredump"

        "/var/cache"
        "/var/log"
      ];
    };
  };

  # machine-id is persisted above.
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}
