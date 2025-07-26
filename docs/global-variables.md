# Global Variables System

## Overview

The global variables system provides a centralized way to define commonly used applications and configurations that might need to be changed across the entire NixOS configuration. This makes it easy to swap out applications system-wide without hunting through multiple files.

## Location

Global variables are defined in `lib/globals.nix` and imported throughout the configuration as needed.

## Usage

```nix
# Import in any configuration file
let
  globals = import ../lib/globals.nix;  # Adjust path as needed
in
{
  # Use global variables
  programs.${globals.shell}.enable = true;
  networking.hostName = globals.system.hostname;
  users.users.${globals.user.username} = { ... };
}
```

## Available Variables

### Applications
- `terminal` - Terminal emulator (currently: kitty)
- `browser` - Web browser (currently: firefox)  
- `fileManager` - File manager (currently: nautilus)
- `editor` - Text editor (currently: helix)
- `launcher` - Application launcher (currently: fuzzel)
- `windowManager` - Window manager/compositor (currently: niri)
- `displayManager` - Display/login manager (currently: sddm)
- `shell` - Interactive shell (currently: fish)

### Fonts & Themes
- `monoFont` - Monospace font
- `sansFont` - Sans-serif font
- `gtkTheme` - GTK theme name
- `iconTheme` - Icon theme
- `cursorTheme` - Cursor theme

### User Information
- `user.name` - Full name
- `user.username` - System username
- `user.email` - Email address
- `user.homeDirectory` - Home directory path

### System Information
- `system.hostname` - System hostname
- `system.architecture` - System architecture
- `system.stateVersion` - NixOS state version

### Common Directories
- `dirs.config` - Main config directory
- `dirs.localBin` - User's local bin directory
- `dirs.localShare` - User's local share directory
- `dirs.secrets` - Secrets directory
- `dirs.scripts` - Scripts directory

## Benefits

1. **Consistency**: All components use the same application choices
2. **Easy Changes**: Change an application once, update everywhere
3. **Documentation**: Clear overview of what's being used
4. **Maintainability**: Easier to understand and modify configuration

## Examples

### Changing Terminal Emulator

To switch from kitty to alacritty system-wide:

```nix
# In lib/globals.nix
terminal = "alacritty";  # Changed from "kitty"
```

This will automatically update:
- Desktop entries that launch terminal applications
- Any scripts that reference the terminal
- Path references to terminal-specific configurations

### Adding New Global Variables

```nix
# In lib/globals.nix
{
  # ... existing variables ...
  
  # New variables
  mediaPlayer = "vlc";
  notificationDaemon = "dunst";
  
  # New directory paths
  dirs = {
    # ... existing dirs ...
    downloads = "/home/albert/Downloads";
    documents = "/home/albert/Documents";
  };
}
```

## Current Usage

The global variables system is currently used in:
- `nixos/configuration.nix` - System-level configuration
- `home-manager/home.nix` - User environment
- `home-manager/modules/programs/default.nix` - Program configurations
- Desktop entries and wrapper scripts

## Best Practices

1. **Import at the top**: Always import globals in the `let` block
2. **Use meaningful names**: Variable names should be clear and consistent
3. **Document changes**: Update this file when adding new variables
4. **Test thoroughly**: Changes affect the entire system configuration

## Migration Guide

When adding global variables to existing configuration:

1. Add the variable to `lib/globals.nix`
2. Import globals in the configuration file
3. Replace hardcoded values with `globals.variableName`
4. Test the configuration builds successfully
5. Update documentation