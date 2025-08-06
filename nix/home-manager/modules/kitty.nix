{pkgs, ...}: let
  colors = import ../../lib/themes;
  fonts = import ../../lib/fonts.nix pkgs;
in {
  programs.kitty = {
    enable = true;
    font.name = fonts.mono.name;
    font.size = fonts.mono.size.normal;
    font.package = fonts.mono.package;
    settings = {
      window_padding_width = 5;
      foreground = colors.ui.foreground.primary;
      background = colors.ui.background.primary;
      selection_foreground = colors.ui.foreground.inverse;
      selection_background = colors.ui.special.selection;

      cursor = colors.ui.foreground.primary;
      cursor_text_color = colors.ui.background.primary;

      url_color = colors.ui.interactive.primary;

      active_border_color = colors.ui.border.focus;
      inactive_border_color = colors.ui.border.secondary;
      bell_border_color = colors.ui.interactive.accent;

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      active_tab_foreground = colors.ui.background.primary;
      active_tab_background = colors.ui.interactive.primary;
      inactive_tab_foreground = colors.ui.foreground.secondary;
      inactive_tab_background = colors.ui.background.secondary;
      tab_bar_background = colors.ui.background.primary;

      mark1_foreground = colors.ui.background.primary;
      mark1_background = colors.ui.interactive.primary;
      mark2_foreground = colors.ui.background.primary;
      mark2_background = colors.ui.foreground.secondary;
      mark3_foreground = colors.ui.background.primary;
      mark3_background = colors.ui.interactive.secondary;

      color0 = colors.terminal.black;
      color1 = colors.terminal.red;
      color2 = colors.terminal.green;
      color3 = colors.terminal.yellow;
      color4 = colors.terminal.blue;
      color5 = colors.terminal.magenta;
      color6 = colors.terminal.cyan;
      color7 = colors.terminal.white;
      color8 = colors.terminal.brightBlack;
      color9 = colors.terminal.brightRed;
      color10 = colors.terminal.brightGreen;
      color11 = colors.terminal.brightYellow;
      color12 = colors.terminal.brightBlue;
      color13 = colors.terminal.brightMagenta;
      color14 = colors.terminal.brightCyan;
      color15 = colors.terminal.brightWhite;
    };
  };
}
