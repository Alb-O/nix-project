# Credit: https://github.com/Misterio77/nix-config
{
  lib,
  inputs,
  pkgs,
  ...
}: let
  globals = import ../../lib/globals.nix;
  colorscheme = import ../../lib/colorscheme.nix;

  # Convert our colorscheme to nix-colors format (remove # from hex colors)
  nixColorsCompatiblePalette = {
    base00 = builtins.substring 1 6 colorscheme.palette.black; # Default Background
    base01 = builtins.substring 1 6 colorscheme.palette.darkPurple; # Lighter Background
    base02 = builtins.substring 1 6 colorscheme.palette.midPurple; # Selection Background
    base03 = builtins.substring 1 6 colorscheme.palette.lightPurple; # Comments, Invisibles
    base04 = builtins.substring 1 6 colorscheme.palette.pink; # Dark Foreground
    base05 = builtins.substring 1 6 colorscheme.palette.white; # Default Foreground
    base06 = builtins.substring 1 6 colorscheme.palette.lightGray; # Light Foreground
    base07 = builtins.substring 1 6 colorscheme.palette.white; # Light Background
    base08 = builtins.substring 1 6 colorscheme.palette.red; # Variables, Tags
    base09 = builtins.substring 1 6 colorscheme.palette.yellow; # Integers, Constants
    base0A = builtins.substring 1 6 colorscheme.palette.brightYellow; # Classes, Bold
    base0B = builtins.substring 1 6 colorscheme.palette.green; # Strings, Code
    base0C = builtins.substring 1 6 colorscheme.palette.cyan; # Support, RegExp
    base0D = builtins.substring 1 6 colorscheme.palette.blue; # Functions, Methods
    base0E = builtins.substring 1 6 colorscheme.palette.pink; # Keywords, Storage
    base0F = builtins.substring 1 6 colorscheme.palette.red; # Deprecated
  };

  # Popular websites to style
  supportedSites = [
    "github"
    "google"
    "youtube"
    "reddit"
    "stackoverflow"
    "duckduckgo"
    "wikipedia"
    "twitter"
    "chatgpt"
    "discord-web"
    "whatsapp-web"
    "spotify"
  ];

  # Generate userstyles using nix-userstyles (only if available)
  userStyles =
    if inputs ? nix-userstyles && inputs.nix-userstyles ? packages.${pkgs.system}.mkUserStyles
    then inputs.nix-userstyles.packages.${pkgs.system}.mkUserStyles nixColorsCompatiblePalette supportedSites
    else "";
in {
  programs.firefox = {
    enable = true;
    policies = {
      AppAutoUpdate = false; # Disable automatic application update
      BackgroundAppUpdate = false; # Disable automatic application update in the background, when the application is not running.
      DisableBuiltinPDFViewer = true; # Considered a security liability
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true; # Disable Firefox Sync
      DisableFirefoxScreenshots = true; # No screenshots?
      DisableForgetButton = true; # Thing that can wipe history for X time, handled differently
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true; # Purity enforcement: Only allow nix-defined profiles
      DisableProfileRefresh = true; # Disable the Refresh Firefox button on about:support and support.mozilla.org
      DisableSetDesktopBackground = true; # Nix is the only thing that can manage the background
      DisplayMenuBar = "default-off";
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      DontCheckDefaultBrowser = true; # Stop being attention whore
      HardwareAcceleration = true; # Enable for proper rendering and performance
      OfferToSaveLogins = false; # Managed by Bitwarden instead
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        # Exceptions = ["https://example.com"]
      };
      EncryptedMediaExtensions = {
        Enabled = true;
        Locked = true;
      };
      ExtensionUpdate = false;
      ExtensionSettings = {
        "addon@darkreader.org" = {
          # Dark Reader
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          # uBlock Origin
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          # BitWarden
          install_url = "https://addons.mozilla.org/firefox/downloads/file/latest/bitwarden_password_manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "sponsorBlocker@ajay.app" = {
          # SponsorBlock
          install_url = "https://addons.mozilla.org/firefox/downloads/file/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
    profiles.${globals.user.username} = {
      id = 0;
      isDefault = true;
      path = globals.user.username; # Explicitly set profile path
      /*
      search = {
        force = true;
        default = "kagi";
        privateDefault = "ddg";
        order = ["kagi" "ddg" "google"];
        engines = {
          kagi = {
            name = "Kagi";
            urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
            icon = "https://kagi.com/favicon.ico";
          };
          bing.metaData.hidden = true;
        };
      };
      */
      settings = {
        "browser.startup.homepage" = "about:home";

        # Disable irritating first-run stuff
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.feeds.showFirstRunUI" = false;
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.rights.3.shown" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.uitour.enabled" = false;
        "startup.homepage_override_url" = "";
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.bookmarks.addedImportButton" = true;

        "browser.download.useDownloadDir" = false; # Don't ask for download dir

        # Disable crappy home activity stream page
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "browser.newtabpage.blocked" = lib.genAttrs [
          # Youtube
          "26UbzFJ7qT9/4DhodHKA1Q=="
          # Facebook
          "4gPpjkxgZzXPVtuEoAL9Ig=="
          # Wikipedia
          "eV8/WsSLxHadrTL1gAxhug=="
          # Reddit
          "gLv0ja2RYVgxKdp0I5qwvA=="
          # Amazon
          "K00ILysCaEq8+bEqV/3nuw=="
          # Twitter
          "T9nJot5PurhJSy8n038xGA=="
        ] (_: 1);

        # Disable some telemetry
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.sessions.current.clean" = true;
        "devtools.onboarding.telemetry.logged" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.prompted" = 2;
        "toolkit.telemetry.rejected" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.unifiedIsOptIn" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        "identity.fxaccounts.enabled" = false; # Disable fx accounts
        "signon.rememberSignons" = false; # Disable "save password" prompt

        # Harden
        "privacy.trackingprotection.enabled" = true;
        "dom.security.https_only_mode" = false; # Disable to allow HTTP sites during troubleshooting
        # Layout
        "browser.uiCustomization.state" = builtins.toJSON {
          placements = {
            widget-overflow-fixed-list = [];
            unified-extensions-area = [];
            nav-bar = ["back-button" "forward-button" "vertical-spacer" "stop-reload-button" "customizableui-special-spring8" "urlbar-container" "customizableui-special-spring7" "ublock0_raymondhill_net-browser-action" "_testpilot-containers-browser-action" "reset-pbm-toolbar-button" "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action" "sponsorblocker_ajay_app-browser-action" "addon_darkreader_org-browser-action" "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action" "unified-extensions-button" "downloads-button"];
            toolbar-menubar = ["menubar-items"];
            TabsToolbar = [];
            vertical-tabs = ["tabbrowser-tabs"];
            PersonalToolbar = ["personal-bookmarks"];
          };
          seen = ["save-to-pocket-button" "developer-button" "ublock0_raymondhill_net-browser-action" "_testpilot-containers-browser-action" "addon_darkreader_org-browser-action" "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action" "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action" "sponsorblocker_ajay_app-browser-action"];
          dirtyAreaCache = ["nav-bar" "PersonalToolbar" "toolbar-menubar" "TabsToolbar" "widget-overflow-fixed-list" "unified-extensions-area" "vertical-tabs"];
          currentVersion = 23;
          newElementCount = 9;
        };
        browser.uidensity = 1; # Compact mode

        # Enable sidebar/vertical tabs
        "sidebar.visibility" = "always-show";
        "sidebar.position_start" = true;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "aichat,bookmarks,history";

        # Use XDG portal
        "widget.use-xdg-desktop-portal.file-picker" = true;

        # Restore session on startup
        "browser.startup.page" = 3;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.clearOnShutdown.sessions" = false;
        "privacy.clearOnShutdown.cache" = false;
        "privacy.clearOnShutdown.cookies" = false;

        "browser.aboutConfig.showWarning" = false; # Disable about:config warning
        "extensions.autoDisableScopes" = 0; # Enable extensions automatically

        # Ensure NixOS-managed settings take priority
        "general.config.filename" = "nixos-firefox.cfg";
        "general.config.obscure_value" = 0;
        "general.config.sandbox_enabled" = false;

        # Prevent Firefox from overriding NixOS-managed settings
        "browser.preferences.instantApply" = false;
        "browser.preferences.animateFadeIn" = true;

        # Force profile consistency
        "browser.profiles.updateCheckIntervalMS" = 0;
        "browser.migration.version" = 999;

        # Enable smooth scrolling
        "apz.overscroll.enabled" = true; # DEFAULT NON-LINUX
        "general.smoothScroll" = true; # DEFAULT
        "general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS" = 12;
        "general.smoothScroll.msdPhysics.enabled" = true;
        "general.smoothScroll.msdPhysics.motionBeginSpringConstant" = 600;
        "general.smoothScroll.msdPhysics.regularSpringConstant" = 650;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaMS" = 25;
        "general.smoothScroll.msdPhysics.slowdownMinDeltaRatio" = "2";
        "general.smoothScroll.msdPhysics.slowdownSpringConstant" = 250;
        "general.smoothScroll.currentVelocityWeighting" = "1";
        "general.smoothScroll.stopDecelerationWeighting" = "1";
        "mousewheel.default.delta_multiplier_y" = 300; # 250-400;
        "general.autoScroll" = true; # Middle-click scrolling

        # Enable userChrome.css for theme support
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };

      # Apply generated userstyles
      userContent = userStyles;
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
