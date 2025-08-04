# NixOS modules aggregation
{
  imports = [
    ./keyring.nix
    ./packages.nix
    ./desktop.nix
  ];
}
