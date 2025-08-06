# NixOS modules aggregation
{globals, ...}: {
  imports = [
    ./keyring.nix
    ./packages.nix
    ./desktop.nix
    ./keyboard.nix
    ./fonts.nix
    ./ssh.nix
    ./sops.nix
    ./flake-configuration.nix
    ./home-manager-configuration.nix
  ];
}
