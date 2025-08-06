{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR (Nix User Repository)
    nur.url = "github:nix-community/NUR";

    # sops-nix for secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # Niri flake for advanced configuration
    niri-flake.url = "github:sodiboo/niri-flake";

    # nix-colors for color scheme management
    nix-colors.url = "github:misterio77/nix-colors";

    # nix-userstyles for website theming
    nix-userstyles.url = "github:knoopx/nix-userstyles";

    # NixOS-WSL for Windows Subsystem for Linux support
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    nix-vscode-extensions,
    niri-flake,
    nix-colors,
    nix-userstyles,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];

    # Import user configurations
    users = import ./lib/users.nix;

    # Helper function to create home configuration
    mkHomeConfiguration = {
      username,
      name,
      email,
      hostname ? "gtx1080shitbox",
      system ? "x86_64-linux",
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = import ./overlays {inherit inputs;};
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          inherit inputs outputs;
          globals = import ./lib/globals.nix {
            inherit username hostname;
            # name and email are now read from sops secrets at runtime
          };
        };
        modules = [
          ./home-manager/home.nix
          sops-nix.homeManagerModules.sops
          niri-flake.homeModules.config
        ];
      };
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays =
      import ./overlays {inherit inputs;}
      // {
      };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./nixos/modules;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./home-manager/modules;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      gtx1080shitbox = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          globals = import ./lib/globals.nix {
            username = "albert";
            hostname = "gtx1080shitbox";
            # name and email are now read from sops secrets
          };
        };
        modules = [
          # > Our main nixos configuration file <
          ./nixos/hosts/gtx1080shitbox/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          globals = import ./lib/globals.nix {
            username = "nixos";
            hostname = "nixos";
            stateVersion = "24.11";
            # name and email are now read from sops secrets
          };
        };
        modules = [
          # NixOS-WSL configuration
          ./nixos/hosts/nixos/configuration.nix
          nixos-wsl.nixosModules.wsl
          sops-nix.nixosModules.sops
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = let
      # Generate configurations for each user and hostname combination
      mkConfigs = hostname:
        nixpkgs.lib.mapAttrs' (
          userKey: userConfig:
            nixpkgs.lib.nameValuePair
            "${userConfig.username}@${hostname}"
            (mkHomeConfiguration {
              inherit (userConfig) username name email;
              inherit hostname;
            })
        )
        users;
    in
      # Supporting multiple hostnames
      (mkConfigs "gtx1080shitbox") // (mkConfigs "nixos");
    # Optionally, add Cachix binary cache for claude-code
    nixConfig = {
      substituters = ["https://claude-code.cachix.org"];
      trusted-public-keys = ["claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="];
    };
  };
}
