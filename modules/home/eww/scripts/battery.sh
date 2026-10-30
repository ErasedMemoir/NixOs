# System battery, ignoring mouse and headset batteries.
battery=""
for supply in /sys/class/power_supply/*; do
  [[ $(cat "$supply/scope" 2>/dev/null) == Device ]] && continue
  [[ $(<"$supply/type") == Battery ]] && battery=$supply && break
done
capacity="" status="" health=""
if [[ -n $battery ]]; then
  capacity=$(<"$battery/capacity")
  status=$(<"$battery/status")
  if [[ -r $battery/energy_full_design ]]; then
    health=$((100 * $(<"$battery/energy_full") / $(<"$battery/energy_full_design")))
  elif [[ -r $battery/charge_full_design ]]; then
    health=$((100 * $(<"$battery/charge_full") / $(<"$battery/charge_full_design")))
  fi
fi

jq -n -c --arg capacity "$capacity" --arg status "$status" --arg health "$health" \
  '{present: ($capacity != ""), capacity: ($capacity | tonumber? // 0), status: $status, health: $health}'
