# Home Manager configuration
# Main entry point for user environment configuration

{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
} @ args: {
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
    username = "albert";
    homeDirectory = "/home/albert";
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
  ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}