# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # NUR (Nix User Repository) overlay
  nur = inputs.nur.overlays.default;

  # VSCode extensions overlay - configure with allowUnfree
  vscode-extensions = final: prev: 
    let
      vscode-extensions = inputs.nix-vscode-extensions.extensions.${final.system};
    in {
      vscode-marketplace = vscode-extensions.vscode-marketplace;
      vscode-marketplace-release = vscode-extensions.vscode-marketplace-release;
    };
}
