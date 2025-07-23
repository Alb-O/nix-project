#!/usr/bin/env bash
set -euo pipefail


# Step 1: Commit to 'building' before build
if git show-ref --verify --quiet refs/heads/building; then
  git checkout building
else
  git checkout -b building
fi
git add -A
git commit -m "[auto] checkpoint before build $(date -Iseconds)" || echo "No changes to commit before build."

# Step 2: Run the build
if sudo nixos-rebuild switch --flake .#gtx1080shitbox; then
  # Step 3: Commit to 'deployed' after successful build
  if git show-ref --verify --quiet refs/heads/deployed; then
    git checkout deployed
  else
    git checkout -b deployed
  fi
  git merge building --no-edit
  git add -A
  git commit -m "[auto] deployed after successful build $(date -Iseconds)" || echo "No changes to commit after build."
  echo "Build and deployment commit complete."
else
  echo "Build failed. Not updating deployed."
  exit 1
fi
