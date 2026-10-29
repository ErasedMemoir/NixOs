# home/packages.nix - User-space applications and command-line utilities
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pkgs.unstable.opencode
    pkgs.unstable.antigravity-cli
    brightnessctl
    wl-clipboard
    pulsemixer
    lunar-client
    thunar
    slurp
    grim
    rar
    android-tools
    file-roller
  ];

  programs = {
    prismlauncher.enable = true;
    fastfetch.enable = true;
    firefox.enable = true;
    discord = {
      enable = true;
      package = pkgs.discord.override {
        commandLineArgs = "--ozone-platform=wayland --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true";
      };
    };
    swappy = {
      enable = true;
      settings = {
        default = {
          save_dir = "~/Pictures/Screenshots";
          save_filename_format = "screenshot_%Y%m%d_%H%M%S.png";
          show_panel = false;
        };
      };
    };
    vscode.enable = true;
    btop.enable = true;
    git.enable = true;
    mpv.enable = true;
    gh.enable = true;
  };

  services.cliphist = {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
  };
}
