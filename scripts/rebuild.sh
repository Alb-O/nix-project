#!/usr/bin/env bash

set -euo pipefail



# Step 1: Ensure we are on an allowed branch (main, deployed, building)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "deployed" && "$CURRENT_BRANCH" != "building" ]]; then
  echo "Error: You must run this script from main, deployed, or building. (Current: $CURRENT_BRANCH)"
  exit 3
fi

if [ "$CURRENT_BRANCH" = "main" ]; then
  # On main: force-overwrite building branch and checkout building, skip auto-checkpoint
  git branch -f building main
  git checkout building
  CURRENT_BRANCH="building"
fi

# Only auto-checkpoint if not on main
if [ "$CURRENT_BRANCH" != "main" ]; then
  git add -A
  git commit -m "auto: checkpoint before build $(date -Iseconds)" || echo "No changes to commit before build."
fi

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
  if [ "$CURRENT_BRANCH" = "building" ]; then
    git branch -f deployed building
    git checkout deployed
    echo "Build and deployment commit complete. 'deployed' now matches 'building'. Checked out 'deployed'."
  elif [ "$CURRENT_BRANCH" = "deployed" ]; then
    git branch -f building deployed
    echo "Build and deployment commit complete. 'building' now matches 'deployed'."
  else
    echo "Build and deployment commit complete. 'building' updated."
  fi
else
  exit 1
fi
