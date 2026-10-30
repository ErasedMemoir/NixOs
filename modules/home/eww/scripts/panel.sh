# Open one panel, or close it if already open. Only one panel is shown.
panels=(network info settings audio)
target=$1

# Never let a click start a second daemon.
eww ping >/dev/null 2>&1 || exit 0

# One click at a time; the lock is not inherited by eww itself.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/eww-panel.lock"
flock -w 2 9 || exit 0
run() { timeout 2 eww "$@" 9>&-; }

# Distance from the right screen edge to the panel, so that the panel is
# centered under its button. Without a battery the buttons move right.
x() {
  local center width=320
  case $1 in
    network) center=366 ;;
    info) center=301 ;;
    settings) center=237 ;;
    audio) center=150 width=200 ;;
  esac
  run get battery | jq -e .present >/dev/null || center=$((center - 101))
  echo "$((center - width / 2 < 8 ? 8 : center - width / 2))px"
}

open=$(run active-windows)

for panel in "${panels[@]}"; do
  if grep -q ": $panel$" <<<"$open"; then
    run update "reveal_$panel=false"
    run close "$panel"
  fi
done

if ! grep -q ": $target$" <<<"$open"; then
  run update "reveal_$target=true"
  run open "$target" --arg "x=$(x "$target")"
  case $target in
    network | settings) run update "$target=$("eww-$target")" ;;
  esac
fi
