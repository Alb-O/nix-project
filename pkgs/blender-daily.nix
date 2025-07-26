# Blender daily build downloader and runner
{
  pkgs,
  lib,
  stdenv,
  writeShellScriptBin,
  fetchurl,
  curl,
  ...
}:
writeShellScriptBin "blender-daily" ''
  set -euo pipefail
  
  CACHE_DIR="$HOME/.cache/blender-daily"
  INSTALL_DIR="$HOME/.local/share/blender-daily"
  CURRENT_LINK="$INSTALL_DIR/current"
  
  mkdir -p "$CACHE_DIR" "$INSTALL_DIR"
  
  # Fetch latest daily build info from Blender download page
  echo "Fetching latest Blender daily build info..."
  LATEST_URL=$(${curl}/bin/curl -s "https://builder.blender.org/download/daily/" | \
    ${pkgs.gnugrep}/bin/grep -o 'https://cdn\.builder\.blender\.org/download/daily/[^"]*linux\.x86_64[^"]*\.tar\.xz' | \
    head -1)
  
  if [[ -z "$LATEST_URL" ]]; then
    echo "Error: Could not fetch latest Blender daily build URL"
    exit 1
  fi
  
  # Extract version/build info from URL
  FILENAME=$(basename "$LATEST_URL")
  BUILD_DIR="$INSTALL_DIR/$FILENAME"
  
  echo "Latest build: $FILENAME"
  
  # Check if already downloaded
  if [[ -d "$BUILD_DIR" ]]; then
    echo "Build already exists, linking..."
  else
    echo "Downloading $LATEST_URL..."
    TEMP_FILE="$CACHE_DIR/$FILENAME"
    
    ${curl}/bin/curl -L --progress-bar -o "$TEMP_FILE" "$LATEST_URL"
    
    echo "Extracting to $BUILD_DIR..."
    mkdir -p "$BUILD_DIR"
    ${pkgs.gnutar}/bin/tar -xf "$TEMP_FILE" -C "$BUILD_DIR" --strip-components=1
    
    # Cleanup
    rm -f "$TEMP_FILE"
  fi
  
  # Update current symlink
  rm -f "$CURRENT_LINK"
  ln -sf "$BUILD_DIR" "$CURRENT_LINK"
  
  echo "Blender daily build ready at: $CURRENT_LINK/blender"
  
  # Run if no arguments given, otherwise just setup
  if [[ $# -eq 0 ]]; then
    exec "$CURRENT_LINK/blender"
  else
    exec "$CURRENT_LINK/blender" "$@"
  fi
''