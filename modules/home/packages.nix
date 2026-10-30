# Packages without a Home Manager module.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Development
    unstable.antigravity-cli
    android-tools

    # Desktop utilities
    pulsemixer
    file-roller
    rar

    # Games
    lunar-client
  ];
}
