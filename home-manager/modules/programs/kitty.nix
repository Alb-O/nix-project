{ pkgs, ... }:

let
  colorscheme = import  ../../../lib/colorscheme.nix;

in {
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Mono";
    font.size = 13;
    font.package = pkgs.nerd-fonts.jetbrains-mono;
    settings = {
      # The basic colors
      foreground = colorscheme.foreground;
      background = colorscheme.background;
      selection_foreground = colorscheme.selection_foreground;
      selection_background = colorscheme.selection_background;

      # Cursor colors
      cursor = colorscheme.cursor;
      cursor_text_color = colorscheme.cursor_text_color;

      # URL underline color when hovering with mouse
      url_color = colorscheme.url_color;

      # Kitty window border colors
      active_border_color = colorscheme.active_border_color;
      inactive_border_color = colorscheme.inactive_border_color;
      bell_border_color = colorscheme.bell_border_color;

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      # Tab bar colors
      active_tab_foreground = colorscheme.active_tab_foreground;
      active_tab_background = colorscheme.active_tab_background;
      inactive_tab_foreground = colorscheme.inactive_tab_foreground;
      inactive_tab_background = colorscheme.inactive_tab_background;
      tab_bar_background = colorscheme.tab_bar_background;

      # Colors for marks (marked text in the terminal)
      mark1_foreground = colorscheme.mark1_foreground;
      mark1_background = colorscheme.mark1_background;
      mark2_foreground = colorscheme.mark2_foreground;
      mark2_background = colorscheme.mark2_background;
      mark3_foreground = colorscheme.mark3_foreground;
      mark3_background = colorscheme.mark3_background;

      # The 16 terminal colors
      color0 = colorscheme.color0;
      color1 = colorscheme.color1;
      color2 = colorscheme.color2;
      color3 = colorscheme.color3;
      color4 = colorscheme.color4;
      color5 = colorscheme.color5;
      color6 = colorscheme.color6;
      color7 = colorscheme.color7;
      color8 = colorscheme.color8;
      color9 = colorscheme.color9;
      color10 = colorscheme.color10;
      color11 = colorscheme.color11;
      color12 = colorscheme.color12;
      color13 = colorscheme.color13;
      color14 = colorscheme.color14;
      color15 = colorscheme.color15;
    };
  };
}
