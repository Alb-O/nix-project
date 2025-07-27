# Program configurations module
# Configures various applications and tools
{
  ...
}: let
  globals = import ../../../lib/globals.nix;
in {
  imports = [
    ./kitty.nix
    ./firefox.nix
    ./niri.nix
    ./fish.nix
    ./vscode.nix
		./fuzzel.nix
    ./sillytavern.nix
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
