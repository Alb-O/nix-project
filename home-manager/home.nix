# Home Manager configuration
# Main entry point for user environment configuration
{pkgs, ...}: let
  globals = import ../lib/globals.nix;
in {
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
    username = globals.user.username;
    homeDirectory = globals.user.homeDirectory;
  };

  # User packages
  home.packages = with pkgs.unstable;
    [
      swww
      luakit
      nil
      nixd
      claude-code
      ufetch
      sillytavern
      # Rust development toolchain
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      cargo-watch
      cargo-edit
      cargo-audit
      cargo-outdated
      gcc # Required for linking during Rust compilation
    ]
    ++ [
      # Custom packages can be added here
    ];

  # Rust development environment variables
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.unstable.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  # State version - don't change this
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = globals.system.stateVersion;
}
