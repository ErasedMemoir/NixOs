{ config, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    
    # reMarkable connection configuration
    settings = {
      "remarkable" = {
        Hostname = "192.168.1.72";
        User = "root";
        IdentityFile = "~/.ssh/remarkable_key";
      };
    };
  };
}
