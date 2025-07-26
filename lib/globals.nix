# Global configuration variables
# Centralized place to define commonly used applications and settings
# that might need to be changed across the entire configuration

{
  # Terminal emulator - used throughout the configuration
  terminal = "kitty";
  
  # Browser - primary web browser
  browser = "firefox";
  
  # File manager - primary file manager
  fileManager = "nautilus";
  
  # Text editor - primary text editor
  editor = "helix";
  
  # Application launcher - used for launching applications
  launcher = "fuzzel";
  
  # Image viewer - primary image viewer
  imageViewer = "loupe";
  
  # Video player - primary video player
  videoPlayer = "mpv";
  
  # PDF viewer - primary PDF viewer
  pdfViewer = "evince";
  
  # Archive manager - for handling compressed files
  archiveManager = "file-roller";
  
  # Window manager/compositor - primary display server
  windowManager = "niri";
  
  # Display manager - login screen
  displayManager = "sddm";
  
  # Shell - primary interactive shell
  shell = "fish";
  
  # Font - primary monospace font
  monoFont = "JetBrains Mono Nerd Font";
  
  # Font - primary sans-serif font
  sansFont = "Noto Sans";
  
  # Theme - GTK theme name
  gtkTheme = "Adwaita-dark";
  
  # Icon theme
  iconTheme = "Adwaita";
  
  # Cursor theme
  cursorTheme = "Adwaita";
  
  # User information
  user = {
    name = "Albert O'Shea";
    username = "albert";
    email = "albertoshea2@gmail.com";
    homeDirectory = "/home/albert";
  };
  
  # System information
  system = {
    hostname = "gtx1080shitbox";
    architecture = "x86_64-linux";
    stateVersion = "25.05";
  };
  
  # Directories - commonly used paths
  dirs = {
    config = "/home/albert/.config/nix-config";
    nixConfig = "/home/albert/.config/nix-config";
    localBin = "/home/albert/.local/bin";
    localShare = "/home/albert/.local/share";
    secrets = "/home/albert/.config/nix-config/secrets";
    scripts = "/home/albert/.config/nix-config/scripts";
  };
}