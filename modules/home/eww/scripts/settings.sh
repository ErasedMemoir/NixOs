mode=auto
[[ -r /run/power-profile-policy/mode ]] && mode=$(</run/power-profile-policy/mode)
profile=$(busctl --system get-property org.freedesktop.UPower.PowerProfiles /org/freedesktop/UPower/PowerProfiles \
  org.freedesktop.UPower.PowerProfiles ActiveProfile 2>/dev/null | cut -d '"' -f 2 || true)
night_light=$(systemctl --user is-active night-light.service || true)
night_level=$(cat "${XDG_STATE_HOME:-$HOME/.local/state}/night-light" 2>/dev/null || true)
[[ $night_level =~ ^[0-9]+$ ]] && ((night_level < 100)) || night_level=100
notifications=on
makoctl mode 2>/dev/null | grep -qx do-not-disturb && notifications=off

jq -n -c --arg mode "$mode" --arg profile "$profile" \
  --arg night_light "$night_light" --arg night_level "$night_level" --arg notifications "$notifications" \
  '{
    mode: $mode,
    profile: $profile,
    night_light: ($night_light == "active"),
    night_level: ($night_level | tonumber),
    notifications: ($notifications == "on")
  }'
