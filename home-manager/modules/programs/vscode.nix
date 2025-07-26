# VSCode configuration with declarative settings management
{pkgs, ...}: {
  programs.vscode = {
    enable = true;

    # Use profiles for declarative configuration
    profiles.default = {
      # Enable automatic updates and extension checks
      enableUpdateCheck = true;
      enableExtensionUpdateCheck = true;

      # Core extensions for development - using only basic, commonly available extensions
      #
      # Troubleshooting checklist:
      # - Always launch VSCode from Nix (e.g., 'nix run nixpkgs#vscode' or from your system packages)
      # - Ensure the nix-vscode-extensions overlay is first in overlays (see overlays/default.nix)
      # - If only the last extension is installed, try moving the extensions block or updating Home Manager
      # - For unfree extensions (Copilot, Claude, etc.), ensure allowUnfree = true in pkgs config
      # - If extensions still do not appear, try rebooting or clearing VSCode's extension cache
      extensions = with pkgs.vscode-marketplace; [
        # Language support
        ms-python.python
        rust-lang.rust-analyzer
        jnoortheen.nix-ide

        # Git integration
        eamodio.gitlens

        # Productivity and diagnostics
        usernamehw.errorlens

        # AI and code assistance
        anthropic.claude-code
        github.copilot
        github.copilot-chat

        # Icons
        pkief.material-icon-theme
        pkief.material-product-icons
      ];

      # Declarative settings.json configuration
      userSettings = {
        # Font configuration - JetBrains Mono Nerd Font
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;

        # Terminal font configuration
        "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font Mono'";
        "terminal.integrated.fontSize" = 14;

        # Editor behavior
        "editor.lineNumbers" = "on";
        "editor.renderWhitespace" = "boundary";
        "editor.tabSize" = 2;
        "editor.insertSpaces" = false;
        "editor.detectIndentation" = false;
        "editor.wordWrap" = "on";
        "editor.minimap.enabled" = true;
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";
        "editor.smoothScrolling" = true;
        "editor.formatOnSave" = true;

        # File handling
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "files.trimTrailingWhitespace" = true;
        "files.insertFinalNewline" = true;

        # Theme and appearance
        "workbench.colorTheme" = "Default Dark+";
        "workbench.startupEditor" = "welcomePage";
        "workbench.productIconTheme" = "material-product-icons";
        "workbench.iconTheme" = "material-icon-theme";

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

        # Performance and telemetry
        "telemetry.telemetryLevel" = "off";
        "update.mode" = "none";
        "extensions.autoUpdate" = false;
      };

      # Custom keybindings
      keybindings = [
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
  };
}
