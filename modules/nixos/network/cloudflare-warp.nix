# Cloudflare WARP, controlled with warp-cli.
{ config, lib, ... }:
{
  services.cloudflare-warp.enable = true;

  # The unit needs /etc/resolv.conf to exist when it starts.
  systemd.services.cloudflare-warp = lib.mkIf config.networking.resolvconf.enable {
    wants = [ "resolvconf.service" ];
    after = [ "resolvconf.service" ];
  };

  preservation.preserveAt."/data".directories = [ config.services.cloudflare-warp.rootDir ];
}
