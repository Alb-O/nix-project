# System-wide configuration definitions
# This function takes user and system parameters to generate configuration
{
  username ? "albert",
  name ? "Albert O'Shea",
  email ? "albertoshea2@gmail.com",
  hostname ? "gtx1080shitbox",
  architecture ? "x86_64-linux",
  stateVersion ? "25.05",
}: let
  homeDir = "/home/${username}";
in {
  # Font system requires pkgs parameter - access via (import ./fonts.nix pkgs)
  # Legacy font references (deprecated - use fonts.* instead)
  monoFont = "JetBrainsMono Nerd Font Mono";
  sansFont = "Inter";
  gtkTheme = "Adwaita-dark";
  iconTheme = "Adwaita";
  cursorTheme = "Adwaita";

  user = {
    inherit name username email;
    homeDirectory = homeDir;
  };

  system = {
    inherit hostname architecture stateVersion;
  };

  dirs = {
    config = "${homeDir}/.config/nix-config";
    nixConfig = "${homeDir}/.config/nix-config";
    localBin = "${homeDir}/.local/bin";
    localShare = "${homeDir}/.local/share";
    secrets = "${homeDir}/.config/nix-config/secrets";
    scripts = "${homeDir}/.config/nix-config/scripts";
    cargoBin = "${homeDir}/.cargo/bin";
    projectRoot = "${homeDir}/_/projects/nix-project";
  };
}
