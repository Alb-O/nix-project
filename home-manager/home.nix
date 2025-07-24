# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
} @ args: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  home = {
    username = "albert";
    homeDirectory = "/home/albert";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    swww
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Albert O'Shea";
    userEmail = "albertoshea2@gmail.com";
  };

  programs.kitty = {
    enable = true;
    font.name = "JetBrains Mono";
    font.package = pkgs.nerd-fonts.jetbrains-mono;
  };

  programs.fish.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      Preferences = {
        "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
        "cookiebanners.service.mode" = 2; # Block cookie banners
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.trackingprotection.emailtracking.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
      ExtensionSettings = {
        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # 1Password:
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        # DuckDuckGo Privacy Essentials:
        "jid1-ZAdIEUB7XOzOJw@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/duckduckgo-for-firefox/latest.xpi";
          installation_mode = "force_installed";
        };
        # Dark Reader:
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    font.name = "JetBrains Mono";
    font.package = pkgs.nerd-fonts.jetbrains-mono;
  };

  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww wallpaper daemon";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swww}-daemon";
      ExecStartPost = "${lib.getExe pkgs.swww} clear '#3b224c'";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.services."1password-gui" = {
    Unit = {
      Description = "1Password GUI";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs._1password-gui} --silent --enable-features=UseOzonePlatform --ozone-platform=wayland";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
