# Credit: https://github.com/Misterio77/nix-config
{
  pkgs,
  lib,
  ...
}: {
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
      OfferToSaveLogins = false; # Managed by 1Password instead
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
        "sponsorBlocker@ajay.app" = {
          # Sponsor Block
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorBlocker@ajay.app.xpi";
          installation_mode = "force_installed";
        };
        "uBlock0@raymondhill.net" = {
          # uBlock Origin
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          # 1Password
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          # BitWarden
          install_url = "https://addons.mozilla.org/firefox/downloads/file/latest/bitwarden_password_manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
    profiles.albert = {
      id = 0;
      isDefault = true;
      path = "albert"; # Explicitly set profile path for consistency
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
          currentVersion = 20;
          newElementCount = 5;
          dirtyAreaCache = ["nav-bar" "PersonalToolbar" "toolbar-menubar" "TabsToolbar" "widget-overflow-fixed-list"];
          placements = {
            PersonalToolbar = ["personal-bookmarks"];
            TabsToolbar = ["tabbrowser-tabs" "new-tab-button" "alltabs-button"];
            nav-bar = ["back-button" "forward-button" "stop-reload-button" "urlbar-container" "downloads-button" "ublock0_raymondhill_net-browser-action" "_testpilot-containers-browser-action" "reset-pbm-toolbar-button" "unified-extensions-button"];
            toolbar-menubar = ["menubar-items"];
            unified-extensions-area = [];
            widget-overflow-fixed-list = [];
          };
          seen = ["save-to-pocket-button" "developer-button" "ublock0_raymondhill_net-browser-action" "_testpilot-containers-browser-action"];
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

        # Enable userChrome.css for GNOME theme support
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
  };

  # Script to reset Firefox to NixOS-managed state and theme installer
  home.packages = [
    pkgs.addwater # Firefox GNOME theme installer
    (pkgs.writeShellScriptBin "firefox-reset-nixos" ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "🔄 Resetting Firefox to NixOS-managed state..."

      # Kill Firefox if running
      pkill firefox || true
      sleep 2

      # Remove problematic cache and state files that can cause inconsistencies
      rm -rf ~/.cache/mozilla/firefox/*/safebrowsing/
      rm -rf ~/.cache/mozilla/firefox/*/startupCache/
      rm -rf ~/.cache/mozilla/firefox/*/shader-cache/

      # Remove files that Firefox might use to override NixOS settings
      find ~/.mozilla/firefox/albert/ -name "compatibility.ini" -delete 2>/dev/null || true
      find ~/.mozilla/firefox/albert/ -name "times.json" -delete 2>/dev/null || true
      find ~/.mozilla/firefox/albert/ -name "addonStartup.json.lz4" -delete 2>/dev/null || true

      # Remove extension state that might conflict with force-installed extensions
      rm -rf ~/.mozilla/firefox/albert/browser-extension-data/ 2>/dev/null || true
      rm -rf ~/.mozilla/firefox/albert/extensions/ 2>/dev/null || true

      # Remove search engine overrides
      rm -f ~/.mozilla/firefox/albert/search.json.mozlz4 2>/dev/null || true

      echo "✅ Firefox reset complete. Your NixOS settings will be applied on next startup."
      echo "💡 Run 'home-manager switch' to ensure latest configuration is active."
    '')
    (pkgs.writeShellScriptBin "firefox-install-gnome-theme" ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "🎨 Installing Firefox GNOME theme..."

      # Kill Firefox if running
      pkill firefox || true
      sleep 2

      # Use addwater to install the theme
      ${pkgs.addwater}/bin/addwater -f

      echo "✅ Firefox GNOME theme installed successfully!"
      echo "💡 Restart Firefox to see the theme changes."
      echo "📝 Note: The theme requires toolkit.legacyUserProfileCustomizations.stylesheets=true (already configured in NixOS)."
    '')
    (pkgs.writeShellScriptBin "firefox-debug-loading" ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "🔍 Firefox loading issue diagnostics..."

      # Check if Firefox is running
      if pgrep firefox > /dev/null; then
        echo "⚠️  Firefox is currently running. Kill it and restart for clean test."
      fi

      # Check profile directory
      PROFILE_DIR="$HOME/.mozilla/firefox/albert"
      if [[ -d "$PROFILE_DIR" ]]; then
        echo "✅ Profile directory exists: $PROFILE_DIR"

        # Check for problematic settings
        if [[ -f "$PROFILE_DIR/prefs.js" ]]; then
          echo "📋 Checking critical settings in prefs.js..."
          grep -E "(dom\.security\.https_only_mode|network\.|security\.|layers\.acceleration)" "$PROFILE_DIR/prefs.js" | head -10 || echo "No matching prefs found"
        fi

        # Check console output
        echo "🔧 Suggested debug steps:"
        echo "1. Open Firefox Developer Tools (F12)"
        echo "2. Check Console tab for errors"
        echo "3. Try loading a simple HTTP site first: http://example.com"
        echo "4. Check Network tab to see if requests are being blocked"
        echo "5. Temporarily disable HTTPS-only mode in about:config"

      else
        echo "❌ Profile directory not found. Run 'home-manager switch' first."
      fi
    '')
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
