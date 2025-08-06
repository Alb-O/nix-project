{
  pkgs,
  lib,
  ...
}: {
  programs.git = {
    enable = true;
    # Personal info is now managed via sops secrets
    # Use the helper scripts to configure git after rebuilding:
    # git config --global user.name "$(get-personal-name)"
    # git config --global user.email "$(get-personal-email)"
    extraConfig = {
      # Basic Git configuration without signing
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = false;
      };
    };
  };

  # Create an activation script to set git config from sops secrets
  home.activation.gitConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ -f /run/secrets/personal-name && -f /run/secrets/personal-email ]]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git config --global user.name "$(cat /run/secrets/personal-name)"
      $DRY_RUN_CMD ${pkgs.git}/bin/git config --global user.email "$(cat /run/secrets/personal-email)"
    fi
  '';
}
