# Screen locking and idle handling.
{ config, pkgs, ... }:
let
  lock = "${config.programs.swaylock.package}/bin/swaylock -f";
in
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      font = "JetBrainsMono Nerd Font";
      indicator-radius = 100;
      indicator-thickness = 10;
      screenshots = true;
      effect-blur = "7x5";
      effect-vignette = "0.5:0.5";
      color = "000000";
      inside-color = "000000";
      inside-clear-color = "000000";
      inside-ver-color = "000000";
      inside-wrong-color = "000000";
      ring-color = "888888";
      ring-clear-color = "888888";
      ring-ver-color = "aaaaaa";
      ring-wrong-color = "888888";
      line-color = "000000";
      line-clear-color = "000000";
      line-ver-color = "000000";
      line-wrong-color = "000000";
      text-color = "ffffff";
      text-clear-color = "ffffff";
      text-ver-color = "ffffff";
      text-wrong-color = "ffffff";
    };
  };

  services.swayidle = {
    enable = true;
    events = {
      before-sleep = lock;
      lock = lock;
    };
    timeouts = [
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 360;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
    ];
  };
}
