# Global font configuration
# Centralized font definitions for consistent typography across all applications
pkgs: {
  mono = {
    name = "JetBrainsMono Nerd Font Mono";
    package = pkgs.nerd-fonts.jetbrains-mono;
    size = {
      small = 11;
      normal = 13;
      large = 15;
    };
  };

  sansSerif = {
    name = "Fira Sans";
    package = pkgs.fira-sans;
    size = {
      small = 11;
      normal = 12;
      large = 14;
    };
  };

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
