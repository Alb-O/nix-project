# VSCode configuration with declarative settings management
{pkgs, ...}: let
  # Wrap VSCode to always use Wayland platform
  vscode-wayland = pkgs.symlinkJoin {
    name = "vscode-wayland";
    pname = pkgs.vscode.pname;
    version = pkgs.vscode.version;
    paths = [ pkgs.vscode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --add-flags "--ozone-platform=wayland"
    '';
  };
in {
  programs.vscode = {
    enable = true;
    package = vscode-wayland;

    # Prevent VSCode from managing extensions imperatively - key to preventing conflicts
    mutableExtensionsDir = false;

    profiles.default.extensions = with pkgs.vscode-marketplace; [
      # Language support
      ms-python.python
      rust-lang.rust-analyzer
      jnoortheen.nix-ide
      tamasfe.even-better-toml

      # Git integration
      eamodio.gitlens

      # Productivity and diagnostics
      usernamehw.errorlens

      # Secrets
      "1password"."op-vscode"

      # AI and code assistance
      anthropic.claude-code

      # Icons
      pkief.material-icon-theme
      pkief.material-product-icons

      # Theme
      ms-vscode.cpptools-themes
    ];

    # Declarative settings.json configuration
    profiles.default.userSettings = {
        # Font configuration - JetBrains Mono Nerd Font
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "editor.fontSize" = 15;
        "editor.fontLigatures" = true;
        "editor.lineHeight" = 1.5;

        # Terminal configuration
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font Mono'";
        "terminal.integrated.fontSize" = 14;
        "terminal.integrated.smoothScrolling" = true;

        # Editor behavior
        "editor.lineNumbers" = "on";
        "editor.renderWhitespace" = "boundary";
        "editor.wordWrap" = "on";
        "editor.minimap.enabled" = true;
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.smoothScrolling" = true;
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "editor.autoIndentOnPaste" = true;

        # File handling
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;

        # Theme and appearance
        "workbench.colorTheme" = "2017 Dark (Visual Studio - C/C++)";
        "workbench.preferredDarkColorTheme" = "";
        "workbench.startupEditor" = "welcomePage";
        "workbench.productIconTheme" = "material-product-icons";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.activityBar.location" = "top";
        "window.commandCenter" = false;
        "workbench.list.smoothScrolling" = true;

        # Git integration
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "git.autofetch" = true;

        # Language-specific settings
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";

        # Rust configuration
        "rust-analyzer.checkOnSave.command" = "clippy";
        "rust-analyzer.cargo.allFeatures" = true;

        # Python configuration
        "python.defaultInterpreterPath" = "/usr/bin/python3";
        "python.linting.enabled" = true;
        "python.linting.pylintEnabled" = true;
        "python.formatting.provider" = "black";

        # Extension settings
        "errorLens.enabledDiagnosticLevels" = ["error" "warning" "info"];

        # Telemetry and updates - disable to prevent conflicts with Nix management
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
        "extensions.autoCheckUpdates" = false;

      };

    # Custom keybindings
    profiles.default.keybindings = [
        {
          key = "ctrl+shift+p";
          command = "workbench.action.showCommands";
        }
        {
          key = "ctrl+`";
          command = "workbench.action.terminal.toggleTerminal";
        }
      ];
  };
}
