# NIX PROJECT

My NixOS configuration. Under construction.

# Multi-User Nix Configuration Setup

This configuration now supports multiple users through a flexible parameter-based system.

## How It Works

### User Configuration
Users are defined in `lib/users.nix`:
```nix
{
  albert = {
    name = "Albert O'Shea";
    username = "albert";
    email = "albertoshea2@gmail.com";
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
- `hostname`: Target hostname (defaults to "gtx1080shitbox")
- `architecture`: System architecture (defaults to "x86_64-linux")
- `stateVersion`: NixOS state version (defaults to "25.05")

### Available Configurations
The flake automatically generates home-manager configurations for each user and hostname combination:
- `albert@gtx1080shitbox` (existing)
- `alice@gtx1080shitbox` (if alice is added to users.nix)

## Usage

### Using the Rebuild Script
The rebuild script now accepts an optional username parameter:
```bash
# Use default user (current system user)
./scripts/rebuild.sh gtx1080shitbox --home-only

# Specify a user
./scripts/rebuild.sh gtx1080shitbox alice --home-only

# With additional flags
./scripts/rebuild.sh gtx1080shitbox bob --home-only --auto-commit
```

### Manual Home Manager
```bash
nix run github:nix-community/home-manager/master -- switch --flake .#alice@gtx1080shitbox
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
  (mkConfigs "gtx1080shitbox")
  // (mkConfigs "laptop")
  // (mkConfigs "server");
```