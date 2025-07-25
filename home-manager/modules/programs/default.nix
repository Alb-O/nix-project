# Program configurations module
# Configures various applications and tools

{ config, lib, pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./firefox.nix
    ./niri.nix
  ];

  # Core programs
  programs.home-manager.enable = true;
  
  programs.git = {
    enable = true;
    userName = "Albert O'Shea";
    userEmail = "albertoshea2@gmail.com";
  };

  programs.fish.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      # If running interactively and fish is available, launch fish
      if [[ $- == *i* ]] && command -v fish >/dev/null 2>&1; then
        exec fish
      fi
    '';
  };

  # Configure niri compositor
  wayland.windowManager.niri = {
    enable = true;
  };
}