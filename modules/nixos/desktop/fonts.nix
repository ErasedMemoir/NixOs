{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;

    packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  };
}
