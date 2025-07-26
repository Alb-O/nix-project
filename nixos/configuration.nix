# NixOS system configuration
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  globals = import ../lib/globals.nix;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    # Add module imports as needed
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.nur

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      # nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = ["ntfs"];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.xserver.videoDrivers = ["nvidia"];

  # NVIDIA driver integration (handles early loading and module setup)
  boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=0"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false; # Use proprietary driver
    nvidiaSettings = true;
  };

  # Extra insurance: force blacklist nouveau (per NixOS Wiki)
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Hobart";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "us";

  # No sudo password for wheel users
  security.sudo.wheelNeedsPassword = false;

  # Set your system hostname
  networking.hostName = globals.system.hostname;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    ${globals.user.username} = {
      isNormalUser = true;
      description = globals.user.name;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = ["wheel" "networkmanager" "audio" "video" "docker"];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    helix
    wget
    gemini-cli
    vscode
    sddm-astronaut
    nautilus # Required for GTK4 file pickers via xdg-desktop-portal-gnome delegation
    sops
    age
    ssh-to-age
  ];

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [globals.user.username];
  };

  programs._1password.enable = true;
  programs.${globals.windowManager}.enable = true;

  # sops-nix configuration
  sops = {
    defaultSopsFile = ../secrets/example.yaml;
    age.keyFile = "${globals.user.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      example-password = {};
      database-url = {};
      api-key = {};
    };
  };

  services.displayManager.${globals.displayManager} = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.${globals.displayManager};
    extraPackages = with pkgs; [sddm-astronaut];
    theme = "sddm-astronaut-theme";
  };

  # XDG Desktop Portal Configuration for GTK4 File Pickers
  #
  # Technical Implementation Notes:
  # - xdg-desktop-portal-gtk (1.15.3) is built against GTK3, produces GTK3 file dialogs
  # - xdg-desktop-portal-gnome (48.0) is built against GTK4, uses Nautilus (GTK4) for file operations
  # - GNOME portal delegates FileChooser to Nautilus, which provides native GTK4 dialogs
  # - GTK portal serves as fallback for interfaces GNOME doesn't implement
  #
  # Portal Backend Selection Priority:
  # 1. GNOME portal: GTK4-based file choosers via Nautilus integration
  # 2. GTK portal: GTK3-based fallback for other desktop integration features
  #
  # Dependencies: Requires nautilus package for GNOME portal file chooser delegation
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk # GTK3-based portal (fallback)
      pkgs.xdg-desktop-portal-gnome # GTK4-based portal (primary for file operations)
    ];
    config = {
      # Common configuration for all desktop environments
      common = {
        default = [
          "gnome" # Prioritize GNOME portal (GTK4)
          "gtk" # Fallback to GTK portal (GTK3)
        ];
        # Force GTK4 file pickers via GNOME portal -> Nautilus delegation
        "org.freedesktop.impl.portal.FileChooser" = [
          "gnome"
        ];
      };
      # Niri compositor specific configuration
      # Niri is a newer Wayland compositor that benefits from explicit portal configuration
      niri = {
        default = [
          "gnome" # GNOME portal provides GTK4 integration
          "gtk" # GTK portal handles remaining interfaces
        ];
        # Critical: Use GNOME portal for GTK4 file choosers
        # This ensures modern file dialogs instead of legacy GTK3 versions
        "org.freedesktop.impl.portal.FileChooser" = [
          "gnome"
        ];
        # GTK portal handles these interfaces well on Wayland
        "org.freedesktop.impl.portal.Access" = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.Notification" = [
          "gtk"
        ];
        # GNOME keyring for secure credential storage
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
    };
    # Enable portal integration for xdg-open commands
    # This ensures file operations use portal-based file choosers
    xdgOpenUsePortal = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "nixbackup";
    users.${globals.user.username} = import ../home-manager/home.nix {inherit inputs outputs lib config pkgs;};
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = globals.system.stateVersion;
}
