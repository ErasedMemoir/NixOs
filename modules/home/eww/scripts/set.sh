# Change a setting from the settings panel. The panel is updated first, the
# change is applied right after.
eww ping >/dev/null 2>&1 || exit 0

# Show a new value in the panel at once.
show() {
  timeout 2 eww update "settings=$(timeout 2 eww get settings | jq -c "$@")"
}

case $1 in
  power)
    # shellcheck disable=SC2016
    show --arg mode "$2" '.mode = $mode'
    echo "$2" >/run/power-profile-policy/mode
    ;;
  night-light)
    if systemctl --user is-active -q night-light.service; then
      show '.night_light = false'
      systemctl --user stop night-light.service
    else
      show '.night_light = true'
      systemctl --user start night-light.service
    fi
    ;;
  night-level)
    [[ $2 =~ ^[0-9]+$ ]] && (($2 <= 100)) || exit 1
    timeout 2 eww update "night_level_live=$2"
    state=${XDG_STATE_HOME:-$HOME/.local/state}
    mkdir -p "$state"
    echo "$2" >"$state/night-light"
    # The slider sends many values while dragging; restart only for the last.
    last=${XDG_RUNTIME_DIR:-/tmp}/eww-night-temp
    echo $$ >"$last"
    sleep 0.4
    [[ $(<"$last") == "$$" ]] || exit 0
    systemctl --user try-restart night-light.service
    ;;
  notifications)
    show '.notifications = (.notifications | not)'
    makoctl mode -t do-not-disturb >/dev/null
    ;;
  *)
    exit 1
    ;;
esac

# Read back the real state, e.g. the profile chosen by the power policy.
sleep 0.3
timeout 2 eww update "settings=$(eww-settings)"
