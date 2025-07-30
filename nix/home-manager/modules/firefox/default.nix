# Credit: https://github.com/Misterio77/nix-config
# Firefox configuration - modularized
{
  lib,
  inputs,
  pkgs,
  ...
}: let
  globals = import ../../../lib/globals.nix;

  # Import modular configurations
  colorschemeConfig = import ./colorscheme.nix {inherit inputs pkgs;};
  userChromeConfig = import ./userchrome.nix {};
  policiesConfig = import ./policies.nix {};
  profileConfig = import ./profile.nix {inherit lib;};
in {
  programs.firefox = {
    enable = true;

    # Security and extension policies
    policies = policiesConfig.policies;

    # User profile configuration
    profiles.${globals.user.username} = {
      id = 0;
      isDefault = true;
      path = globals.user.username; # Explicitly set profile path

      # Profile settings
      settings = profileConfig.profileSettings;

      # Apply generated userstyles and userChrome theme
      userContent = colorschemeConfig.userStyles;
      userChrome = userChromeConfig.userChromeCSS;
    };
  };

  # MIME type associations
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
