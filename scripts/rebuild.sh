#!/usr/bin/env bash
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}" >&2
}

# Validate arguments
if [[ $# -lt 1 ]]; then
    error "Usage: $0 <hostname>"
    echo "  hostname: Target hostname for deployment (e.g., gtx1080shitbox)"
    exit 2
fi

HOSTNAME="$1"

# Check if we're in the right directory structure
if [[ ! -d "nix" ]]; then
    error "Must run from the root of nix-config (where nix/ directory exists)"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir &>/dev/null; then
    error "Not in a git repository"
    exit 1
fi

# Change to nix directory for the build
cd nix

log "NixOS rebuild starting for $HOSTNAME..."

# Check if there are any changes to commit
if git diff-index --quiet HEAD -- 2>/dev/null; then
    log "No changes to commit, proceeding with rebuild"
    COMMIT_MADE=false
else
    log "Changes detected, creating amendme commit..."

    # Create the amendme commit
    git add -A
    git commit -m "amendme: auto-commit before rebuild $(date -Iseconds)"
    COMMIT_MADE=true
    success "Created amendme commit"
fi

# Run the build and capture the exit code
log "Running nixos-rebuild switch --flake .#$HOSTNAME"
if sudo nixos-rebuild switch --flake .#"$HOSTNAME"; then
    success "NixOS rebuild completed successfully!"
    exit 0
else
    BUILD_EXIT_CODE=$?
    error "NixOS rebuild failed!"

    # If we made a commit, undo it
    if [[ "$COMMIT_MADE" == "true" ]]; then
        log "Undoing amendme commit due to build failure..."
        git reset --soft HEAD~1
        success "Amendme commit undone - changes are back in working directory"
    fi

    exit $BUILD_EXIT_CODE
fi
