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
      DisableMasterPasswordCreation = true; # To be determined how to handle master password
      DisableProfileImport = true; # Purity enforcement: Only allow nix-defined profiles
      DisableProfileRefresh = true; # Disable the Refresh Firefox button on about:support and support.mozilla.org
      DisableSetDesktopBackground = true; # Remove the “Set As Desktop Background…” menuitem when right clicking on an image, because Nix is the only thing that can manage the backgroud
      DisplayMenuBar = "default-off";
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      DontCheckDefaultBrowser = true; # Stop being attention whore
      HardwareAcceleration = false; # Disabled as it's exposes points for fingerprinting
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
      # FIXME(Krey): Review `~/.mozilla/firefox/Default/extensions.json` and uninstall all unwanted
      # Suggested by t0b0 thank you <3 https://gitlab.com/engmark/root/-/blob/60468eb82572d9a663b58498ce08fafbe545b808/configuration.nix#L293-310
      # NOTE(Krey): Check if the addon is packaged on https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/addons.json
      ExtensionSettings = {
        "*" = {
          installation_mode = "blocked";
          blocked_install_message = "FUCKING FORGET IT!";
        };
        # "addon@darkreader.org" = {
        # 	# Dark Reader
        # 	install_url = "file:///${self.inputs.firefox-addons.packages.x86_64-linux.darkreader}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/addon@darkreader.org.xpi";
        # 	installation_mode = "force_installed";
        # };
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
      };
    };
    profiles.albert = {
      id = 0;
      isDefault = true;
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

        # Don't ask for download dir
        "browser.download.useDownloadDir" = false;

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

        # Disable fx accounts
        "identity.fxaccounts.enabled" = false;
        # Disable "save password" prompt
        "signon.rememberSignons" = false;
        # Harden
        "privacy.trackingprotection.enabled" = true;
        "dom.security.https_only_mode" = true;
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
        # Enable sidebar/vertical tabs
        "sidebar.position_start" = true;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "aichat,bookmarks,history"
        # Restore session on startup
        "browser.startup.page" = 3;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "privacy.clearOnShutdown.sessions" = false;
        "privacy.clearOnShutdown.cache" = false;
        "privacy.clearOnShutdown.cookies" = false;
        # Disable about:config warning
        "browser.aboutConfig.showWarning" = false;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
