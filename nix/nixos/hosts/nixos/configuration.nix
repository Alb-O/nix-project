# NixOS-WSL Configuration
# WSL-specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL
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
  services.xserver.enable = true;
  services.displayManager.sddm.enable = lib.mkForce false; # Disable for WSL

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
    mesa # For OpenGL support
    mesa.drivers # Mesa drivers including llvmpipe
    vulkan-loader # For Vulkan support
    weston # Alternative Wayland compositor
    # Environment and niri launcher scripts
    (writeShellScriptBin "fix-wsl-env" ''
      # Fix WSL environment for niri
      echo "Fixing WSL environment variables..."
      unset WAYLAND_DISPLAY
      unset DISPLAY
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"
      mkdir -p "$XDG_RUNTIME_DIR"
      echo "Environment fixed. You can now run 'niri' directly."
    '')
    # Niri launcher scripts
    (writeShellScriptBin "start-niri-simple" ''
      # Reset environment to clean state
      unset WAYLAND_DISPLAY
      unset DISPLAY
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"
      mkdir -p "$XDG_RUNTIME_DIR"

      echo "Starting niri with clean environment..."
      exec niri
    '')
    (writeShellScriptBin "start-niri-with-services" ''
      # Start systemd user services first, then run niri normally
      echo "Starting systemd user services..."
      systemctl --user start graphical-session.target 2>/dev/null || true

      echo "Starting niri (preserving current environment)..."
      exec niri
    '')
    (writeShellScriptBin "start-niri" ''
      # Set up WSL environment for niri as compositor
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=niri
      export XDG_SESSION_DESKTOP=niri
      export XDG_RUNTIME_DIR="/run/user/$(id -u)"

      # Set up library paths for X11 libraries
      export LD_LIBRARY_PATH="${pkgs.xorg.libXcursor}/lib:${pkgs.xorg.libXrandr}/lib:${pkgs.xorg.libXi}/lib:${pkgs.xorg.libXinerama}/lib:${pkgs.mesa}/lib:${pkgs.vulkan-loader}/lib:$LD_LIBRARY_PATH"

      # Ensure runtime directory exists
      mkdir -p "$XDG_RUNTIME_DIR"

      # IMPORTANT: Unset WAYLAND_DISPLAY so niri starts as compositor, not client
      unset WAYLAND_DISPLAY

      # Force Wayland-only mode (disable X11 fallback)
      unset DISPLAY
      export WINIT_UNIX_BACKEND=wayland

      # WSL GPU/rendering configuration
      export WLR_RENDERER=pixman  # Use CPU-based rendering
      export WLR_NO_HARDWARE_CURSORS=1
      export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe  # Force software rendering
      export WLR_BACKENDS=headless  # Force headless backend for WSL
      export WLR_SESSION=noop  # No session management needed

      # Import systemd environment
      systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_RUNTIME_DIR LD_LIBRARY_PATH WINIT_UNIX_BACKEND WLR_RENDERER WLR_NO_HARDWARE_CURSORS MESA_LOADER_DRIVER_OVERRIDE WLR_BACKENDS WLR_SESSION

      # Start niri as the Wayland compositor
      echo "Starting niri compositor in WSL mode..."
      echo "Note: This may run headless - connect via WSLg or VNC"

      # Try different approaches
      echo "Attempting to start niri..."
      exec niri --session
    '')
  ];
}
