_: {
  programs.ssh = {
    enable = true;
    # Basic SSH configuration without external identity agent
    extraConfig = ''
      Host *
          AddKeysToAgent yes
    '';
  };
}
