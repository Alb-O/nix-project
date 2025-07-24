# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
} @ args: let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
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
    profiles = {
      "user" = {
        id = 0;
        isDefault = true;

        search.engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            definedAliases = ["@no"];
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
        };
      };
    };
    package = pkgs.librewolf;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      /*
         NewTabPage = true;
      Homepage = {
        StartPage = "previous-session";
      };
      Preferences = {
        "cookiebanners.service.mode.privateBrowsing" = 2; # Block cookie banners in private browsing
        "cookiebanners.service.mode" = 2; # Block cookie banners
        "browser.sessionstore.resuming_after_os_restart" = lock-true;
        "browser.startup.page" = 3;
        "privacy.clearOnShutdown.history" = lock-false;
        "privacy.clearOnShutdown.downloads" = lock-false;
        "privacy.clearOnShutdown.sessions" = lock-false;
        "privacy.clearOnShutdown.cookies" = lock-false;
        "privacy.clearOnShutdown.cache" = lock-false;
        "privacy.clearOnShutdown.formdata" = lock-false;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = lock-false;
        "privacy.clearOnShutdown_v2.cache" = lock-false;
        "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = lock-false;
        "middlemouse.paste" = lock-false; # Disable middle mouse paste
        "general.autoScroll" = lock-true; # Enable auto-scrolling
        "sidebar.verticalTabs" = lock-true; # Enable vertical tabs
        "browser.search.suggest.enabled" = lock-true;
      };
      */
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
