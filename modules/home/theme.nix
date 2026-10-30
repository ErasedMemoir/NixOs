{ pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 32;

    gtk.enable = true;
    x11.enable = true;
    sway.enable = true;
  };

  # Qt applications follow the GTK theme.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # Dark variant for GTK4/libadwaita apps, portals and Firefox.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };
}
