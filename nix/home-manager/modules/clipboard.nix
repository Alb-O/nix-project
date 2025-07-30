# Clipboard manager configuration for Wayland
# Ensures clipboard content persists even after source application closes
{pkgs, ...}: {
  # Enable cliphist service to manage clipboard history
  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard manager for Wayland";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.unstable.wl-clipboard}/bin/wl-paste --watch ${pkgs.unstable.cliphist}/bin/cliphist store";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Enable wl-clip-persist service to keep clipboard content alive
  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Clipboard persistence daemon for Wayland";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.unstable.wl-clip-persist}/bin/wl-clip-persist --clipboard regular";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Optional: Add environment variables for clipboard tools
  home.sessionVariables = {
    # Ensure clipboard tools work properly
    CLIPHIST_DB_PATH = "$HOME/.local/share/cliphist/db";
  };
}
