# sops-nix Usage Guide

## Overview

sops-nix is now configured for secure secrets management in this NixOS configuration.

## Key Components

- **Age key**: Generated at `~/.config/sops/age/keys.txt`
- **Configuration**: `.sops.yaml` defines encryption rules
- **Secrets**: Stored encrypted in `secrets/` directory
- **Runtime**: Decrypted secrets available at `/run/secrets/`

## Current Setup

### Secrets Available

- `example-password`: Basic password example
- `database-url`: Database connection string
- `api-key`: API key example

### Access Patterns

```nix
# In NixOS configuration, reference secrets like:
services.postgresql = {
  enable = true;
  authentication = pkgs.lib.mkOverride 10 ''
    local all all              peer
    host  all all 127.0.0.1/32 md5
    host  all all ::1/128      md5
  '';
  initialScript = pkgs.writeText "backend-initScript" ''
    CREATE ROLE myapp WITH LOGIN PASSWORD '$(cat ${config.sops.secrets.database-url.path})';
  '';
};
```

## Common Commands

```bash
# Edit encrypted secrets
sops secrets/example.yaml

# Add new secret
sops --set '["new-secret"]' "value" secrets/example.yaml

# View decrypted content
sops --decrypt secrets/example.yaml

# Check runtime secrets (as root)
sudo ls -la /run/secrets/
sudo cat /run/secrets/example-password
```

## Adding New Secrets

1. Edit the encrypted file:
   ```bash
   sops secrets/example.yaml
   ```

2. Add the secret to NixOS configuration:
   ```nix
   sops.secrets.new-secret = {};
   ```

3. Rebuild the system:
   ```bash
   sudo nixos-rebuild switch --flake .#gtx1080shitbox
   ```

## Security Notes

- Age key is stored in user's home directory
- Runtime secrets are owned by root with restricted permissions
- Secrets are automatically decrypted at boot time
- Never commit the age key to version control