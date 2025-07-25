#!/usr/bin/env bash
set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}ℹ$1${NC}"
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

# Check for --auto flag
AUTO_MODE=false
if [[ "${1:-}" == "--auto" ]]; then
    AUTO_MODE=true
fi

log "Scanning for .nixbackup files..."

# Find all .nixbackup files in the home directory, excluding .git and node_modules
# Using a more robust approach that handles filenames with spaces
mapfile -t BACKUP_FILES < <(find ~ \
  -type d \( -name .git -o -name node_modules -o -name .cache \) -prune \
  -o -type f -name '*.nixbackup' -print 2>/dev/null)

if [[ ${#BACKUP_FILES[@]} -eq 0 ]]; then
    success "No .nixbackup files found - system is clean!"
    exit 0
fi

# Display found files
echo
log "Found ${#BACKUP_FILES[@]} .nixbackup file(s):"
printf '%s\n' "${BACKUP_FILES[@]}" | sed 's/^/  /'
echo

if [[ "$AUTO_MODE" == "true" ]]; then
    log "Auto-cleaning mode enabled - removing all .nixbackup files..."
    confirm="y"
else
    echo -n "Do you want to delete all these files? [y/N] "
    read -r confirm
fi

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    deleted_count=0
    failed_count=0
    
    for file in "${BACKUP_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            if rm -f "$file"; then
                ((deleted_count++))
                if [[ "$AUTO_MODE" != "true" ]]; then
                    echo "  Deleted: $file"
                fi
            else
                ((failed_count++))
                warn "Failed to delete: $file"
            fi
        else
            warn "File no longer exists: $file"
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        success "Successfully deleted $deleted_count .nixbackup file(s)"
    else
        warn "Deleted $deleted_count file(s), failed to delete $failed_count file(s)"
        exit 1
    fi
else
    log "No files were deleted."
fi
