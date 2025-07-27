# Home Manager modules aggregation
# Logical per-software modules in flat structure
{...}: let
  globals = import ../../lib/globals.nix;
in {
  imports = [
    # Desktop environment
    ./gtk.nix

    # Applications
    ./1password.nix
    ./firefox.nix
    ./kitty.nix
    ./vscode.nix
    ./sillytavern.nix

    # System tools
    ./swww.nix
    ./fuzzel.nix
    ./niri.nix
    ./fish.nix
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
  home.sessionPath = [globals.dirs.localBin];

}
