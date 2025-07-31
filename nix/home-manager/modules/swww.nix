# swww wallpaper daemon configuration
{
  lib,
  pkgs,
  ...
}: let
  colors = import ../../lib/themes;
in {
  # Include swww package in user environment
  home.packages = [pkgs.swww];

  # swww daemon service
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swww}-daemon";
      ExecStartPost = "${lib.getExe pkgs.swww} clear ${colors.ui.background.primary}";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
