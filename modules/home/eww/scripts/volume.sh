# Output and microphone volume of the default devices.
get() {
  local out
  # Empty while WirePlumber has not picked the default device yet.
  out=$(wpctl get-volume "$1" 2>/dev/null || true)
  awk '{ printf "%d %s\n", $2 * 100 + 0.5, ($3 == "[MUTED]") ? "true" : "false" }' <<<"${out:-Volume: 0}"
}

print() {
  local volume muted mic mic_muted
  read -r volume muted < <(get @DEFAULT_AUDIO_SINK@)
  read -r mic mic_muted < <(get @DEFAULT_AUDIO_SOURCE@)
  printf '{"volume": %d, "muted": %s, "mic": %d, "mic_muted": %s}\n' "$volume" "$muted" "$mic" "$mic_muted"
}

# PipeWire may start after eww or be restarted; keep reconnecting. Without
# its socket pactl would start a PulseAudio daemon of its own.
while true; do
  print
  if [[ -S ${XDG_RUNTIME_DIR:-/run/user/$UID}/pulse/native ]]; then
    pactl subscribe 2>/dev/null | grep --line-buffered -E "'change' on (sink|source|server)" |
      while read -r _; do print; done || true
  fi
  sleep 1
done
