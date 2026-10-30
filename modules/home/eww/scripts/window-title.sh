print() {
  swaymsg -t get_tree | jq -r '
    [.. | objects | select(.focused? == true and (.type == "con" or .type == "floating_con"))]
    | first | .name // ""'
}

print
swaymsg -t subscribe -m '["window", "workspace"]' | while read -r _; do print; done
