# NVIDIA driver, enabled when the Facter report has an NVIDIA GPU.
# Pre-Turing GPUs need `hardware.nvidia.open = false` and a legacy driver,
# hybrid laptops need `hardware.nvidia.prime`, both set in the host file.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasNvidiaGpu = lib.any (gpu: (gpu.vendor.hex or "") == "10de") (
    config.hardware.facter.report.hardware.graphics_card or [ ]
  );
in
lib.mkIf hasNvidiaGpu {
  # The driver does not always build against the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages;

  # Also required on Wayland.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = lib.mkDefault true;

    modesetting.enable = true;
  };

  home-manager.sharedModules = [
    { wayland.windowManager.sway.extraOptions = [ "--unsupported-gpu" ]; }
  ];
}
