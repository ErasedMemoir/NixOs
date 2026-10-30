# SSH client.
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    settings = {
      "remarkable" = {
        Hostname = "192.168.1.72";
        User = "root";
        IdentityFile = "~/.ssh/remarkable_key";
      };
    };
  };
}
