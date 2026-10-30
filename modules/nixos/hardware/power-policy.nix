# Selects the power profile from the power-supply state:
#
#   no battery or on AC      performance
#   battery 61-100 %         performance
#   battery 21-60 %          balanced
#   battery 0-20 %           power-saver
#
# Wi-Fi power saving is off in performance and on otherwise. Writing
# performance, balanced or power-saver to /run/power-profile-policy/mode
# overrides the rule until reboot; auto or no file restores it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.power-profile-policy;

  policy = pkgs.writeShellApplication {
    name = "power-profile-policy";
    runtimeInputs = [
      config.systemd.package
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.iw
      pkgs.inotify-tools
    ];
    text = ''
      performance_threshold=${toString cfg.performanceThreshold}
      power_saver_threshold=${toString cfg.powerSaverThreshold}
      interval=${toString cfg.interval}
      manage_wifi=${lib.boolToString cfg.wifiPowerSave}
      mode_file=/run/power-profile-policy/mode

      # power-profiles-daemon over D-Bus; powerprofilesctl is much slower.
      ppd() {
        busctl --system "$1" org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles \
          org.freedesktop.UPower.PowerProfiles "''${@:2}"
      }

      select_profile() {
        local supply battery="" external=false capacity mode=auto

        [[ -r $mode_file ]] && mode=$(<"$mode_file")
        case $mode in
          performance | balanced | power-saver)
            echo "$mode"
            return
            ;;
        esac

        for supply in /sys/class/power_supply/*; do
          # Skip mouse/headset batteries.
          [[ $(cat "$supply/scope" 2>/dev/null) == Device ]] && continue

          if [[ $(<"$supply/type") == Battery ]]; then
            [[ -z $battery ]] && battery=$supply
          elif [[ $(cat "$supply/online" 2>/dev/null) == 1 ]]; then
            external=true
          fi
        done

        if [[ -z $battery ]]; then
          echo performance
          return
        fi

        [[ $(<"$battery/status") == Discharging ]] || external=true
        capacity=$(<"$battery/capacity")

        if $external || ((capacity > performance_threshold)); then
          echo performance
        elif ((capacity > power_saver_threshold)); then
          echo balanced
        else
          echo power-saver
        fi
      }

      apply() {
        local target
        target=$(select_profile)

        if ! ppd get-property Profiles | grep -F "\"Profile\" s \"$target\"" >/dev/null; then
          target=balanced
        fi

        if [[ $(ppd get-property ActiveProfile) != "s \"$target\"" ]]; then
          echo "Switching power profile to $target"
          ppd set-property ActiveProfile s "$target"
        fi

        if $manage_wifi; then
          apply_wifi "$target"
        fi
      }

      # Re-applied every time, NetworkManager may reset it on reconnect.
      apply_wifi() {
        local state=on iface
        [[ $1 == performance ]] && state=off

        for iface in /sys/class/net/*; do
          [[ -d $iface/wireless ]] || continue
          iface=''${iface##*/}
          if ! iw dev "$iface" get power_save | grep -q ": $state$"; then
            echo "Setting Wi-Fi power saving on $iface to $state"
            iw dev "$iface" set power_save "$state"
          fi
        done
      }

      apply

      # Wake up on power-supply events, mode changes, or every $interval seconds.
      while true; do
        status=0
        read -r -t "$interval" _ <&3 || status=$?
        if ((status != 0 && status <= 128)); then
          exit 1
        fi
        apply
      done 3< <(
        udevadm monitor --udev --subsystem-match=power_supply &
        inotifywait -q -m -e close_write,moved_to,delete "''${mode_file%/*}"
      )
    '';
  };
in
{
  options.services.power-profile-policy = {
    enable = lib.mkEnableOption "battery-aware power profile selection" // {
      default = config.services.power-profiles-daemon.enable;
      defaultText = lib.literalExpression "config.services.power-profiles-daemon.enable";
    };

    performanceThreshold = lib.mkOption {
      type = lib.types.ints.between 0 100;
      default = 60;
      description = "Battery percentage above which the performance profile is used on battery.";
    };

    powerSaverThreshold = lib.mkOption {
      type = lib.types.ints.between 0 100;
      default = 20;
      description = "Battery percentage at or below which the power-saver profile is used on battery.";
    };

    wifiPowerSave = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to turn Wi-Fi power saving off in the performance profile and on otherwise.";
    };

    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60;
      description = "Seconds between evaluations when no power-supply event occurs.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.power-profiles-daemon.enable;
        message = "services.power-profile-policy requires services.power-profiles-daemon.";
      }
      {
        assertion = cfg.powerSaverThreshold <= cfg.performanceThreshold;
        message = "services.power-profile-policy: powerSaverThreshold must not exceed performanceThreshold.";
      }
    ];

    # Writable by users so the desktop can switch modes.
    systemd.tmpfiles.rules = [ "d /run/power-profile-policy 0775 root users -" ];

    systemd.services.power-profile-policy = {
      description = "Battery-aware power profile selection";
      # power-profiles-daemon is ordered after multi-user.target.
      wantedBy = [ "graphical.target" ];
      wants = [ "power-profiles-daemon.service" ];
      after = [ "power-profiles-daemon.service" ];

      serviceConfig = {
        ExecStart = lib.getExe policy;
        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_NETLINK"
        ];
      };
    };
  };
}
