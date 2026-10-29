{ pkgs, ... }:
{
  # Declarative background daemon for Polkit GUI authentication
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      TimeoutStopSec = 10;
      Type = "simple";
      RestartSec = 1;
    };
  };
}
