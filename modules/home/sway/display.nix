# Use the highest resolution and refresh rate of every monitor. The mode a
# monitor reports as preferred is often 60 Hz even on high refresh panels.
{ pkgs, ... }:
let
  bestMode = pkgs.writeShellApplication {
    name = "sway-best-mode";
    runtimeInputs = with pkgs; [
      sway
      jq
    ];
    text = ''
      apply() {
        swaymsg -t get_outputs -r | jq -r '
          .[] | select(.active)
          | (.modes | max_by([.width * .height, .refresh])) as $best
          | select([$best.width, $best.height, $best.refresh]
              != [.current_mode.width, .current_mode.height, .current_mode.refresh])
          | "output \(.name | @json) mode \($best.width)x\($best.height)@\($best.refresh / 1000)Hz"
        ' | while read -r command; do swaymsg "$command" >/dev/null; done
      }

      # Again whenever a monitor is connected.
      apply
      swaymsg -t subscribe -m '["output"]' | while read -r _; do apply; done
    '';
  };
in
{
  wayland.windowManager.sway.config.startup = [ { command = "${bestMode}/bin/sway-best-mode"; } ];
}
