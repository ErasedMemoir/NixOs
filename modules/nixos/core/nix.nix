# Nix, nixpkgs and store maintenance.
{ inputs, ... }:
{
  nix = {
    channel.enable = false;
    settings.experimental-features = "nix-command flakes";

    optimise.automatic = true;
  };

  nixpkgs = {
    config.allowUnfree = true;

    # pkgs.unstable.<name>
    overlays = [
      (final: _: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (final) overlays config;
        };
      })
    ];
  };

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
