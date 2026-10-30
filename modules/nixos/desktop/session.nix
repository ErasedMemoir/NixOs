# Login manager and session environment. Sway is configured in modules/home.
{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  environment.variables.NIXOS_OZONE_WL = "1";

  programs.dconf.enable = true;
}
