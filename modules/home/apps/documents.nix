# PDF, image and office applications.
{ pkgs, ... }:
{
  home.packages = [ pkgs.libreoffice ];

  programs.zathura = {
    enable = true;
    options = {
      font = "JetBrainsMono Nerd Font 11";
      selection-clipboard = "clipboard";
      default-bg = "#000000";
      default-fg = "#ffffff";
      statusbar-bg = "#000000";
      statusbar-fg = "#888888";
      inputbar-bg = "#000000";
      inputbar-fg = "#ffffff";
      recolor = true;
      recolor-lightcolor = "#000000";
      recolor-darkcolor = "#ffffff";
    };
  };

  programs.imv = {
    enable = true;
    settings.options.background = "000000";
  };
}
