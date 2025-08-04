# SOPS secrets management configuration
{pkgs, ...}: let
  globals = import ../../lib/globals.nix;
in {
  # sops-nix configuration
  sops = {
    defaultSopsFile = ../../../secrets/example.yaml;
    age.keyFile = "${globals.user.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      example-password = {};
      database-url = {};
      api-key = {};
    };
  };

  # Required for sops
  environment.systemPackages = with pkgs; [
    ssh-to-age
  ];
}
