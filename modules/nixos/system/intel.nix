{ pkgs, ... }:
{
  services.thermald.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      libvdpau-va-gl
      vpl-gpu-rt
    ];
  };
}
