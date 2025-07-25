# User services configuration
# Manages user-level systemd services

{ config, lib, pkgs, ... }:

{
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

  # 1Password GUI service
  systemd.user.services."1password-gui" = {
    Unit = {
      Description = "1Password GUI";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs._1password-gui} --silent --enable-features=UseOzonePlatform --ozone-platform=wayland";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}