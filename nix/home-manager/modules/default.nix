# Home Manager modules aggregation
# Logical per-software modules in flat structure
{
  inputs,
  globals,
  ...
}: {
  _module.args = {inherit inputs globals;};
  imports = [
    # Desktop environment
    ./niri
    ./fuzzel.nix
    ./swww.nix
    ./gtk.nix
    ./mako.nix

    # Applications
    ./firefox
    ./kitty.nix
    ./vscode.nix
    ./sillytavern.nix

    # System tools
    ./fish.nix
    ./git.nix
    ./ssh.nix
    ./polkit.nix
    ./clipboard.nix
    ./personal-info.nix

    # Development environments
    ./rust.nix
  ];

  # Core programs
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      # If running interactively and fish is available, launch fish (but not in nix-shell)
      if [[ $- == *i* ]] && command -v fish >/dev/null 2>&1 && [[ -z "$IN_NIX_SHELL" ]]; then
        exec fish
      fi
    '';
  };

  # Extra PATH
  home.sessionPath = [
    globals.dirs.localBin
    globals.dirs.cargoBin
  ];
}
