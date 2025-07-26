# System-wide application and configuration definitions
# Change applications here to update entire system
{
  terminal = "kitty";
  browser = "firefox";
  fileManager = "nautilus";
  editor = "helix";
  launcher = "fuzzel";
  imageViewer = "loupe";
  videoPlayer = "mpv";
  pdfViewer = "evince";
  archiveManager = "file-roller";
  windowManager = "niri";
  displayManager = "sddm";
  shell = "fish";
  
  monoFont = "JetBrains Mono Nerd Font";
  sansFont = "Noto Sans";
  gtkTheme = "Adwaita-dark";
  iconTheme = "Adwaita";
  cursorTheme = "Adwaita";
  
  user = {
    name = "Albert O'Shea";
    username = "albert";
    email = "albertoshea2@gmail.com";
    homeDirectory = "/home/albert";
  };
  
  system = {
    hostname = "gtx1080shitbox";
    architecture = "x86_64-linux";
    stateVersion = "25.05";
  };
  
  dirs = {
    config = "/home/albert/.config/nix-config";
    nixConfig = "/home/albert/.config/nix-config";
    localBin = "/home/albert/.local/bin";
    localShare = "/home/albert/.local/share";
    secrets = "/home/albert/.config/nix-config/secrets";
    scripts = "/home/albert/.config/nix-config/scripts";
  };
}