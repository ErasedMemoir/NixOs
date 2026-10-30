# Intel extras, enabled from the Facter report.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hardware.facter) report;

  hasIntelCpu = lib.any (cpu: (cpu.vendor_name or "") == "GenuineIntel") (report.hardware.cpu or [ ]);

  hasIntelGpu = lib.any (gpu: (gpu.vendor.hex or "") == "8086") (
    report.hardware.graphics_card or [ ]
  );
in
lib.mkMerge [
  (lib.mkIf hasIntelCpu {
    services.thermald.enable = true;
  })

  (lib.mkIf hasIntelGpu {
    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD) video decoding and encoding
      vpl-gpu-rt # oneVPL / Quick Sync Video
    ];
  })
]
