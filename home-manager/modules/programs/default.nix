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

  # Ensure .local/bin is in PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Create SillyTavern wrapper script
  home.file.".local/bin/sillytavern-start" = {
    text = ''
      #!/bin/bash
      export SILLYTAVERN_DATAROOT="$HOME/.local/share/sillytavern"
      mkdir -p "$SILLYTAVERN_DATAROOT"
      exec ${pkgs.unstable.sillytavern}/opt/sillytavern/start.sh "$@"
    '';
    executable = true;
  };

  # Desktop application entries
  xdg.desktopEntries = {
    sillytavern = {
      name = "SillyTavern";
      comment = "LLM Frontend for Power Users";
      icon = "applications-games"; # Generic game icon, can be customized
      exec = "${config.home.homeDirectory}/.local/bin/sillytavern-start";
      categories = [ "Network" "Chat" "Development" ];
      terminal = false;
      type = "Application";
      startupNotify = true;
    };
  };
}