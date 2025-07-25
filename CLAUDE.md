# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# NixOS Configuration Repository

Personal NixOS configuration using flakes with home-manager integration, featuring a three-branch workflow for safe configuration management.

## Repository Structure

### Core Configuration Files

- **`flake.nix`** - Main flake configuration defining inputs, outputs, and system/home-manager configurations
- **`nixos/configuration.nix`** - System-wide NixOS configuration
- **`nixos/hardware-configuration.nix`** - Hardware-specific configuration (auto-generated)
- **`home-manager/home.nix`** - User environment configuration via home-manager
- **`home-manager/modules/firefox.nix`** - Firefox-specific configuration module with security hardening

### Directory Structure

```
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Flake dependency lockfile
├── nixos/
│   ├── configuration.nix        # System configuration
│   └── hardware-configuration.nix # Hardware configuration
├── home-manager/
│   ├── home.nix                 # Home-manager configuration
│   └── modules/
│       └── firefox.nix          # Firefox module
├── overlays/
│   └── default.nix              # Package overlays
├── pkgs/
│   └── default.nix              # Custom packages (currently empty)
└── scripts/
    ├── rebuild.sh               # Main rebuild script
    ├── sync-scripts.sh          # Script synchronization utility
    └── find-and-clean-nixbackups.sh # Cleanup utility
```

## Configuration Architecture

### Flake Configuration

The flake uses NixOS 25.05 stable as the base with nixpkgs-unstable overlay for bleeding-edge packages:

- **System**: `gtx1080shitbox` (AMD-based system with NVIDIA GPU)
- **User**: `albert@gtx1080shitbox`
- **Architecture**: x86_64-linux

### Key Features

1. **Integrated home-manager**: System configuration includes home-manager for user environment
2. **Overlays**: Support for unstable packages, custom packages, and NUR
3. **Security hardening**: Comprehensive Firefox security configuration
4. **Wayland setup**: Uses Niri window manager with SDDM display manager
5. **Development tools**: Includes Helix editor, VSCode, and claude-code

### System Configuration Highlights

- **Boot**: systemd-boot with EFI support
- **Kernel**: Latest Linux kernel with NVIDIA proprietary drivers  
- **Display**: Wayland with Niri compositor, SDDM login manager
- **Security**: Passwordless sudo for wheel users, SSH with key-only authentication
- **Fonts**: JetBrains Mono Nerd Font, Noto fonts with emoji support

### Home Manager Configuration

- **Shell**: Fish shell with Kitty terminal
- **Theme**: Adwaita dark theme with dark color scheme preference
- **Applications**: Firefox with extensive security policies, 1Password integration
- **Services**: swww wallpaper daemon, 1Password GUI auto-start

## Three-Branch Workflow

This repository implements a sophisticated three-branch workflow for safe configuration management:

### Branch Structure

1. **`main`** - Clean, stable configuration
2. **`building`** - Testing branch for builds
3. **`deployed`** - Currently active configuration

### Workflow Process

The `rebuild.sh` script manages the entire workflow:

1. **Starting from `main`**: Creates/updates `building` branch, performs build there
2. **Starting from `deployed`**: Rebuilds in place, creates checkpoint commits
3. **Starting from `building`**: Rebuilds in place, moves to `deployed` on success

### Build Script Features

- **Automatic stashing**: Handles uncommitted changes safely
- **Checkpoint commits**: Creates timestamped commits before builds
- **Error recovery**: Returns to original branch on failure
- **Cleanup integration**: Automatically removes .nixbackup files
- **Script synchronization**: Keeps scripts consistent across branches

## Essential Commands

### Building and Deployment

```bash
# Build and deploy configuration
./scripts/rebuild.sh gtx1080shitbox

# Build with automatic backup cleanup
./scripts/rebuild.sh gtx1080shitbox --auto-clean

# Apply home-manager configuration directly
home-manager switch --flake .#albert@gtx1080shitbox

# Rebuild NixOS system configuration
sudo nixos-rebuild switch --flake .#gtx1080shitbox
```

### Script Management

```bash
# Sync scripts across all branches
./scripts/sync-scripts.sh

# Clean up .nixbackup files interactively  
./scripts/find-and-clean-nixbackups.sh

# Clean up .nixbackup files automatically
./scripts/find-and-clean-nixbackups.sh --auto
```

### Firefox Management

```bash
# Reset Firefox to NixOS-managed state
firefox-reset-nixos
```

### MCP NixOS Tools

This repository has access to comprehensive NixOS MCP server tools for package and configuration research:

```bash
# Search for packages, options, or programs
mcp__nixos__nixos_search(query="firefox", search_type="packages", channel="unstable")

# Get detailed package information
mcp__nixos__nixos_info(name="firefox", type="package", channel="unstable")

# Search Home Manager configuration options
mcp__nixos__home_manager_search(query="programs.firefox")

# Get specific Home Manager option details
mcp__nixos__home_manager_info(name="programs.firefox.enable")

# Find package version history with commit hashes
mcp__nixos__nixhub_package_versions(package_name="firefox", limit=10)

# Search community flakes
mcp__nixos__nixos_flakes_search(query="firefox")
```

## Scripts

### `rebuild.sh <hostname> [--auto-clean]`

Primary build and deployment script with comprehensive error handling:

- Validates git state and current branch (must be main/building/deployed)
- Manages branch switching and updates
- Creates checkpoint commits with timestamps
- Runs home-manager configuration builds via flake
- Synchronizes scripts across branches automatically
- Updates branch relationships on successful builds

**Branch behavior**:
- From `main` → switches to `building`, updates `deployed` to match on success
- From `deployed` → rebuilds in place, updates `building` to match
- From `building` → rebuilds in place, moves to `deployed` on success

**Error recovery**: Automatically restores stashed changes and returns to original branch on failure.

### `sync-scripts.sh`

Synchronizes the `scripts/` directory across all three branches:
- Detects script changes between branches
- Automatically commits synchronized scripts
- Ensures consistency across the workflow

### `find-and-clean-nixbackups.sh [--auto]`

Cleans up .nixbackup files created by home-manager:
- Scans home directory for backup files
- Interactive or automatic cleanup modes
- Excludes common directories (.git, node_modules, .cache)

## Package Management

### Overlays (`overlays/default.nix`)

- **additions**: Custom packages from the `pkgs/` directory
- **modifications**: Package overrides and patches
- **unstable-packages**: Access to nixpkgs-unstable via `pkgs.unstable`
- **nur**: Nix User Repository integration

### Available MCP Tools

The repository provides access to comprehensive NixOS research tools:

- **Package search**: `mcp__nixos__nixos_search()` for packages, options, programs
- **Package details**: `mcp__nixos__nixos_info()` with version and dependency information
- **Version history**: `mcp__nixos__nixhub_package_versions()` with nixpkgs commit hashes
- **Home Manager**: `mcp__nixos__home_manager_search()` and `mcp__nixos__home_manager_info()`
- **Community flakes**: `mcp__nixos__nixos_flakes_search()` for third-party packages
- **Channel information**: `mcp__nixos__nixos_channels()` and `mcp__nixos__nixos_stats()`

### System Packages

- **Editors**: Helix, VSCode
- **Terminal**: Kitty with JetBrains Mono font
- **Applications**: Firefox, 1Password, Fuzzel launcher
- **Development**: claude-code from unstable

### Home Manager Packages

- **Wayland**: swww wallpaper daemon, luakit browser
- **Development**: nil and nixd LSP servers for Nix
- **Tools**: claude-code from unstable channel

## Security Configuration

### Firefox Hardening

The Firefox module (`home-manager/modules/firefox.nix`) implements comprehensive security policies:

- **Disabled features**: Telemetry, studies, Pocket, form history, master password creation
- **Privacy**: Tracking protection, fingerprinting protection, email tracking protection
- **Extensions**: Force-installed uBlock Origin, Dark Reader, SponsorBlock, 1Password
- **Settings**: HTTPS-only mode, disabled password manager (1Password used instead)
- **UI**: Vertical tabs, sidebar visibility always-show, custom toolbar layout
- **Reset utility**: `firefox-reset-nixos` command removes cache/state files to ensure NixOS settings take priority

### System Security

- **SSH**: Key-only authentication, root login disabled
- **Sudo**: Passwordless for wheel users
- **Boot**: Secure boot compatible systemd-boot
- **Drivers**: Proprietary NVIDIA drivers with proper kernel parameters

## Hardware Support

- **CPU**: AMD with microcode updates
- **GPU**: NVIDIA GTX 1080 with proprietary drivers
- **Storage**: NTFS support for external drives
- **Boot**: EFI with systemd-boot
- **File systems**: ext4 root, vfat boot, swap partition

## Development Workflow

### Making Changes

1. Work on the `main` branch for configuration changes
2. Use `./scripts/rebuild.sh gtx1080shitbox` to test changes
3. Script automatically handles branch management
4. Successful builds update the `deployed` branch

### Script Development

1. Modify scripts on any branch
2. `sync-scripts.sh` automatically runs during rebuilds
3. Scripts stay synchronized across all branches

### Troubleshooting

- **Build failures**: Script automatically returns to original branch and restores stashed changes
- **Inconsistent scripts**: `sync-scripts.sh` runs automatically during builds or can be run manually
- **Backup files**: Use `find-and-clean-nixbackups.sh` to clean .nixbackup files created by home-manager
- **Firefox issues**: Use `firefox-reset-nixos` command to reset to NixOS-managed state
- **Git hooks**: Custom hooks in `.githooks/` automatically sync scripts on commits
- **Branch workflow**: Only work from main/building/deployed branches - script validates this

## Current State

- **Active branch**: `deployed` 
- **System**: `gtx1080shitbox` with AMD CPU and NVIDIA GPU
- **User**: `albert` with comprehensive home-manager configuration
- **Recent activity**: Regular checkpoint commits with build timestamps

This configuration provides a robust, secure, and maintainable NixOS setup with a sophisticated deployment workflow suitable for both development and production use.