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

# Load environment variables from .env file if it exists
if [[ -f .env ]]; then
    set -a  # automatically export all variables
    source .env
    set +a  # disable automatic export
fi

# Function to generate commit message with Gemini
generate_commit_message() {
    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        log "GEMINI_API_KEY not set, keeping original commit message"
        return 1
    fi

    log "Generating improved commit message with Gemini..."

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

# Main execution
if ! git rev-parse --git-dir &>/dev/null; then
    error "Not in a git repository"
    exit 1
fi

# Check if there's a commit to amend
if ! git log -1 --oneline &>/dev/null; then
    error "No commits found to amend"
    exit 1
fi

# Generate and apply the commit message
generate_commit_message || exit $?
