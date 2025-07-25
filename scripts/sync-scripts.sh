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

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
ALLOWED_BRANCHES=("main" "deployed" "building")

if [[ ! " ${ALLOWED_BRANCHES[*]} " =~ " $CURRENT_BRANCH " ]]; then
    error "Must run from main, deployed, or building branch (current: $CURRENT_BRANCH)"
    exit 1
fi

log "Syncing scripts from '$CURRENT_BRANCH' to other branches..."

# Track changes
updated_branches=()
failed_branches=()

# Sync to other branches
for target_branch in "${ALLOWED_BRANCHES[@]}"; do
    if [[ "$target_branch" == "$CURRENT_BRANCH" ]]; then
        continue
    fi
    
    if ! git show-ref --verify --quiet "refs/heads/$target_branch"; then
        warn "Branch '$target_branch' doesn't exist, skipping"
        continue
    fi
    
    # Check if scripts differ
    if git diff --quiet "$CURRENT_BRANCH:scripts/" "$target_branch:scripts/" 2>/dev/null; then
        log "Scripts on '$target_branch' already match, skipping"
        continue
    fi
    
    log "Updating scripts on '$target_branch'..."
    
    # Switch to target branch and update scripts
    if git checkout "$target_branch" && \
       git checkout "$CURRENT_BRANCH" -- scripts/ && \
       git add scripts/ && \
       git commit -m "auto: sync scripts from $CURRENT_BRANCH branch"; then
        updated_branches+=("$target_branch")
        success "Updated scripts on '$target_branch'"
    else
        failed_branches+=("$target_branch")
        error "Failed to update scripts on '$target_branch'"
    fi
done

# Return to original branch
if [[ "$(git rev-parse --abbrev-ref HEAD)" != "$CURRENT_BRANCH" ]]; then
    git checkout "$CURRENT_BRANCH"
fi

# Report results
if [[ ${#updated_branches[@]} -gt 0 ]]; then
    success "Successfully synced scripts to: ${updated_branches[*]}"
fi

if [[ ${#failed_branches[@]} -gt 0 ]]; then
    error "Failed to sync scripts to: ${failed_branches[*]}"
    exit 1
fi

if [[ ${#updated_branches[@]} -eq 0 && ${#failed_branches[@]} -eq 0 ]]; then
    success "All scripts are already in sync across branches"
fi