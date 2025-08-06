# NixOS-WSL Configuration
# WSL-specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
#
# This configuration provides:
# - Multi-user support via parameterized globals
# - Niri window manager with WSL optimizations
# - Systemd user services (audio: pipewire, wireplumber)
# - GUI support with WSLg integration
# - Wallpaper daemon (swww) with proper Wayland dependency handling
#
# Usage:
# - Use `start-niri-with-services` for full desktop experience
# - Use `start-niri-simple` for minimal niri session
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  globals,
  ...
}: {
  imports = [
    # Import our modular NixOS configuration
    ../../modules
  ];

  # WSL-specific configuration
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.startMenuLaunchers = true;

  # Enable GUI support for WSL
  # This allows running GUI applications with WSLg
  wsl.wslConf.interop.appendWindowsPath = false;

  # User configuration
  users.users.nixos = {
    isNormalUser = true;
    description = globals.user.name;
    extraGroups = ["wheel" "networkmanager" "audio" "video"];
  };

  # System configuration
  system.stateVersion = globals.system.stateVersion;
  networking.hostName = globals.system.hostname;

  # Platform configuration
  nixpkgs.hostPlatform = globals.system.architecture;

  # Enable experimental features (using mkForce to override module conflicts)
  nix.settings.experimental-features = lib.mkForce ["nix-command" "flakes"];

  # Disable legacy channels that cause storePath errors
  nix.channel.enable = lib.mkForce false;

  # Enable essential services for GUI support (WSL with auto-login)
  #services.xserver.enable = true;
  #services.displayManager.sddm.enable = lib.mkForce false; # Disable for WSL

  # Enable auto-login for WSL user
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Use greetd for lightweight session management
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
      initial_session = {
        command = "niri-session";
        user = "nixos";
      };
    };
  };

  # Enable niri with build optimizations for WSL
  programs.niri.enable = true;

  # Enable proper user session management
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Increase build resources for Rust compilation
  nix.settings = {
    max-jobs = lib.mkDefault 1; # Single job to maximize memory per build
    cores = lib.mkDefault 1;
    # Disable sandbox to reduce memory overhead
    sandbox = false;
  };

  # Set environment variables for Rust builds to prevent stack overflow
  environment.variables = {
    RUST_MIN_STACK = "67108864"; # 64MB stack size (double the suggested)
    # Additional Rust build optimizations
    CARGO_BUILD_JOBS = "1";
    # Reduce memory usage during linking
    RUSTFLAGS = "-C link-arg=-Wl,--no-keep-memory -C link-arg=-Wl,--reduce-memory-overheads";
  };

  # Disable SSH service for WSL (not needed, causes key generation issues)
  services.openssh.enable = lib.mkForce false;

  # Disable SOPS for WSL (secrets not needed for basic setup)
  sops.defaultSopsFile = lib.mkForce null;
  sops.secrets = lib.mkForce {};

  # Disable keyd for WSL (no direct keyboard hardware access)
  services.keyd.enable = lib.mkForce false;

  # Disable xdg-desktop-portal for WSL (causes hangs)
  xdg.portal.enable = lib.mkForce false;

  # Audio support
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Font configuration for GUI apps
  fonts.enableDefaultPackages = true;

  # Create niri launcher script and add required libraries for WSL
  environment.systemPackages = with pkgs; [
    # X11 libraries needed for niri in WSL
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXinerama
    mesa # For OpenGL support (includes llvmpipe)
    vulkan-loader # For Vulkan support
    weston # Alternative Wayland compositor

    # Main niri launcher with services (recommended for WSL)
    (writeShellScriptBin "start-niri-with-services" ''
      # Start systemd user services properly, then run niri
      echo "Setting up systemd user session..."

      # Set up session environment
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=niri
      export XDG_SESSION_DESKTOP=niri

      # Start niri in background
      niri &
      NIRI_PID=$!
      echo "Niri started with PID $NIRI_PID"

      # Wait for niri to create wayland socket
      sleep 3
      export WAYLAND_DISPLAY=wayland-1

      # Import environment to systemd
      systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP WAYLAND_DISPLAY

      # Start essential user services now that wayland is available
      echo "Starting user services..."
      systemctl --user start pipewire.service 2>/dev/null || true
      systemctl --user start pipewire-pulse.service 2>/dev/null || true
      systemctl --user start wireplumber.service 2>/dev/null || true
      # Skip xdg-desktop-portal as it hangs in WSL
      echo "  - Skipping xdg-desktop-portal (hangs in WSL)"

      # Start swww daemon now that Wayland is available
      echo "Starting swww wallpaper daemon..."
      systemctl --user start swww-daemon.service 2>/dev/null || true

      echo "Services started. Press Ctrl+C to stop niri."
      wait $NIRI_PID
    '')

    # Simple niri launcher (fallback option)
    (writeShellScriptBin "start-niri-simple" ''
      # Reset environment to clean state
      unset WAYLAND_DISPLAY 2>/dev/null || true
      unset DISPLAY 2>/dev/null || true
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"
      mkdir -p "$XDG_RUNTIME_DIR"

      echo "Starting niri with clean environment..."
      exec niri
    '')
  ];
}
