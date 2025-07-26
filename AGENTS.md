# AGENTS.md

NixOS configuration with flakes, home-manager, three-branch workflow, and global variables.

## Code Style & Documentation

### Documentation Philosophy
- **Inline comments**: Technical, functional comments in Nix files, not verbose markdown
- **Brevity**: Short, precise explanations focused on function and purpose
- **No self-congratulation**: Avoid adjectives like "robust", "sophisticated", "comprehensive"
- **Technical focus**: What it does, not why it's good

### Comment Style
```nix
# Global system applications - change here to update everywhere
terminal = "kitty";

# Three-branch git workflow: main -> building -> deployed
./scripts/rebuild.sh hostname

# sops-nix: encrypted secrets via age, runtime at /run/secrets/
sops.defaultSopsFile = ../secrets/example.yaml;
```

## Architecture

### Structure
- `lib/globals.nix` - System-wide application definitions
- `nixos/` - System configuration
- `home-manager/` - User environment, modular
- `scripts/` - Build automation
- `secrets/` - sops-nix encrypted files

### Global Variables
```nix
# Import in any config file
let globals = import ../lib/globals.nix; in
{
  programs.${globals.shell}.enable = true;
  networking.hostName = globals.system.hostname;
}
```

## Build Commands

```bash
# Primary build - handles branch management, stashing, rollback
./scripts/rebuild.sh hostname

# Direct builds (bypass branch workflow)
home-manager switch --flake .#albert@gtx1080shitbox
sudo nixos-rebuild switch --flake .#gtx1080shitbox

# Utilities
./scripts/sync-scripts.sh                 # Sync scripts across branches
./scripts/find-and-clean-nixbackups.sh   # Clean .nixbackup files
```

## Three-Branch Workflow
- `main` - stable config for development
- `building` - test builds 
- `deployed` - active system

Script behavior:
- main → building → deployed (on success)
- deployed → rebuild in place → update building
- building → rebuild in place → move to deployed

## Secrets Management

```bash
# Edit encrypted secrets
sops secrets/example.yaml

# View decrypted
sops --decrypt secrets/example.yaml

# Runtime location
ls /run/secrets/
```

Configuration:
```nix
# System-level
sops = {
  defaultSopsFile = ../secrets/example.yaml;
  age.keyFile = "${globals.user.homeDirectory}/.config/sops/age/keys.txt";
  secrets.example-password = {};
};

# Access in config
systemd.services.myservice.script = "$(cat ${config.sops.secrets.example-password.path})";
```

## Development

### Workflow
1. Edit on `main` branch
2. `./scripts/rebuild.sh hostname` - handles branching, testing, deployment
3. Use global variables for system-wide changes

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