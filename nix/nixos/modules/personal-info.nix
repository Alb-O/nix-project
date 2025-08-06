# Personal information module that reads from sops secrets
{
  config,
  lib,
  ...
}: {
  # Create environment variables from sops secrets for use in scripts/applications
  environment.variables = {
    PERSONAL_NAME_FILE = config.sops.secrets.personal-name.path;
    PERSONAL_EMAIL_FILE = config.sops.secrets.personal-email.path;
  };

  # Create wrapper scripts that can access the secrets
  environment.systemPackages = [
    (config.lib.nixos.writeShellScriptBin "get-personal-name" ''
      cat ${config.sops.secrets.personal-name.path}
    '')
    (config.lib.nixos.writeShellScriptBin "get-personal-email" ''
      cat ${config.sops.secrets.personal-email.path}
    '')
  ];
}
