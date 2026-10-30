# Clipboard history.
{ pkgs, ... }:
{
  home.packages = [ pkgs.wl-clipboard ];

  services.cliphist = {
    enable = true;

    extraOptions = [
      "-max-dedupe-search"
      "10"
      "-max-items"
      "10"
    ];
  };
}
