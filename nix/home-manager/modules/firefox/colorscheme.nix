# Firefox colorscheme integration
# Converts our colorscheme to nix-colors format and generates userstyles
{
  inputs,
  pkgs,
  ...
}: let
  colorscheme = import ../../../lib/colorscheme.nix;

  # Convert our colorscheme to nix-colors format (remove # from hex colors)
  nixColorsCompatiblePalette = {
    base00 = builtins.substring 1 6 colorscheme.palette.black; # Default Background
    base01 = builtins.substring 1 6 colorscheme.palette.darkPurple; # Lighter Background
    base02 = builtins.substring 1 6 colorscheme.palette.midPurple; # Selection Background
    base03 = builtins.substring 1 6 colorscheme.palette.lightPurple; # Comments, Invisibles
    base04 = builtins.substring 1 6 colorscheme.palette.pink; # Dark Foreground
    base05 = builtins.substring 1 6 colorscheme.palette.white; # Default Foreground
    base06 = builtins.substring 1 6 colorscheme.palette.lightGray; # Light Foreground
    base07 = builtins.substring 1 6 colorscheme.palette.white; # Light Background
    base08 = builtins.substring 1 6 colorscheme.palette.red; # Variables, Tags
    base09 = builtins.substring 1 6 colorscheme.palette.yellow; # Integers, Constants
    base0A = builtins.substring 1 6 colorscheme.palette.brightYellow; # Classes, Bold
    base0B = builtins.substring 1 6 colorscheme.palette.green; # Strings, Code
    base0C = builtins.substring 1 6 colorscheme.palette.cyan; # Support, RegExp
    base0D = builtins.substring 1 6 colorscheme.palette.blue; # Functions, Methods
    base0E = builtins.substring 1 6 colorscheme.palette.pink; # Keywords, Storage
    base0F = builtins.substring 1 6 colorscheme.palette.red; # Deprecated
  };

  # Popular websites to style
  supportedSites = [
    "github"
    "google"
    "youtube"
    "reddit"
    "stackoverflow"
    "duckduckgo"
    "wikipedia"
    "twitter"
    "chatgpt"
    "whatsapp-web"
    "spotify"
  ];

  # Generate userstyles using nix-userstyles (only if available)
  userStyles =
    if inputs ? nix-userstyles && inputs.nix-userstyles ? packages.${pkgs.system}.mkUserStyles
    then inputs.nix-userstyles.packages.${pkgs.system}.mkUserStyles nixColorsCompatiblePalette supportedSites
    else "";
in {
  inherit nixColorsCompatiblePalette supportedSites userStyles;
}
