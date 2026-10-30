# Running binaries not built for NixOS.
{ inputs, ... }:
{
  imports = [ inputs.nix-index.nixosModules.nix-index ];

  programs = {
    nix-ld.enable = true;

    appimage = {
      enable = true;
      binfmt = true;
    };

    nix-index-database.comma.enable = true;
  };
}
