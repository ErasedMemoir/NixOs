# Warmer screen. The settings panel stores a strength from 0 to 99, or 100
# to follow the sun.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  start = pkgs.writeShellScript "night-light" ''
    wlsunset=(${lib.getExe pkgs.wlsunset} -l 43.6 -L 13.5)
    level=$(cat "${config.xdg.stateHome}/night-light" 2>/dev/null || true)

    if [[ $level =~ ^[0-9]+$ ]] && ((level < 100)); then
      # Same temperature day and night: the high one must be higher.
      temp=$((6500 - level * 45))
      exec "''${wlsunset[@]}" -T $((temp + 1)) -t "$temp"
    fi
    exec "''${wlsunset[@]}" -T 6500 -t 2500
  '';
in
{
  systemd.user.services.night-light = {
    Unit = {
      Description = "Night light";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      # The settings panel restarts it to apply a new strength.
      StartLimitIntervalSec = 0;
    };
    Service = {
      ExecStart = "${start}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
