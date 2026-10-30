{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    # The X11 bell module crashes PipeWire when Xwayland exits.
    extraConfig.pipewire."10-no-x11-bell"."context.properties"."module.x11.bell" = false;
  };

  security.rtkit.enable = true;

  # Restore the mixer at boot, otherwise the mute LEDs stay on until login.
  hardware.alsa.enablePersistence = true;
  preservation.preserveAt."/data".directories = [ "/var/lib/alsa" ];
}
