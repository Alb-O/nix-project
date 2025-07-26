# Program configurations module
# Configures various applications and tools

{ config, lib, pkgs, ... }:

let
  globals = import ../../../lib/globals.nix;
in
{
  imports = [
    ./kitty.nix
    ./firefox.nix
    ./niri.nix
    ./fish.nix
    ./vscode.nix
  ];

  # Core programs
  programs.home-manager.enable = true;
  
  programs.git = {
    enable = true;
    userName = globals.user.name;
    userEmail = globals.user.email;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # If running interactively and ${globals.shell} is available, launch ${globals.shell}
      if [[ $- == *i* ]] && command -v ${globals.shell} >/dev/null 2>&1; then
        exec ${globals.shell}
      fi
    '';
  };

  # Configure window manager
  wayland.windowManager.${globals.windowManager} = {
    enable = true;
  };

  # Ensure .local/bin is in PATH
  home.sessionPath = [ globals.dirs.localBin ];

  # Create SillyTavern wrapper script
  home.file.".local/bin/sillytavern-start" = {
    text = ''
      #!${pkgs.bash}/bin/bash
      export SILLYTAVERN_DATAROOT="${globals.dirs.localShare}/sillytavern"
      mkdir -p "$SILLYTAVERN_DATAROOT"
      cd ${pkgs.unstable.sillytavern}/opt/sillytavern
      exec ${pkgs.nodejs}/bin/node server.js "$@"
    '';
    executable = true;
  };

  # Desktop application entries
  xdg.desktopEntries = {
    sillytavern = {
      name = "SillyTavern";
      comment = "LLM Frontend for Power Users";
      icon = "applications-games"; # Generic game icon, can be customized
      exec = "${globals.terminal} ${globals.dirs.localBin}/sillytavern-start";
      categories = [ "Network" "Chat" "Development" ];
      terminal = true;
      type = "Application";
      startupNotify = true;
    };
  };
}