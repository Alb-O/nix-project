#!/usr/bin/env bash
set -euo pipefail


# Step 1: Commit to 'building' before build
if git show-ref --verify --quiet refs/heads/building; then
  git checkout building
else
  git checkout -b building
fi
git add -A
git commit -m "auto: checkpoint before build $(date -Iseconds)" || echo "No changes to commit before build."

if [ $# -lt 1 ]; then
  echo "Usage: $0 <hostname>"
  exit 2
fi
HOSTNAME="$1"

# Step 2: Clean up .nixbackup files before build
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/find-and-clean-nixbackups.sh"

USER_HOST="albert@$HOSTNAME"
# Step 3: Run the build using flake-based home-manager activation
if nix run .#homeConfigurations."$USER_HOST".activationPackage; then
  # Step 4: Commit to 'deployed' after successful build
  if git show-ref --verify --quiet refs/heads/deployed; then
    git checkout deployed
  else
    git checkout -b deployed
  fi
  git merge building --no-edit
  git add -A
  git commit -m "auto: deployed after successful build $(date -Iseconds)" || echo "No changes to commit after build."
  echo "Build and deployment commit complete."
else
  echo "Build failed. Not updating deployed."
  exit 1
fi
