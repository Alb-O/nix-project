{
  pkgs,
  lib,
  ...
}: let
  globals = import ../../lib/globals.nix;
in
{
  programs.git = {
    enable = true;
    userName = globals.user.name;
    userEmail = globals.user.email;
    extraConfig = {
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = {
        gpgsign = true;
      };

      user = {
        signingKey = "...";
      };
    };
  };
}
