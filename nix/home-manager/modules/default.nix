# Home Manager modules aggregation
# Logical per-software modules in flat structure
{inputs}: let
  globals = import ../../lib/globals.nix;
in {
  _module.args = {inherit inputs;};
  imports = [
    # Desktop environment
    ./niri.nix
    ./fuzzel.nix
    ./swww.nix
    ./gtk.nix
    ./mako.nix

    # Applications
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
      # If running interactively and fish is available, launch fish
      if [[ $- == *i* ]] && command -v fish >/dev/null 2>&1; then
        exec fish
      fi
    '';
  };

  # Window manager configuration is handled by niri-declarative.nix module

  # Ensure .local/bin is in PATH
  home.sessionPath = [globals.dirs.localBin];
}
