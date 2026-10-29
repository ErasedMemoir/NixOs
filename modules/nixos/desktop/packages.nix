# desktop/packages.nix - System-wide packages and compat layers
{ pkgs, ... }:
{
  services = {
    # Network Overlays
    cloudflare-warp.enable = true;

    power-profiles-daemon.enable = true;

    # Kernel Scheduling & Auto-tuning
    bpftune.enable = true;
    gvfs.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };

  programs = {
    nix-index-database.comma.enable = true;
    gamemode.enable = true;
    nix-ld.enable = true;
    dconf.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
    };
  };

  environment.systemPackages = with pkgs; [ sbctl ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
