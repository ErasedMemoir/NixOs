# Screenshots, bound in sway.nix.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    grim
    slurp
  ];

  programs.swappy = {
    enable = true;
    settings.default = {
      save_dir = "~/Pictures/Screenshots";
      save_filename_format = "screenshot_%Y%m%d_%H%M%S.png";
      show_panel = false;
    };
  };
}
