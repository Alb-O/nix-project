#!/usr/bin/env bash

set -euo pipefail

# Step 1: Ensure we are on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Error: You must run this script from the main branch. (Current: $CURRENT_BRANCH)"
  exit 3
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
  # Step 4: Force-update building and deployed to match main
  git branch -f building main
  git branch -f deployed main
  echo "Build and deployment commit complete. Branches 'building' and 'deployed' now match 'main'."
else
  echo "Build failed. Not updating deployed/building."
  exit 1
fi
