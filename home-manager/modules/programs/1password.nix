# 1Password home-manager configuration with Wayland wrapper
{pkgs, ...}: let
  # Wrap 1Password GUI to always use Wayland platform
  _1password-gui-wayland = pkgs.symlinkJoin {
    name = "1password-gui-wayland";
    pname = pkgs._1password-gui.pname;
    version = pkgs._1password-gui.version;
    paths = [pkgs._1password-gui];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/1password \
        --add-flags "--ozone-platform=wayland"
    '';
  };
in {
  # 1Password CLI tool for user environment
  home.packages = [
    pkgs._1password
    _1password-gui-wayland
  ];

  # 1Password GUI service with Wayland support
  systemd.user.services."1password-gui" = {
    Unit = {
      Description = "1Password GUI";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${_1password-gui-wayland}/bin/1password --silent";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}