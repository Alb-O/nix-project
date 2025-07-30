# Firefox policies configuration
# Security, privacy, and extension management
{...}: {
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
}
