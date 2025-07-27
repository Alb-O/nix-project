# Niri Home Manager Module
# Configures niri, a scrollable-tiling Wayland compositor
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.niri;
in {
  options.wayland.windowManager.niri = {
    enable = mkEnableOption "niri, a scrollable-tiling Wayland compositor";

    package = mkOption {
      type = types.package;
      default = pkgs.niri;
      description = "The niri package to use.";
    };

    configFile = mkOption {
      type = types.path;
      default = ../../configs/niri/config.kdl;
      description = "Path to the niri configuration file.";
    };

    systemd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable niri-session.target on niri startup.";
      };

      variables = mkOption {
        type = types.listOf types.str;
        default = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "SWAYSOCK"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "NIXOS_OZONE_WL"
          "_JAVA_AWT_WM_NONREPARENTING"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
        ];
        description = "Environment variables to be imported in the systemd & D-Bus user environment.";
      };

      extraCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Extra commands to be run after D-Bus activation.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."niri/config.kdl" = {
      source = cfg.configFile;
    };

    systemd.user.targets.niri-session = mkIf cfg.systemd.enable {
      Unit = {
        Description = "niri compositor session";
        Documentation = ["man:systemd.special(7)"];
        Wants = ["graphical-session-pre.target" "graphical-session.target"];
        After = ["graphical-session-pre.target"];
      };
    };

    systemd.user.services.niri-session = mkIf cfg.systemd.enable {
      Unit = {
        Description = "Import environment variables and start systemd user session for niri";
        Documentation = ["man:systemd.special(7)"];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart =
          [
            "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${concatStringsSep " " cfg.systemd.variables}"
            "${pkgs.systemd}/bin/systemctl --user start niri-session.target"
          ]
          ++ optional (cfg.systemd.extraCommands != "") cfg.systemd.extraCommands;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
