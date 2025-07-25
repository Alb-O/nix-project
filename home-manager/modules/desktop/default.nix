# Desktop environment configuration
# Handles themes, fonts, and desktop-wide settings

{ config, lib, pkgs, ... }:

{
  # Dark theme preferences
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    font.name = "JetBrains Mono";
    font.package = pkgs.nerd-fonts.jetbrains-mono;
  };
}