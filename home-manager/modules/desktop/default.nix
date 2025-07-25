# Desktop environment configuration
# Handles themes, fonts, and desktop-wide settings

{ config, lib, pkgs, ... }:

{
  # Dark theme preferences with UI scaling
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      # GTK UI scaling - 1.25 = 125% scale
      text-scaling-factor = 1.25;
    };
  };

  # GTK theme configuration with larger font size
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    font = {
      name = "JetBrains Mono";
      package = pkgs.nerd-fonts.jetbrains-mono;
      # Increase font size from default (usually 11) to 13 for better readability
      size = 13;
    };
  };
}