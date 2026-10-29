# sway/waybar.nix - Wayland bar daemon config
{
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 34;
      spacing = 4;
      modules-left = [
        "sway/workspaces"
        "sway/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "network"
        "custom/separator"
        "cpu"
        "custom/separator"
        "memory"
        "custom/separator"
        "temperature"
        "custom/separator"
        "disk"
        "custom/separator"
        "battery"
      ];
      "custom/separator" = {
        format = "·";
        tooltip = false;
      };

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{name}";
      };
      "clock" = {
        format = "{:%H:%M | %a %d %m}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };
      "cpu" = {
        format = "cpu {usage}%";
      };
      "memory" = {
        format = "mem {}%";
      };
      "temperature" = {
        hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
        input-filename = "temp1_input";
        format = "tmp {temperatureC}°C";
      };
      "disk" = {
        format = "dsk {percentage_used}%";
      };
      "battery" = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "bat {capacity}%";
        format-charging = "chr {capacity}%";
        format-plugged = "chr {capacity}%";
      };
      "network" = {
        format-wifi = "wifi {essid}";
        format-ethernet = "lan {ipaddr}";
        format-linked = "lan no ip";
        format-disconnected = "offline";
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 15px;
          min-height: 0;
      }

      window#waybar {
          background: #000000;
          color: #ffffff;
      }

      #workspaces button {
          padding: 0 8px;
          background: transparent;
          color: #ffffff;
          border-bottom: 2px solid transparent;
      }

      #workspaces button.focused {
          background: #333333;
          border-bottom: 2px solid #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #disk,
      #network,
      #window {
          padding: 0 6px;
          color: #ffffff;
      }

      #custom-separator {
          color: #555555;
          padding: 0 4px;
      }

      #window {
          font-weight: bold;
      }

      #battery.warning:not(.charging) {
          background: #888888;
          color: #ffffff;
      }

      #battery.critical:not(.charging) {
          background: #ffffff;
          color: #000000;
      }
    '';
  };
}
