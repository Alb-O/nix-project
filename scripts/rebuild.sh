#!/usr/bin/env bash

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
ORIGINAL_BRANCH=""
STASH_CREATED=false
STASH_NAME=""

# Cleanup function for error recovery
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo -e "${RED}Build failed. Attempting recovery...${NC}" >&2
        
        # Return to original branch first if needed
        local current_branch
        current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
        if [[ -n "$ORIGINAL_BRANCH" && "$ORIGINAL_BRANCH" != "$current_branch" ]]; then
            echo -e "${YELLOW}Returning to original branch: $ORIGINAL_BRANCH${NC}" >&2
            git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
        fi
        
        # Restore stash if we created one (now on correct branch)
        if [[ "$STASH_CREATED" == "true" && -n "$STASH_NAME" ]]; then
            echo -e "${YELLOW}Restoring stashed changes...${NC}" >&2
            if git stash list | grep -q "$STASH_NAME"; then
                local stash_num
                stash_num=$(git stash list | grep -n "$STASH_NAME" | cut -d: -f1 | head -1)
                if [[ -n "$stash_num" ]]; then
                    git stash pop "stash@{$((stash_num-1))}" 2>/dev/null || true
                fi
            fi
        fi
    fi
}

trap cleanup EXIT

log() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# Check if we're in a git repository
if ! git rev-parse --git-dir &>/dev/null; then
    error "Not in a git repository"
    exit 1
fi

# Validate arguments
if [[ $# -lt 1 ]]; then
    error "Usage: $0 <hostname> [--auto-clean]"
    echo "  hostname: Target hostname for deployment"
    echo "  --auto-clean: Automatically clean .nixbackup files without prompting"
    exit 2
fi

HOSTNAME="$1"
AUTO_CLEAN=false
if [[ "${2:-}" == "--auto-clean" ]]; then
    AUTO_CLEAN=true
fi

# Step 1: Validate current branch and git state
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
ALLOWED_BRANCHES=("main" "deployed" "building")

if [[ ! " ${ALLOWED_BRANCHES[*]} " =~ " $ORIGINAL_BRANCH " ]]; then
    error "You must run this script from main, deployed, or building. (Current: $ORIGINAL_BRANCH)"
    exit 3
fi

log "Starting rebuild from branch: $ORIGINAL_BRANCH"

# Step 2: Handle uncommitted changes
if ! git diff-index --quiet HEAD --; then
    STASH_NAME="nixos-rebuild-$(date +%s)"
    log "Stashing uncommitted changes as: $STASH_NAME"
    git stash push -m "$STASH_NAME"
    STASH_CREATED=true
fi

# Step 3: Branch workflow management - Always build on building branch
TARGET_BRANCH="building"

if [[ "$ORIGINAL_BRANCH" == "main" ]]; then
    log "On main branch, switching to building for rebuild"
    
    # Ensure building branch exists and is up to date with main
    if git show-ref --verify --quiet "refs/heads/building"; then
        git branch -f building main
    else
        git branch building main
    fi
    
    git checkout building
    
    # Restore stashed changes from main to building branch
    if [[ "$STASH_CREATED" == "true" ]]; then
        log "Restoring stashed changes from main to building branch"
        git stash pop
        STASH_CREATED=false
    fi
elif [[ "$ORIGINAL_BRANCH" == "deployed" ]]; then
    log "On deployed branch, switching to building for rebuild"
    
    # Create building branch from deployed
    git branch -f building deployed
    git checkout building
    
    # Restore stash for rebuild if we created one
    if [[ "$STASH_CREATED" == "true" ]]; then
        log "Restoring changes to building branch"
        git stash pop
        STASH_CREATED=false
    fi
else
    log "On building branch, rebuilding in place"
    
    # Restore stash for checkpoint if we created one
    if [[ "$STASH_CREATED" == "true" ]]; then
        log "Restoring changes for checkpoint commit"
        git stash pop
        STASH_CREATED=false
    fi
fi

# Step 4: Create checkpoint commit (if there are changes)
if ! git diff-index --quiet HEAD --; then
    git add -A
    if git commit -m "auto: checkpoint before build $(date -Iseconds)"; then
        success "Created checkpoint commit"
    fi
fi

# Step 5: Clean up .nixbackup files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$AUTO_CLEAN" == "true" ]]; then
    "$SCRIPT_DIR/find-and-clean-nixbackups.sh" --auto
else
    "$SCRIPT_DIR/find-and-clean-nixbackups.sh"
fi

# Step 6: Run the build
USER_HOST="albert@$HOSTNAME"
log "Building configuration for: $USER_HOST"

if ! nix run ./nix#homeConfigurations."$USER_HOST".activationPackage; then
    error "Build failed on 'building' branch"
    error "Fix the issues and try again. Staying on 'building' branch for debugging."
    exit 1
fi

success "Build completed successfully"

# Step 7: Sync scripts across branches if this is a script update
if ! git diff --quiet HEAD~1 -- scripts/ 2>/dev/null || [[ "$ORIGINAL_BRANCH" == "main" ]]; then
    log "Script changes detected, syncing across branches..."
    if ! "$SCRIPT_DIR/sync-scripts.sh"; then
        warn "Script sync failed, but continuing with build"
    fi
fi

# Step 8: Update branch workflow after successful build (always on building branch)
if [[ "$ORIGINAL_BRANCH" == "main" ]]; then
    # Coming from main: stay on building, update deployed to match
    git branch -f deployed building
    log "Updated 'deployed' to match 'building'"
    success "Rebuild complete. Staying on 'building' branch."
elif [[ "$ORIGINAL_BRANCH" == "deployed" ]]; then
    # Coming from deployed: update deployed and switch back to it
    git branch -f deployed building
    git checkout deployed
    log "Updated 'deployed' with successful build from 'building'"
    success "Rebuild complete. Switched back to 'deployed' branch."
else
    # Was already on building: update deployed and switch to it
    git branch -f deployed building
    git checkout deployed
    success "Rebuild complete. Switched to 'deployed' branch."
fi

# Clear trap since we succeeded
trap - EXIT
success "NixOS configuration deployed successfully!"
# Test change
