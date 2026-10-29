# sway/rofi.nix
{ config, ... }:

let
  mkLiteral = config.lib.formats.rasi.mkLiteral;
in
{
  programs.rofi = {
    enable = true;

    extraConfig = {
      modi = "drun";
      show-icons = false;
      display-drun = "> ";
      drun-display-format = "{name}";
      disable-history = true;
      sort = true;
      drun-match-fields = "name";
    };

    theme = {
      "*" = {
        background-color = mkLiteral "#000000";
        text-color = mkLiteral "#ffffff";
        border-color = mkLiteral "#888888";
        font = "JetBrainsMono Nerd Font 13";
      };

      window = {
        width = mkLiteral "400px";
        border = mkLiteral "2px";
        padding = mkLiteral "15px";
      };

      mainbox = {
        children = map mkLiteral [
          "inputbar"
          "listview"
        ];
      };

      inputbar = {
        padding = mkLiteral "0 0 10px 0";
        children = map mkLiteral [
          "prompt"
          "entry"
        ];
      };

      prompt.text-color = mkLiteral "#ffffff";

      entry.text-color = mkLiteral "#ffffff";

      listview = {
        lines = 5;
        scrollbar = false;
        border = 0;
        require-input = true;
      };

      element.padding = mkLiteral "5px";

      "element selected" = {
        background-color = mkLiteral "#333333";
        text-color = mkLiteral "#ffffff";
      };
    };
  };
}
