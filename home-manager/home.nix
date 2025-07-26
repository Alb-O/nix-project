# Home Manager configuration
# Main entry point for user environment configuration

{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
} @ args: 

let
  globals = import ../lib/globals.nix;
in
{
  # Import modular configuration
  imports = [
    # Custom modules
    ./modules/programs
    ./modules/desktop
    ./modules/services

    # Example external modules (commented out):
    # outputs.homeManagerModules.example
    # inputs.nix-colors.homeManagerModules.default
  ];

  # Basic user information
  home = {
    username = globals.user.username;
    homeDirectory = globals.user.homeDirectory;
  };

  # User packages
  home.packages = with pkgs.unstable; [
    swww
    luakit
    nil
    nixd
    claude-code
    fastfetch
    sillytavern
  ] ++ [
    # Custom packages can be added here
  ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = globals.system.stateVersion;
}