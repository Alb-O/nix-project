# Rust development environment configuration
{
  pkgs,
  globals,
  ...
}: {
  # Shell aliases for Rust development
  home.shellAliases = {
    cargo-binstall = "nix-shell ${globals.dirs.projectRoot}/nix/shells/rust.nix --run 'cargo-binstall'";
    rust-shell = "nix-shell ${globals.dirs.projectRoot}/nix/shells/rust.nix --command fish";
  };

  # Rust development environment variables
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
