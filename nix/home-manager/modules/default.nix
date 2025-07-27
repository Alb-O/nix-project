# Home Manager modules aggregation
# Logical per-software modules in flat structure
{...}: let
  globals = import ../../lib/globals.nix;
in {
  imports = [
    # Desktop environment
    ./niri.nix
    ./fuzzel.nix
    ./swww.nix
    ./gtk.nix

    # Applications
    ./1password.nix
    ./firefox.nix
    ./kitty.nix
    ./vscode.nix
    ./sillytavern.nix

    # System tools
    ./fish.nix
    ./git.nix
    ./ssh.nix
    ./polkit.nix
  ];

  # Core programs
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      # If running interactively and ${globals.shell} is available, launch ${globals.shell}
      if [[ $- == *i* ]] && command -v ${globals.shell} >/dev/null 2>&1; then
        exec ${globals.shell}
      fi
    '';
  };

  # Window manager configuration is handled by niri-declarative.nix module

  # Ensure .local/bin is in PATH
  home.sessionPath = [globals.dirs.localBin];

}
