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

# Function to generate commit message with Gemini
generate_commit_message() {
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        log "GEMINI_API_KEY not set, keeping original commit message"
        return 1
    fi
    
    log "Generating improved commit message with Gemini (using extensive context)..."
    
    # Get the current commit diff with full context
    local commit_diff
    commit_diff=$(git show HEAD --no-merges --stat --patch)
    
    # Get extensive commit history (last 50 commits with full diffs)
    local commit_history
    commit_history=$(git log --oneline -50 HEAD~1)
    
    # Get detailed diffs for recent commits (last 10 commits with patches)
    local recent_diffs
    recent_diffs=$(git log -10 HEAD~1 --stat --patch --no-merges)
    
    # Get file structure context
    local file_structure
    file_structure=$(find . -name "*.nix" -o -name "*.md" -o -name "*.sh" -o -name "*.yaml" -o -name "*.json" | head -100 | sort)
    
    # Get current branch and repo info
    local branch_info
    branch_info=$(git branch -vv 2>/dev/null || echo "Branch info unavailable")
    
    # Get repository statistics
    local repo_stats
    repo_stats=$(git log --oneline | wc -l 2>/dev/null || echo "0")
    
    # Create comprehensive prompt with maximum context
    local prompt="You are an expert at writing conventional commit messages for NixOS configurations. 

Based on all the context below, write a single, concise conventional commit message that accurately describes the current changes.

RULES:
- Use conventional commit format: type(scope): description
- Types: feat, fix, chore, refactor, docs, style, test, build
- Keep the description under 50 characters
- Focus on WHAT was changed, not WHY
- Be specific about the component/module affected
- Output ONLY the commit message text, no explanation or formatting

REPOSITORY CONTEXT:
- This is a NixOS configuration repository with flakes and home-manager
- Total commits in repo: $repo_stats
- Current branch info: $branch_info

FILE STRUCTURE (relevant files):
$file_structure

RECENT COMMIT HISTORY (last 50):
$commit_history

DETAILED RECENT CHANGES (last 10 commits with diffs):
$recent_diffs

CURRENT COMMIT BEING AMENDED:
$commit_diff

Based on all this context, generate the commit message:"
    
    # Escape the prompt for JSON
    local escaped_prompt
    escaped_prompt=$(printf '%s' "$prompt" | jq -Rs .)
    
    # Make API request
    local response
    response=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" \
      -H "x-goog-api-key: $GEMINI_API_KEY" \
      -H 'Content-Type: application/json' \
      -X POST \
      -d "{
        \"contents\": [
          {
            \"parts\": [
              {
                \"text\": $escaped_prompt
              }
            ]
          }
        ]
      }")
    
    # Extract the generated text
    local commit_message
    commit_message=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null | tr -d '\n\r')
    
    if [[ -n "$commit_message" && "$commit_message" != "null" ]]; then
        log "Generated commit message: $commit_message"
        git commit --amend -m "$commit_message"
        success "Commit message updated with Gemini suggestion"
        return 0
    else
        log "Failed to generate commit message, keeping original"
        return 1
    fi
}

# Run the build and capture the exit code
log "Running nixos-rebuild switch --flake .#$HOSTNAME"
if sudo nixos-rebuild switch --flake .#"$HOSTNAME"; then
    success "NixOS rebuild completed successfully!"
    
    # Generate improved commit message if we made a commit
    if [[ "$COMMIT_MADE" == "true" ]]; then
        generate_commit_message || true  # Don't fail if Gemini fails
    fi
    
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
