# sway/lock-idle.nix - Screen locking and automated idle detection logic
{ pkgs, ... }:
{
  # Cryptographic-style screen locker utilizing Wayland's ext-session-lock
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      font = "JetBrainsMono Nerd Font";
      indicator-radius = 100;
      indicator-thickness = 10;
      # Generates a real-time blur array of the current viewport
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

  # Idle management daemon
  services.swayidle = {
    enable = true;
    events = {
      "before-sleep" = "${pkgs.swaylock-effects}/bin/swaylock -f";
    };
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
      {
        timeout = 360;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
    ];
  };
}
