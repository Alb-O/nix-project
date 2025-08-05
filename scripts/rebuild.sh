#!/usr/bin/env bash
set -euo pipefail

# Load environment variables from .env file if it exists
if [[ -f .env ]]; then
    set -a  # automatically export all variables
    source .env
    set +a  # disable automatic export
fi

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
    error "Usage: $0 <hostname> [--home-only] [--auto-commit]"
    echo "  hostname: Target hostname for deployment (e.g., gtx1080shitbox)"
    echo "  --home-only: Only rebuild home-manager configuration (faster)"
    echo "  --auto-commit: Auto-accept geminicommit suggestions (for AI tools)"
    exit 2
fi

HOSTNAME="$1"
HOME_ONLY=false
AUTO_COMMIT=false

# Parse flags
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --home-only)
            HOME_ONLY=true
            ;;
        --auto-commit)
            AUTO_COMMIT=true
            ;;
        *)
            error "Unknown flag: $1"
            exit 2
            ;;
    esac
    shift
done

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

if [[ "$HOME_ONLY" == "true" ]]; then
    log "Home-manager rebuild starting for $HOSTNAME..."
else
    log "NixOS rebuild starting for $HOSTNAME..."
fi

# Check if there are any changes to commit
if git diff-index --quiet HEAD -- 2>/dev/null; then
    log "No changes to commit, proceeding with rebuild"
    COMMIT_MADE=false
else
    log "Changes detected, formatting Nix files before commit..."

    # Format all Nix files
    if nix fmt .; then
        success "Nix files formatted"
    else
        log "Nix formatting failed, continuing anyway..."
    fi

    log "Creating amendme commit..."

    # Create the amendme commit
    git add -A
    git commit -m "amendme: auto-commit before rebuild $(date -Iseconds)"
    COMMIT_MADE=true
    success "Created amendme commit"
fi

# Function to get package versions
get_package_versions() {
    if [[ "$HOME_ONLY" == "true" ]]; then
        nix-store --query --references ~/.nix-profile 2>/dev/null | \
        sed -n 's|.*/\([^/]*\)-\([0-9][^/]*\)$|\1 \2|p' | \
        sort -u || true
    else
        nix-store --query --references /run/current-system 2>/dev/null | \
        sed -n 's|.*/\([^/]*\)-\([0-9][^/]*\)$|\1 \2|p' | \
        sort -u || true
    fi
}

# Update flake inputs to get latest packages
log "Updating flake inputs to get latest packages..."
if nix flake update; then
    success "Flake inputs updated successfully"
else
    error "Failed to update flake inputs, continuing anyway..."
fi

# Capture package versions before rebuild
log "Capturing current package versions..."
BEFORE_VERSIONS=$(mktemp)
get_package_versions > "$BEFORE_VERSIONS"

# Run the build and capture the exit code
if [[ "$HOME_ONLY" == "true" ]]; then
    log "Running home-manager switch --flake .#albert@$HOSTNAME"
    if nix run github:nix-community/home-manager/master -- switch --flake .#"albert@$HOSTNAME"; then
        success "Home-manager rebuild completed successfully!"
    else
        BUILD_EXIT_CODE=$?
        error "Home-manager rebuild failed!"
    fi
else
    log "Running nixos-rebuild switch --flake .#$HOSTNAME"
    if sudo nixos-rebuild switch --upgrade-all --flake .#"$HOSTNAME"; then
        success "NixOS rebuild completed successfully!"
    else
        BUILD_EXIT_CODE=$?
        error "NixOS rebuild failed!"
    fi
fi

# Show package version changes if build succeeded
if [[ ${BUILD_EXIT_CODE:-0} -eq 0 ]]; then
    log "Checking for package version updates..."
    AFTER_VERSIONS=$(mktemp)
    get_package_versions > "$AFTER_VERSIONS"
    
    # Compare versions and show updates
    UPDATES=$(comm -13 <(sort "$BEFORE_VERSIONS") <(sort "$AFTER_VERSIONS") | \
              while IFS=' ' read -r pkg new_ver; do
                  old_ver=$(grep "^$pkg " "$BEFORE_VERSIONS" | cut -d' ' -f2- || echo "new")
                  if [[ "$old_ver" != "new" ]] && [[ "$old_ver" != "$new_ver" ]]; then
                      echo "$pkg: $old_ver → $new_ver"
                  elif [[ "$old_ver" == "new" ]]; then
                      echo "$pkg: new → $new_ver"
                  fi
              done)
    
    if [[ -n "$UPDATES" ]]; then
        echo -e "\n${YELLOW}Package Updates:${NC}"
        echo "$UPDATES"
    else
        log "No package version changes detected"
    fi
    
    # Cleanup temp files
    rm -f "$BEFORE_VERSIONS" "$AFTER_VERSIONS"
fi

# Handle success/failure
if [[ ${BUILD_EXIT_CODE:-0} -eq 0 ]]; then
    # Generate improved commit message if we made a commit
    if [[ "$COMMIT_MADE" == "true" ]]; then
        log "Generating improved commit message with geminicommit..."
        # Configure geminicommit API key if available
        if [[ -n "${GEMINI_API_KEY:-}" ]]; then
            gmc config key set "$GEMINI_API_KEY" || log "Failed to set geminicommit API key"
        fi
        # Reset the commit to staged changes, then use geminicommit to recommit
        git reset --soft HEAD~1
        if [[ "$AUTO_COMMIT" == "true" ]]; then
            gmc -y || { log "geminicommit failed, creating fallback commit..."; git commit -m "chore: auto-commit rebuild $(date -Iseconds)" || true; }
        else
            gmc || { log "geminicommit failed, creating fallback commit..."; git commit -m "chore: auto-commit rebuild $(date -Iseconds)" || true; }
        fi
        success "Commit message improved with geminicommit"
    fi

    exit 0
else
    # If we made a commit, undo it
    if [[ "$COMMIT_MADE" == "true" ]]; then
        log "Undoing amendme commit due to build failure..."
        git reset --soft HEAD~1
        success "Amendme commit undone - changes are back in working directory"
    fi

    exit $BUILD_EXIT_CODE
fi
