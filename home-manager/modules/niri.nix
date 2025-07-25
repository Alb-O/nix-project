# Niri Home Manager Module
# Configures niri, a scrollable-tiling Wayland compositor

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland.windowManager.niri;

  # Convert a Nix attribute set to KDL format
  toKDL = value:
    if isString value then value
    else if isBool value then (if value then "true" else "false")
    else if isInt value then toString value
    else if isFloat value then toString value
    else if isNull value then "null"
    else if isList value then
      concatMapStringsSep " " toKDL value
    else if isAttrs value then
      concatStringsSep "\n" (mapAttrsToList (name: val:
        if isList val then
          concatMapStringsSep "\n" (item: "${name} ${toKDL item}") val
        else if isAttrs val then
          "${name} {\n${indent (toKDL val)}\n}"
        else
          "${name} ${toKDL val}"
      ) value)
    else toString value;

  # Indent helper function
  indent = text: concatStringsSep "\n" (map (line: "    ${line}") (splitString "\n" text));

  # Generate input section
  inputSection = optionalString (cfg.settings.input != null) ''
    input {
    ${indent (toKDL cfg.settings.input)}
    }
  '';

  # Generate output sections
  outputSections = concatStringsSep "\n\n" (mapAttrsToList (name: outputCfg: ''
    output "${name}" {
    ${indent (toKDL outputCfg)}
    }
  '') cfg.settings.outputs);

  # Generate layout section
  layoutSection = optionalString (cfg.settings.layout != null) ''
    layout {
    ${indent (toKDL cfg.settings.layout)}
    }
  '';

  # Generate binds section
  bindsSection = optionalString (cfg.settings.binds != null) ''
    binds {
    ${indent (concatStringsSep "\n" (mapAttrsToList (key: action: 
      "${key} { ${action}; }"
    ) cfg.settings.binds))}
    }
  '';

  # Generate animations section
  animationsSection = optionalString (cfg.settings.animations != null) ''
    animations {
    ${indent (toKDL cfg.settings.animations)}
    }
  '';

  # Generate window rules
  windowRules = concatStringsSep "\n\n" (map (rule: ''
    window-rule {
    ${indent (toKDL rule)}
    }
  '') cfg.settings.windowRules);

  # Generate spawn-at-startup commands
  spawnCommands = concatStringsSep "\n" (map (cmd: ''spawn-at-startup "${cmd}"'') cfg.settings.spawnAtStartup);

  # Generate the complete configuration
  configFile = ''
    ${optionalString (cfg.settings.input != null) inputSection}

    ${optionalString (cfg.settings.outputs != {}) outputSections}

    ${optionalString (cfg.settings.layout != null) layoutSection}

    ${optionalString (cfg.settings.spawnAtStartup != []) spawnCommands}

    ${optionalString (cfg.settings.animations != null) animationsSection}

    ${optionalString (cfg.settings.windowRules != []) windowRules}

    ${optionalString (cfg.settings.binds != null) bindsSection}

    ${optionalString (cfg.settings.screenshotPath != null) ''screenshot-path "${cfg.settings.screenshotPath}"''}

    ${cfg.extraConfig}
  '';

in

{
  options.wayland.windowManager.niri = {
    enable = mkEnableOption "niri, a scrollable-tiling Wayland compositor";

    package = mkOption {
      type = types.package;
      default = pkgs.niri;
      description = "The niri package to use.";
    };

    settings = mkOption {
      type = types.submodule {
        options = {
          input = mkOption {
            type = types.nullOr (types.attrsOf types.anything);
            default = null;
            description = "Input device configuration.";
            example = {
              keyboard = {
                xkb = {
                  layout = "us";
                  options = "ctrl:nocaps";
                };
                numlock = true;
              };
              touchpad = {
                tap = true;
                natural-scroll = true;
              };
            };
          };

          outputs = mkOption {
            type = types.attrsOf (types.attrsOf types.anything);
            default = {};
            description = "Output (monitor) configurations keyed by output name.";
            example = {
              "eDP-1" = {
                mode = "1920x1080@60";
                scale = 1.5;
                position = { x = 0; y = 0; };
              };
            };
          };

          layout = mkOption {
            type = types.nullOr (types.attrsOf types.anything);
            default = null;
            description = "Layout configuration for windows and gaps.";
            example = {
              gaps = 16;
              center-focused-column = "never";
              default-column-width = { proportion = 0.5; };
              focus-ring = {
                width = 4;
                active-color = "#7fc8ff";
                inactive-color = "#505050";
              };
            };
          };

          binds = mkOption {
            type = types.nullOr (types.attrsOf types.str);
            default = null;
            description = "Key bindings configuration.";
            example = {
              "Mod+T" = ''spawn "alacritty"'';
              "Mod+Q" = "close-window";
              "Mod+Left" = "focus-column-left";
              "Mod+Right" = "focus-column-right";
            };
          };

          animations = mkOption {
            type = types.nullOr (types.attrsOf types.anything);
            default = null;
            description = "Animation settings.";
            example = {
              slowdown = 1.0;
            };
          };

          windowRules = mkOption {
            type = types.listOf (types.attrsOf types.anything);
            default = [];
            description = "Window rules for specific applications.";
            example = [
              {
                match = { app-id = "firefox"; };
                open-floating = true;
              }
            ];
          };

          spawnAtStartup = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Commands to spawn at startup.";
            example = [ "waybar" "swaybg -i ~/wallpaper.jpg" ];
          };

          screenshotPath = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Path where screenshots are saved.";
            example = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
          };
        };
      };
      default = {};
      description = "Niri configuration settings.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration lines to add to the niri config file.";
      example = ''
        prefer-no-csd

        debug {
            dbus-interfaces-in-non-session-instances
        }
      '';
    };

    systemd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable niri-session.target on niri startup.";
      };

      variables = mkOption {
        type = types.listOf types.str;
        default = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "SWAYSOCK"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "NIXOS_OZONE_WL"
          "_JAVA_AWT_WM_NONREPARENTING"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
        ];
        description = "Environment variables to be imported in the systemd & D-Bus user environment.";
      };

      extraCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Extra commands to be run after D-Bus activation.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."niri/config.kdl" = {
      text = configFile;
    };

    systemd.user.targets.niri-session = mkIf cfg.systemd.enable {
      Unit = {
        Description = "niri compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    systemd.user.services.niri-session = mkIf cfg.systemd.enable {
      Unit = {
        Description = "Import environment variables and start systemd user session for niri";
        Documentation = [ "man:systemd.special(7)" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = [
          "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${concatStringsSep " " cfg.systemd.variables}"
          "${pkgs.systemd}/bin/systemctl --user start niri-session.target"
        ] ++ optional (cfg.systemd.extraCommands != "") cfg.systemd.extraCommands;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}