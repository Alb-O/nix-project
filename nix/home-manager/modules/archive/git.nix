{
  pkgs,
  lib,
  secrets,
  ...
}: {
  programs.git = {
    enable = true;
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
        signingKey = secrets.signingKey;
      };
      "gpg.ssh" = {
        allowedSignersFile = "${pkgs.writeText "allowed_signers" secrets.allowedSigners}";
      };
      "credential \"https://github.com\"" = {
        helper = "${lib.getExe pkgs.gh} auth git-credential";
      };
      "credential \"https://gist.github.com\"" = {
        helper = "${lib.getExe pkgs.gh} auth git-credential";
      };
    };
    userName = secrets.name;
    userEmail = secrets.email;
  };
}
