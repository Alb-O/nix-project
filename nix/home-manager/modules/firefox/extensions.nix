# Firefox extensions configuration
# Managed extensions and their installation settings
{...}: {
  extensionSettings = {
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
    "clipper@obsidian.md" = {
      # Obsidian Clipper
      install_url = "https://addons.mozilla.org/firefox/downloads/file/latest/web-clipper-obsidian/latest.xpi";
      installation_mode = "force_installed";
    };
  };
}
