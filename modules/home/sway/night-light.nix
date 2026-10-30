# Warmer screen at night. The strength is set from the eww settings panel.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  start = pkgs.writeShellScript "night-light" ''
    temp=$(cat "${config.xdg.stateHome}/night-light" 2>/dev/null || true)
    [[ $temp =~ ^[0-9]+$ ]] || temp=4500
    exec ${lib.getExe pkgs.wlsunset} -l 43.6 -L 13.5 -T 6500 -t "$temp"
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
