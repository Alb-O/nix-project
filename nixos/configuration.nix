# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # Enable home-manager
    inputs.home-manager.nixosModules.home-manager

    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

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

  boot.supportedFilesystems = [ "ntfs" ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.xserver.videoDrivers = ["nvidia"];

  # NVIDIA driver integration (handles early loading and module setup)
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=0" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
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
  networking.hostName = "gtx1080shitbox";

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    albert = {
      isNormalUser = true;
      description = "Albert O'Shea";
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" ];
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
    alacritty
    kitty
    fuzzel
    nil
    nixd
    gemini-cli
    vscode
  ];

programs._1password-gui = {
  enable = true;
  polkitPolicyOwners = [ "albert" ];
};

programs._1password.enable = true;
programs.niri.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [ sddm-astronaut ];
    theme = "sddm-astronaut-theme";
    # themePackages not available, workaround below
  };

  environment.etc."sddm/themes/sddm-astronaut-theme".source =
    "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";

xdg.portal = {
  enable = true;
  extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
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
  users.albert = import ../home-manager/home.nix { inherit inputs outputs lib config pkgs; };
  backupFileExtension = "backup";
};

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
