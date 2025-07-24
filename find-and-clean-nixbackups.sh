#!/usr/bin/env bash
set -euo pipefail


# Find all .nixbackup files in the home directory, excluding .git and node_modules
BACKUPS=$(find ~ \
  -type d \( -name .git -o -name node_modules \) -prune -false \
  -o -type f -name '*.nixbackup' -print)

if [ -z "$BACKUPS" ]; then
  echo "No .nixbackup files found."
  exit 0
fi

echo "The following .nixbackup files were found:"
echo "$BACKUPS"
echo
read -p "Do you want to delete all these files? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "$BACKUPS" | xargs rm -v
  echo "All .nixbackup files deleted."
else
  echo "No files were deleted."
fi
