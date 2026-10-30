connection=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active |
  grep -E ':(802-11-wireless|802-3-ethernet):' | head -n 1 || true)
IFS=: read -r name type device <<<"$connection"
signal=$(nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no 2>/dev/null | awk -F: '$1 == "*" { print $2; exit }' || true)
local_ip=""
[[ -n ${device:-} ]] && local_ip=$(ip -4 -o addr show dev "$device" scope global | awk '{ split($4, a, "/"); print a[1]; exit }')

case $(warp-cli --accept-tos status 2>/dev/null || true) in
  *"Status update: Connected"*) warp="connected" ;;
  *"Status update: Connecting"*) warp="connecting" ;;
  *"Status update: Disconnected"*) warp="disconnected" ;;
  *"Registration Missing"*) warp="not registered" ;;
  *) warp="unavailable" ;;
esac

jq -n -c \
  --arg name "${name:-}" --arg type "${type:-}" --arg signal "$signal" --arg local_ip "$local_ip" \
  --arg warp "$warp" \
  '{
    name: $name,
    kind: (if $type == "802-11-wireless" then "wifi" elif $type == "802-3-ethernet" then "ethernet" else "" end),
    signal: $signal,
    local_ip: $local_ip,
    warp: $warp
  }'
