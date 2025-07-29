{...}: let
  colorscheme = import ../../lib/colorscheme.nix;
  # Helper to add alpha to hex color (e.g. "#3b224c" + "dd" -> "3b224cdd")
  hexNoHash = hex: builtins.replaceStrings ["#"] [""] hex;
  withAlpha = hex: alpha: hexNoHash hex + alpha;
in {
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
        background = withAlpha colorscheme.ui.background "dd";
        input = withAlpha colorscheme.ui.foreground "ff";
        counter = withAlpha colorscheme.ui.foreground "ff";
        text = withAlpha colorscheme.ui.primary "ee";
        placeholder = withAlpha colorscheme.ui.background "ff";
        selection = withAlpha colorscheme.ui.primary "ee";
        selection-text = withAlpha colorscheme.ui.background "ff";
        match = withAlpha colorscheme.ui.error "ff";
      };
      border = {
        width = 0;
        radius = 0;
      };
    };
  };
}
