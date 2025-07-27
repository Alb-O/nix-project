# This file defines overlays
{inputs, ...}: [
  # VSCode extensions overlay - use the nix-vscode-extensions overlay
  inputs.nix-vscode-extensions.overlays.default

  # This one brings our custom packages from the 'pkgs' directory
  (final: _prev: import ../pkgs final.pkgs)

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  (final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  })

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  (final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  })

  # NUR (Nix User Repository) overlay
  inputs.nur.overlays.default
]
