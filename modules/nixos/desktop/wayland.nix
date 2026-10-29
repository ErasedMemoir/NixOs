# desktop/wayland.nix - Wayland init, auth, audio, TUI display manager
{ pkgs, ... }:
{
  # Enforce native Wayland
  environment.variables.NIXOS_OZONE_WL = "1";

  # Security shit
  security = {
    pam.services.greetd.enableGnomeKeyring = true;
    pam.services.swaylock = {};
    polkit.enable = true;
  };

  # Required for Wayland Screen Sharing
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  services = {
    # More security shit
    gnome.gnome-keyring.enable = true;

    # Sound Shit
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Secure Minimalist Terminal UI Login Manager
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };
}
