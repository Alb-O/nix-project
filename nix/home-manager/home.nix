# Home Manager configuration
# Main entry point for user environment configuration
{
  pkgs,
  inputs,
  ...
}: let
  globals = import ../lib/globals.nix;
in {
  # Import modular configuration
  imports = [
    # Custom modules
    (import ./modules {inherit inputs;})

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
  home.packages = with pkgs.unstable;
    [
      # General
      wl-clipboard
      cliphist # Clipboard manager for Wayland
      wl-clip-persist # Keeps clipboard content alive after source app closes
      jq
      ufetch
      git
      gh
      unipicker
      hyprpicker
      lm_sensors
      # AI
      claude-code
      gemini-cli
      geminicommit
      # Nix LSP
      nil
      nixd
      # Python development environment
      python3
      uv
      gcc # Required for linking during Rust compilation
    ]
    ++ [
      # Custom packages
      pkgs.blender-daily
    ];

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = globals.system.stateVersion;
}
