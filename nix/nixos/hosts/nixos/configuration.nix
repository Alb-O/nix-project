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

  # Create niri launcher script for WSL
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "start-niri" ''
      # Set up environment for niri session
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=niri
      export XDG_SESSION_DESKTOP=niri

      # Import systemd environment
      systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP

      # Start session target (this will start graphical-session.target as dependency)
      systemctl --user start niri.service

      # Wait for niri to be ready and then exec into it
      sleep 1
      exec niri
    '')
  ];
}
