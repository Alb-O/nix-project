# NIX PROJECT

My NixOS configuration. Under construction.

# Multi-User Nix Configuration Setup

This configuration supports multiple users through a parameter-based system.

## How It Works

### User Configuration
Users are defined in `lib/users.nix`:
```nix
{
  john = {
    name = "John Smith";
    username = "john";
    email = "john@example.com";
  };

  # Add more users here
  alice = {
    name = "Alice Smith";
    username = "alice";
    email = "alice@example.com";
  };
}
```

### Global Configuration
The `lib/globals.nix` file now accepts parameters:
- `username`: The system username
- `name`: Full display name
- `email`: User email address
- `hostname`: Target hostname
- `architecture`: System architecture (defaults to "x86_64-linux")
- `stateVersion`: NixOS state version (defaults to "25.05")

### Available Configurations
The flake automatically generates home-manager configurations for each user and hostname combination:
- `john@host` (existing)
- `alice@host` (if alice is added to users.nix)

## Usage

### Using the Rebuild Script
The rebuild script now accepts an optional username parameter:
```bash
# Use default user (current system user)
./scripts/rebuild.sh host --home-only

# Specify a user
./scripts/rebuild.sh host alice --home-only

# With additional flags
./scripts/rebuild.sh host bob --home-only --auto-commit
```

### Manual Home Manager
```bash
nix run github:nix-community/home-manager/master -- switch --flake .#alice@host
```

## Adding New Users

1. Add user to `lib/users.nix`
2. Configuration will be automatically available as `username@hostname`
3. Use rebuild script with the new username

## Adding New Hostnames

To support additional hostnames, modify the `homeConfigurations` section in `flake.nix`:
```nix
homeConfigurations =
  # Merge configurations for multiple hostnames
  (mkConfigs "host")
  // (mkConfigs "laptop")
  // (mkConfigs "server");
```

## Git Bootstrap and Secrets

This repo uses a two-stage git config for full declarativity and security:

- On first bootstrap (before secrets are available), git is configured with a generic identity:
  - `Bootstrap User <bootstrap@example.com>`
- As soon as sops secrets are available, the real identity is set automatically from secrets.
- No personal info is ever stored in the repo or config.
- This is handled by the activation script in `nix/home-manager/modules/git.nix`.

**You do not need to manually run `git config` or store your info in the repo.**

If you see commits from the bootstrap identity, you can amend them after secrets are available.
