# Personal information module that reads from sops secrets
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Check if personal secrets are configured
  hasPersonalSecrets = config.sops.secrets ? personal-name && config.sops.secrets ? personal-email;
in {
  # Only create environment variables if secrets are available
  environment.variables = lib.mkIf hasPersonalSecrets {
    PERSONAL_NAME_FILE = config.sops.secrets.personal-name.path;
    PERSONAL_EMAIL_FILE = config.sops.secrets.personal-email.path;
  };

  # Create wrapper scripts that can access the secrets
  environment.systemPackages = with pkgs;
    if hasPersonalSecrets
    then [
      (writeShellScriptBin "get-personal-name" ''
        cat ${config.sops.secrets.personal-name.path}
      '')
      (writeShellScriptBin "get-personal-email" ''
        cat ${config.sops.secrets.personal-email.path}
      '')
    ]
    else [
      (writeShellScriptBin "get-personal-name" ''
        echo "Personal secrets not configured (SOPS disabled)"
        exit 1
      '')
      (writeShellScriptBin "get-personal-email" ''
        echo "Personal secrets not configured (SOPS disabled)"
        exit 1
      '')
    ];
}
