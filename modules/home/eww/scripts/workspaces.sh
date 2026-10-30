print() {
  swaymsg -t get_workspaces | jq -c 'sort_by(.num) | map({num, focused, urgent})'
}

print
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do print; done
