# Sway.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.brightnessctl ];

  wayland.windowManager.sway = {
    enable = true;

    wrapperFeatures.gtk = true;

    # greetd starts sway without a login shell.
    extraSessionCommands = ''
      vars="${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      if [ -f "$vars" ]; then . "$vars"; fi
    '';

    config = {
      modifier = "Mod4"; # Super
      terminal = "foot";
      menu = "rofi -show drun";
      defaultWorkspace = "workspace number 1";

      input = {
        "type:keyboard".xkb_layout = "it";
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      output."*".bg = "${./wallpaper.png} fill";

      # The bar is drawn by eww.
      bars = [ ];

      gaps.inner = 6;

      window = {
        border = 2;
        titlebar = false;
      };

      colors = {
        focused = {
          border = "#888888";
          background = "#888888";
          text = "#ffffff";
          indicator = "#888888";
          childBorder = "#888888";
        };
        focusedInactive = {
          border = "#333333";
          background = "#333333";
          text = "#888888";
          indicator = "#333333";
          childBorder = "#333333";
        };
        unfocused = {
          border = "#000000";
          background = "#000000";
          text = "#888888";
          indicator = "#000000";
          childBorder = "#000000";
        };
        urgent = {
          border = "#ffffff";
          background = "#ffffff";
          text = "#000000";
          indicator = "#ffffff";
          childBorder = "#ffffff";
        };
      };

      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${mod}+Shift+r" = "reload";
          "${mod}+Escape" = "exec loginctl lock-session";

          "${mod}+Shift+e" = "exec ${pkgs.writeShellScript "powermenu" ''
            chosen=$(echo -e "Logout\nReboot\nShutdown" | rofi -dmenu -i -theme-str 'listview {lines: 3; require-input: false;} inputbar { enabled: false; }')
            case "$chosen" in
              "Logout") swaymsg exit ;;
              "Reboot") systemctl reboot ;;
              "Shutdown") systemctl poweroff ;;
            esac
          ''}";

          # Mod+f, Mod+b and Mod+v launch applications.
          "${mod}+Shift+f" = "fullscreen toggle";
          "${mod}+Shift+b" = "splith";
          "${mod}+Shift+v" = "splitv";
          "${mod}+b" = "exec firefox";
          "${mod}+c" = "exec discord";
          "${mod}+f" = "exec thunar";

          "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && eww-osd volume";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && eww-osd volume";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && eww-osd volume";
          "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && eww-osd mic";
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioPause" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
          "XF86MonBrightnessUp" = "exec brightnessctl set 5%+ && eww-osd brightness";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%- && eww-osd brightness";

          "${mod}+v" = "exec cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy";
          "${mod}+Shift+s" = ''exec grim -g "$(slurp)" - | wl-copy -t image/png'';
          "Print" = ''exec grim -g "$(slurp)" - | swappy -f -'';
        };
    };
  };
}
