#!/usr/bin/env bash
set -euo pipefail

# Save original arguments at the very beginning
ORIGINAL_ARGS=("$@")

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
    error "Usage: $0 <hostname> [username] [--home-only] [--auto-commit]"
    echo "  hostname: Target hostname for deployment (e.g., gtx1080shitbox)"
    echo "  username: Username for home-manager (optional, defaults to current user)"
    echo "  --home-only: Only rebuild home-manager configuration (faster)"
    echo "  --auto-commit: Auto-accept geminicommit suggestions (for AI tools)"
    exit 2
fi

HOSTNAME="$1"
USERNAME="${2:-$(whoami)}"
HOME_ONLY=false
AUTO_COMMIT=false

# Parse flags - shift past hostname and optional username
shift
if [[ $# -gt 0 ]] && [[ "$1" != --* ]]; then
    shift  # Skip username if provided
fi

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

# Bootstrap git if needed
if ! command -v git &>/dev/null; then
    log "Git not found, installing with nix..."
    if command -v nix &>/dev/null; then
        # Try multiple approaches to install git
        if nix-env -iA nixpkgs.git &>/dev/null; then
            success "Git installed with nix-env"
        elif nix profile install nixpkgs#git &>/dev/null; then
            success "Git installed with nix profile"
        elif nix-shell -p git --run "nix-env -iA nixpkgs.git" &>/dev/null; then
            success "Git installed via nix-shell"
        else
            log "Standard methods failed, trying direct install..."
            nix-shell -p git --run "echo 'Git available in shell'" || {
                error "Failed to make git available. Please install git manually with:"
                echo "  sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs"
                echo "  sudo nix-channel --update"
                echo "  nix-env -iA nixpkgs.git"
                echo "Or run this script from a nix-shell with git:"
                echo "  nix-shell -p git --run './scripts/rebuild.sh nixos'"
                exit 1
            }
            # If we get here, use nix-shell for the rest of the script
            log "Git only available via nix-shell, re-executing script..."
            # Use the saved original arguments
            exec nix-shell -p git --run "$0 ${ORIGINAL_ARGS[*]}"
        fi
    else
        error "Nix not found. Please install Nix first."
        exit 1
    fi
fi

# Configure git user if not set
configure_git_user() {
    local git_name git_email
    
    # Check if git user is configured
    if ! git config user.name &>/dev/null || ! git config user.email &>/dev/null; then
        log "Git user not configured. Please provide your details:"
        
        # Get user name
        if ! git_name=$(git config user.name 2>/dev/null); then
            read -p "Enter your full name: " git_name
            git config user.name "$git_name"
        fi
        
        # Get user email  
        if ! git_email=$(git config user.email 2>/dev/null); then
            read -p "Enter your email address: " git_email
            git config user.email "$git_email"
        fi
        
        success "Git user configured as: $git_name <$git_email>"
    fi
}

# Initialize git repository if needed
if ! git rev-parse --git-dir &>/dev/null; then
    log "Not in a git repository, initializing..."
    git init
    configure_git_user
    git add .
    git commit -m "Initial commit: nix configuration setup

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    success "Git repository initialized"
else
    # Configure git user even for existing repos
    configure_git_user
fi

# Clean up legacy channels for WSL if they exist
if [[ "$HOSTNAME" == "nixos" ]]; then
    log "Cleaning up legacy nix channels for WSL..."
    sudo rm -rf /root/.nix-defexpr/channels 2>/dev/null || true
    sudo rm -rf /nix/var/nix/profiles/per-user/root/channels 2>/dev/null || true
    rm -rf ~/.nix-defexpr/channels 2>/dev/null || true
    success "Legacy channels cleaned up"
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
    if nix --extra-experimental-features 'nix-command flakes' fmt .; then
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
# Fix potential git permissions issue
chmod -R u+w .git/ 2>/dev/null || true
if nix --extra-experimental-features 'nix-command flakes' flake update; then
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
    log "Running home-manager switch --flake .#$USERNAME@$HOSTNAME"
    # Try building with extra memory settings for WSL
    if [[ "$HOSTNAME" == "nixos" ]]; then
        log "WSL detected, using memory-optimized build settings"
        export RUST_MIN_STACK=67108864
        export CARGO_BUILD_JOBS=1
        ulimit -s 65536 2>/dev/null || true  # Increase stack size limit
    fi
    if nix run github:nix-community/home-manager/master -- switch --flake .#"$USERNAME@$HOSTNAME"; then
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
