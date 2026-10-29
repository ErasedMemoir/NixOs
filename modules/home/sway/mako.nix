# sway/mako.nix - Minimalist, stateless notification daemon
{
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      padding = "15";
      margin = "10";
      default-timeout = 5000;
      background-color = "#000000";
      text-color = "#ffffff";
      border-color = "#888888";
      border-size = 2;
      border-radius = 5;
    };
  };
}
