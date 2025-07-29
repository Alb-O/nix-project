let
  # Core palette - define each color once
  palette = {
    # Base colors
    black = "#281733";
    darkPurple = "#3b224c";
    midPurple = "#5a5977";
    lightPurple = "#a4a0e8";
    pink = "#dbbfef";
    white = "#ffffff";

    # Accent colors
    red = "#f47868";
    green = "#9ff28f";
    yellow = "#efba5d";
    brightYellow = "#ffcd1c";
    blue = "#7aa2f7";
    cyan = "#697C81";
    lightGray = "#cccccc";
  };
in {
  # Main palette export
  inherit palette;

  # Semantic color mappings for UI elements
  ui = {
    foreground = palette.white;
    background = palette.darkPurple;
    surface = palette.black;
    surfaceVariant = palette.midPurple;

    primary = palette.pink;
    primaryVariant = palette.lightPurple;
    secondary = palette.blue;
    accent = palette.yellow;

    success = palette.green;
    warning = palette.yellow;
    error = palette.red;
    info = palette.blue;

    border = palette.midPurple;
    borderActive = palette.pink;
    borderInactive = palette.midPurple;
  };

  # Terminal color mappings (ANSI colors)
  terminal = {
    # Normal colors (0-7)
    black = palette.black; # color0
    red = palette.red; # color1
    green = palette.green; # color2
    yellow = palette.yellow; # color3
    blue = palette.blue; # color4
    magenta = palette.pink; # color5
    cyan = palette.cyan; # color6
    white = palette.lightPurple; # color7

    # Bright colors (8-15)
    brightBlack = palette.midPurple; # color8
    brightRed = palette.red; # color9
    brightGreen = palette.green; # color10
    brightYellow = palette.brightYellow; # color11
    brightBlue = palette.lightPurple; # color12
    brightMagenta = palette.pink; # color13
    brightCyan = palette.lightGray; # color14
    brightWhite = palette.white; # color15
  };
}
