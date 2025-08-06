# SOPS secrets management configuration
{
  pkgs,
  globals,
  ...
}: {
  # sops-nix configuration
  sops = {
    defaultSopsFile = ../../../secrets/example.yaml;
    age.keyFile = "${globals.user.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      example-password = {};
      database-url = {};
      api-key = {};

      # Personal information secrets
      personal-name = {
        sopsFile = ../../../secrets/personal.yaml;
        key = "name";
      };
      personal-email = {
        sopsFile = ../../../secrets/personal.yaml;
        key = "email";
      };
    };
  };

  # Required for sops
  environment.systemPackages = with pkgs; [
    ssh-to-age
  ];
}
