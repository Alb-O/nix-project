# Global font configuration
# Centralized font definitions for consistent typography across all applications
pkgs: {
  # Monospace font - for terminals, code editors, and technical content
  mono = {
    name = "JetBrainsMono Nerd Font Mono";
    package = pkgs.nerd-fonts.jetbrains-mono;
    size = {
      small = 11;
      normal = 13;
      large = 15;
    };
  };

  # Sans-serif font - for UI elements and general text
  sansSerif = {
    name = "Inter";
    package = pkgs.inter;
    size = {
      small = 11;
      normal = 12;
      large = 14;
    };
  };

  # Serif font - for documents and reading
  serif = {
    name = "Crimson Pro";
    package = pkgs.crimson-pro;
    size = {
      small = 12;
      normal = 13;
      large = 15;
    };
  };
}
