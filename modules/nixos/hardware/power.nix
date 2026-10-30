# Power profiles and CPU scheduling. The profile is set by power-policy.nix.
{
  services = {
    power-profiles-daemon.enable = true;

    upower.enable = true;

    # --autopower follows the active power profile.
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [ "--autopower" ];
    };

    bpftune.enable = true;
  };

  preservation.preserveAt."/data".directories = [
    "/var/lib/power-profiles-daemon"
    "/var/lib/upower"
  ];
}
