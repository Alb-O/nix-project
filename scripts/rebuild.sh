#!/usr/bin/env bash

set -euo pipefail


# Step 1: Ensure we are on an allowed branch (main, deployed, building)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "deployed" && "$CURRENT_BRANCH" != "building" ]]; then
  echo "Error: You must run this script from main, deployed, or building. (Current: $CURRENT_BRANCH)"
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
  # Step 4: Force-update downstream branches
  if [ "$CURRENT_BRANCH" = "main" ]; then
    git branch -f deployed main
    git branch -f building deployed
    echo "Build and deployment commit complete. 'deployed' now matches 'main', 'building' now matches 'deployed'."
  elif [ "$CURRENT_BRANCH" = "deployed" ]; then
    git branch -f building deployed
    echo "Build and deployment commit complete. 'building' now matches 'deployed'."
  else
    echo "Build and deployment commit complete. 'building' updated."
  fi
else
  echo "Build failed. Not updating downstream branches."
  exit 1
fi
