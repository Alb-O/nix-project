# NixOS system configuration
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  globals = import ../../../lib/globals.nix;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./hardware-extra.nix
    ./graphics.nix
    ../../modules
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = import ../../../overlays {inherit inputs;};
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

  # udev rules for GNOME portal hardware integration
  services.udev.packages = with pkgs; [gnome-settings-daemon];

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

  # dconf - required for GNOME portal GSettings access
  programs.dconf.enable = true;

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
    ssh-to-age
  ];

  programs.niri.enable = true;

  # sops-nix configuration
  sops = {
    defaultSopsFile = ../../../../secrets/example.yaml;
    age.keyFile = "${globals.user.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      example-password = {};
      database-url = {};
      api-key = {};
    };
  };

  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [sddm-astronaut];
    theme = "sddm-astronaut-theme";
  };

  # Dependencies: Requires nautilus package for GNOME portal file chooser delegation
  # Portal configuration following Niri wiki recommendations
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # Required fallback portal
      xdg-desktop-portal-gnome # Required for screencasting and file choosers
    ];
  };

  # GNOME keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  # Key remapping with keyd
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = ["*"];
        settings = {
          main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };
    };
  };

  # Hardware fan control
  hardware.fancontrol = {
    enable = true;
    config = ''
      # Configuration file generated by pwmconfig, changes will be lost
      INTERVAL=10
      DEVPATH=hwmon1=devices/pci0000:00/0000:00:18.3 hwmon6=devices/platform/nct6775.656
      DEVNAME=hwmon1=k10temp hwmon6=nct6779
      FCTEMPS=hwmon6/pwm2=hwmon1/temp1_input hwmon6/pwm3=hwmon1/temp1_input
      FCFANS=hwmon6/pwm2=hwmon6/fan2_input
      MINTEMP=hwmon6/pwm2=50 hwmon6/pwm3=50
      MAXTEMP=hwmon6/pwm2=85 hwmon6/pwm3=85
      MINSTART=hwmon6/pwm2=30 hwmon6/pwm3=30
      MINSTOP=hwmon6/pwm2=20 hwmon6/pwm3=20
    '';
  };

  # Don't let fancontrol block rebuilds
  systemd.services.fancontrol.unitConfig.X-StopOnReconfiguration = false;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
    inter
    crimson-pro
  ];

  # Environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "nixbackup";
    sharedModules = [
      inputs.niri-flake.homeModules.config
    ];
    users.${globals.user.username} = import ../../../home-manager/home.nix {inherit inputs outputs lib config pkgs;};
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = globals.system.stateVersion;
}
