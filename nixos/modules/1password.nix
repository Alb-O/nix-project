# 1Password system configuration
# Requires system-level integration for polkit authentication
{...}: let
  globals = import ../../lib/globals.nix;
in {
  # 1Password CLI and GUI with polkit integration
  programs._1password = {
    enable = true;
  };

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [globals.user.username];
  };
}