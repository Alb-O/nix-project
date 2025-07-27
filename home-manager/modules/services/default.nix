# User services configuration
# Manages user-level systemd services
{
  lib,
  pkgs,
  ...
}: {
  # Wallpaper daemon
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swww}-daemon";
      ExecStartPost = "${lib.getExe pkgs.swww} clear '#3b224c'";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };


  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
