# Personal information module for home-manager that reads from sops secrets
{
  config,
  lib,
  pkgs,
  ...
}: {
  # sops configuration is handled by the flake-level sops module
  # The secrets will be available at runtime via NixOS sops configuration

  # Create helper scripts to access personal info from NixOS sops paths
  home.packages = with pkgs; [
    (writeShellScriptBin "get-personal-name" ''
      # Read from NixOS sops secret path
      if [ -f /run/secrets/personal-name ]; then
        cat /run/secrets/personal-name
      else
        echo "Personal name secret not available"
        exit 1
      fi
    '')
    (writeShellScriptBin "get-personal-email" ''
      # Read from NixOS sops secret path
      if [ -f /run/secrets/personal-email ]; then
        cat /run/secrets/personal-email
      else
        echo "Personal email secret not available"
        exit 1
      fi
    '')
  ];
}
