# Bitwarden home-manager configuration with Wayland wrapper
{pkgs, ...}: let
  # Wrap Bitwarden desktop app to always use Wayland platform
  bitwarden-wayland = pkgs.symlinkJoin {
    name = "bitwarden";
    pname = pkgs.bitwarden.pname;
    version = pkgs.bitwarden.version;
    paths = [pkgs.bitwarden];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/bitwarden \
        --add-flags "--ozone-platform=wayland"
    '';
  };
in {
  # Bitwarden desktop app with Wayland support
  home.packages = [
    bitwarden-wayland
  ];

  # Optional: Bitwarden GUI service with Wayland support
  # Uncomment if you want Bitwarden to start automatically
  # systemd.user.services."bitwarden-gui" = {
  #   Unit = {
  #     Description = "Bitwarden Desktop";
  #     After = ["graphical-session.target"];
  #   };
  #   Service = {
  #     ExecStart = "${bitwarden-wayland}/bin/bitwarden";
  #     Restart = "on-failure";
  #   };
  #   Install = {
  #     WantedBy = ["graphical-session.target"];
  #   };
  # };
}
