{globals, ...}: {
  programs.git = {
    enable = true;
    userName = globals.user.name;
    userEmail = globals.user.email;
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
}
