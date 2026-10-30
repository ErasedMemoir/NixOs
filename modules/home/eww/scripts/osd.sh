# Show the volume, microphone or brightness level for a moment.
eww ping >/dev/null 2>&1 || exit 0

case $1 in
  volume)
    read -r level muted < <(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ print int($2 * 100 + 0.5), ($3 == "[MUTED]") }')
    label=vol
    [[ $muted == 1 ]] && label=muted
    ;;
  mic)
    read -r level muted < <(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{ print int($2 * 100 + 0.5), ($3 == "[MUTED]") }')
    label=mic
    [[ $muted == 1 ]] && label="mic off"
    ;;
  brightness)
    level=$(brightnessctl -m | cut -d, -f4 | tr -d %)
    label=bri
    ;;
  *)
    exit 1
    ;;
esac

timeout 2 eww update "osd_label=$label" "osd_value=$level"
timeout 2 eww active-windows | grep -q ': osd$' || timeout 2 eww open --duration 1500ms osd
