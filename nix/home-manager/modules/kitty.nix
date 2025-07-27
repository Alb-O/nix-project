{pkgs, ...}: let
  colorscheme = import ../../lib/colorscheme.nix;
in {
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Mono";
    font.size = 13;
    font.package = pkgs.nerd-fonts.jetbrains-mono;
    settings = {
      # Basic colors
      foreground = colorscheme.ui.foreground;
      background = colorscheme.ui.background;
      selection_foreground = colorscheme.ui.background;
      selection_background = colorscheme.ui.primary;

      # Cursor colors
      cursor = colorscheme.ui.foreground;
      cursor_text_color = colorscheme.ui.background;

      # URL underline color when hovering with mouse
      url_color = colorscheme.ui.primary;

      # Kitty window border colors
      active_border_color = colorscheme.ui.borderActive;
      inactive_border_color = colorscheme.ui.borderInactive;
      bell_border_color = colorscheme.ui.accent;

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      # Tab bar colors
      active_tab_foreground = colorscheme.ui.background;
      active_tab_background = colorscheme.ui.primary;
      inactive_tab_foreground = colorscheme.ui.primaryVariant;
      inactive_tab_background = colorscheme.ui.surface;
      tab_bar_background = colorscheme.ui.background;

      # Colors for marks (marked text in the terminal)
      mark1_foreground = colorscheme.ui.background;
      mark1_background = colorscheme.ui.primary;
      mark2_foreground = colorscheme.ui.background;
      mark2_background = colorscheme.ui.primaryVariant;
      mark3_foreground = colorscheme.ui.background;
      mark3_background = colorscheme.ui.secondary;

      # The 16 terminal colors
      color0 = colorscheme.terminal.black;
      color1 = colorscheme.terminal.red;
      color2 = colorscheme.terminal.green;
      color3 = colorscheme.terminal.yellow;
      color4 = colorscheme.terminal.blue;
      color5 = colorscheme.terminal.magenta;
      color6 = colorscheme.terminal.cyan;
      color7 = colorscheme.terminal.white;
      color8 = colorscheme.terminal.brightBlack;
      color9 = colorscheme.terminal.brightRed;
      color10 = colorscheme.terminal.brightGreen;
      color11 = colorscheme.terminal.brightYellow;
      color12 = colorscheme.terminal.brightBlue;
      color13 = colorscheme.terminal.brightMagenta;
      color14 = colorscheme.terminal.brightCyan;
      color15 = colorscheme.terminal.brightWhite;
    };
  };
}
