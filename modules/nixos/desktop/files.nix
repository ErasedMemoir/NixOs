# File manager.
{ pkgs, ... }:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin # Extract and create archives (via file-roller)
      thunar-volman # Automatic handling of removable media
    ];
  };

  services = {
    gvfs.enable = true;

    tumbler.enable = true;
  };
}
