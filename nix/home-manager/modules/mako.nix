{...}: let
  colorscheme = import ../../lib/colorscheme.nix;
in {
  services.mako = {
    enable = true;

    settings = {
      # Basic appearance
      background-color = colorscheme.ui.background;
      text-color = colorscheme.ui.foreground;
      border-color = colorscheme.ui.border;
      progress-color = colorscheme.ui.primary;

      # Font configuration
      font = "JetBrainsMono Nerd Font 13";

      # Layout and positioning
      width = 400;
      height = 150;
      margin = "10";
      padding = "15";
      border-size = 2;
      border-radius = 0;

      # Behavior
      default-timeout = 5000;
      ignore-timeout = true;
      layer = "overlay";
      anchor = "top-right";
    };

    # Categories with different colors
    extraConfig = ''
      [urgency=low]
      border-color=${colorscheme.ui.info}

      [urgency=normal]
      border-color=${colorscheme.ui.border}

      [urgency=critical]
      border-color=${colorscheme.ui.error}
      background-color=${colorscheme.ui.error}
      text-color=${colorscheme.ui.background}

      [category=screenshot]
      border-color=${colorscheme.ui.success}

      [app-name=volume]
      border-color=${colorscheme.ui.accent}
    '';
  };
}
