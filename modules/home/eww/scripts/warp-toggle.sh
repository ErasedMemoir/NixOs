eww ping >/dev/null 2>&1 || exit 0

case $(warp-cli --accept-tos status 2>/dev/null || true) in
  *"Status update: Connected"* | *"Status update: Connecting"*)
    warp-cli --accept-tos disconnect
    ;;
  *"Registration Missing"*)
    warp-cli --accept-tos registration new
    warp-cli --accept-tos connect
    ;;
  *)
    warp-cli --accept-tos connect
    ;;
esac
sleep 1
timeout 2 eww update "network=$(eww-network)"
