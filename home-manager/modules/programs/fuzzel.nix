{ config, pkgs, ... }:

let
  styles = import ./styles.nix;
  # Helper to add alpha to hex color (e.g. "#3b224c" + "dd" -> "3b224cdd")
  hexNoHash = hex: builtins.replaceStrings ["#"] [""] hex;
  withAlpha = hex: alpha: hexNoHash hex + alpha;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = styles.font;
        exit-on-keyboard-focus-loss = "no";
        prompt = "> ";
        line-height = 32;
        inner-pad = 24;
        width = 100;
        lines = 10;
        horizontal-pad = 40;
        vertical-pad = 40;
        match-counter = "yes";
        icon-theme = "Adwaita";
      };
      colors = {
        background = withAlpha styles.background "dd";
        input = withAlpha styles.foreground "ff";
        counter = withAlpha styles.foreground "ff";
        text = withAlpha styles.selection_background "ee";
        placeholder = withAlpha styles.background "ff";
        selection = withAlpha styles.selection_background "ee";
        selection-text = withAlpha styles.background "ff";
        match = withAlpha styles.color1 "ff";
      };
      border = {
        width = 0;
        radius = 0;
      };
    };
  };
}
