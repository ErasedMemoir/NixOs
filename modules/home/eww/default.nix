# Status bar, panels and volume/brightness indicator.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  script =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      name = "eww-${name}";
      inherit runtimeInputs;
      text = builtins.readFile ./scripts/${name}.sh;
    };

  scripts = pkgs.symlinkJoin {
    name = "eww-scripts";
    paths = with pkgs; [
      (script "workspaces" [
        sway
        jq
      ])
      (script "window-title" [
        sway
        jq
      ])
      (script "volume" [
        wireplumber
        pulseaudio
        gawk
        gnugrep
      ])
      (script "network" [
        networkmanager
        iproute2
        cloudflare-warp
        gawk
        gnugrep
        jq
      ])
      (script "warp-toggle" [
        cloudflare-warp
        coreutils
        eww
      ])
      (script "sysinfo" [
        coreutils
        jq
      ])
      (script "battery" [
        coreutils
        jq
      ])
      (script "settings" [
        systemd
        coreutils
        mako
        gnugrep
        jq
      ])
      (script "set" [
        systemd
        mako
        coreutils
        eww
        jq
      ])
      (script "panel" [
        eww
        jq
        gnugrep
        util-linux
        coreutils
      ])
      (script "osd" [
        eww
        wireplumber
        brightnessctl
        coreutils
        gawk
        gnugrep
      ])
    ];
  };
in
{
  home.packages = [ scripts ];

  programs.eww = {
    enable = true;
    yuckConfig = builtins.readFile ./eww.yuck;
    scssConfig = builtins.readFile ./eww.scss;
    systemd.enable = true;
  };

  # Restart on switch when the config or a script changes.
  systemd.user.services.eww.Unit.X-Restart-Triggers = [
    config.xdg.configFile."eww/eww.yuck".source
    config.xdg.configFile."eww/eww.scss".source
    scripts
  ];

  systemd.user.services.eww.Service = {
    ExecStartPost = "${pkgs.writeShellScript "eww-open-bar" ''
      until ${lib.getExe pkgs.eww} ping >/dev/null 2>&1; do sleep 0.1; done
      ${lib.getExe pkgs.eww} open bar
    ''}";
  };
}
