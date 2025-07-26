# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

# NixOS Configuration Repository

Personal NixOS configuration using flakes with home-manager integration, featuring a three-branch workflow for safe configuration management and global variable system for easy customization.

## Architecture Overview

### Configuration Philosophy
- **Modular design**: Separate concerns (programs, desktop, services)
- **Global variables**: Centralized application definitions in `lib/globals.nix`
- **Declarative**: All system state defined in configuration files
- **Reproducible**: Flake-based with locked dependencies
- **Secure**: Hardened configurations and secrets management

### Key Technologies
- **NixOS 25.05** stable with unstable overlay for select packages
- **Home Manager** for user environment management
- **Wayland** display server with modern compositor
- **sops-nix** for encrypted secrets management
- **Flakes** for reproducible configurations

## Global Variables System

Applications and system settings are centralized in `lib/globals.nix`:

```nix
let
  globals = import ../lib/globals.nix;
in
{
  programs.${globals.shell}.enable = true;
  networking.hostName = globals.system.hostname;
}
```

This allows easy system-wide changes (e.g., switching terminal emulators) by modifying one file.

## Three-Branch Workflow

### Branch Purpose
- **`main`** - Clean, stable configuration for development
- **`building`** - Testing branch for builds and validation
- **`deployed`** - Currently active system configuration

### Workflow Commands
```bash
# Main build command - handles all branch management automatically
./scripts/rebuild.sh <hostname>

# Additional utilities
./scripts/sync-scripts.sh                   # Sync scripts across branches
./scripts/find-and-clean-nixbackups.sh      # Clean backup files
```

The rebuild script automatically:
- Manages branch switching and stashing
- Creates checkpoint commits before builds
- Handles error recovery and rollback
- Synchronizes scripts across branches

## Configuration Structure

### System Level (`nixos/`)
- Core system configuration
- Hardware settings
- Security policies
- System services

### User Level (`home-manager/`)
- Modular user environment
- Application configurations
- Desktop environment
- User services

### Supporting Infrastructure
- **`lib/`** - Global variables and shared utilities
- **`scripts/`** - Build and maintenance automation
- **`secrets/`** - Encrypted configuration secrets
- **`docs/`** - Documentation and usage guides

## Development Workflow

### Making Changes
1. Work on `main` branch for new features/changes
2. Use `./scripts/rebuild.sh <hostname>` to test and deploy
3. Script handles branch management automatically
4. Successful builds are deployed to active system

### Best Practices
- Use global variables for system-wide settings
- Keep modules focused and single-purpose
- Test changes before committing
- Document significant changes
- Use secrets management for sensitive data

## Available Tools

### NixOS MCP Integration
Comprehensive package and configuration research tools available:

#### NixOS Tools
- `nixos_search(query, type, channel)` - Search packages, options, or programs
- `nixos_info(name, type, channel)` - Get detailed info about packages/options
- `nixos_stats(channel)` - Package and option counts
- `nixos_channels()` - List all available channels
- `nixos_flakes_search(query)` - Search community flakes
- `nixos_flakes_stats()` - Flake ecosystem statistics

#### Version History Tools
- `nixhub_package_versions(package, limit)` - Get version history with commit hashes
- `nixhub_find_version(package, version)` - Smart search for specific versions

#### Home Manager Tools
- `home_manager_search(query)` - Search user config options
- `home_manager_info(name)` - Get option details (with suggestions!)
- `home_manager_stats()` - See what's available
- `home_manager_list_options()` - Browse all 131 categories
- `home_manager_options_by_prefix(prefix)` - Explore options by prefix

#### Darwin Tools
- `darwin_search(query)` - Search macOS options
- `darwin_info(name)` - Get option details
- `darwin_stats()` - macOS configuration statistics
- `darwin_list_options()` - Browse all 21 categories
- `darwin_options_by_prefix(prefix)` - Explore macOS options

### Secrets Management
- **sops-nix** integration for encrypted secrets
- Age-based encryption with user key
- Runtime secret deployment to `/run/secrets/`
- Git-safe encrypted storage

### Build Automation
- Integrated rebuild workflow
- Automatic script synchronization
- Error recovery and rollback
- Cleanup automation

## System Capabilities

### Desktop Environment
- Modern Wayland compositor
- Secure display manager
- GTK theme integration
- Font and icon management

### Development Tools
- Multiple editors and IDEs
- Language servers and tooling
- Terminal emulators
- Version control integration

### Security Features
- Hardened browser configuration
- SSH key-only authentication
- Encrypted secrets management
- Minimal attack surface

### Hardware Support
- Modern Linux kernel
- Proprietary driver support
- Multiple filesystem compatibility
- Power management

## Troubleshooting

### Common Issues
- **Build failures**: Script provides automatic rollback
- **Configuration errors**: Check global variables and module imports
- **Secret access**: Verify sops-nix configuration and key permissions
- **Package conflicts**: Review overlays and package selections

### Recovery Tools
- Branch-based recovery via git workflow
- Automatic stashing and restoration
- System rollback capabilities
- Backup file cleanup utilities

## Customization

### Changing Applications
Modify `lib/globals.nix` to change applications system-wide:
```nix
terminal = "alacritty";  # Changes from default
```

### Adding Modules
Create new modules in appropriate directories and import in parent `default.nix`.

### Managing Secrets
Use sops to encrypt sensitive configuration:
```bash
sops secrets/example.yaml  # Edit encrypted secrets
```

This configuration provides a robust, maintainable NixOS setup with modern tooling, security features, and automated management workflows.