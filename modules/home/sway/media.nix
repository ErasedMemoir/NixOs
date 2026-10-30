# Media keys control the last active player.
{ pkgs, ... }:
{
  home.packages = [ pkgs.playerctl ];

  services.playerctld.enable = true;
}
