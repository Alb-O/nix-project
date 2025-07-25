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

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    font = {
      name = "JetBrains Mono";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    
    # Enable GTK4 features
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
    
    gtk4.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
  };

}