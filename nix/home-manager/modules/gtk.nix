# Desktop environment configuration
# Handles themes, fonts, and desktop-wide settings
{pkgs, ...}: let
  fonts = import ../../lib/fonts.nix pkgs;
in {
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
      package = pkgs.libadwaita;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = fonts.mono.name;
      size = fonts.mono.size.small;
      package = fonts.mono.package;
    };

    # GTK bookmarks file
    gtk3.bookmarks = [];

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
