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
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOowbFxL8PwbgqUDYz0QNFpTwraXoMsrQjA8+9Jn/2vH";
      };
    };
  };
}
