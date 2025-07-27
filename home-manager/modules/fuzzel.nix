{ ... }:

let
  colorscheme = import ../../../lib/colorscheme.nix;
  # Helper to add alpha to hex color (e.g. "#3b224c" + "dd" -> "3b224cdd")
  hexNoHash = hex: builtins.replaceStrings ["#"] [""] hex;
  withAlpha = hex: alpha: hexNoHash hex + alpha;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font Mono";
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
        background = withAlpha colorscheme.background "dd";
        input = withAlpha colorscheme.foreground "ff";
        counter = withAlpha colorscheme.foreground "ff";
        text = withAlpha colorscheme.selection_background "ee";
        placeholder = withAlpha colorscheme.background "ff";
        selection = withAlpha colorscheme.selection_background "ee";
        selection-text = withAlpha colorscheme.background "ff";
        match = withAlpha colorscheme.color1 "ff";
      };
      border = {
        width = 0;
        radius = 0;
      };
    };
  };
}
