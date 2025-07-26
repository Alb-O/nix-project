# Blender daily build downloader and runner
{
  pkgs,
  lib,
  stdenv,
  writeShellScriptBin,
  fetchurl,
  curl,
  jq,
  ...
}:
writeShellScriptBin "blender-daily" ''
  set -euo pipefail

  CACHE_DIR="$HOME/.cache/blender-daily"
  INSTALL_DIR="$HOME/.local/share/blender-daily"
  CURRENT_LINK="$INSTALL_DIR/current"

  mkdir -p "$CACHE_DIR" "$INSTALL_DIR"

  # Fetch latest daily build from Blender API (JSON endpoint)
  echo "Fetching latest Blender daily build from API..."
  API_URL="https://builder.blender.org/download/daily/?format=json&v=1"
  
  # Get architecture (x86_64 for most Linux systems)
  ARCH="x86_64"
  
  echo "Querying API: $API_URL"
  LATEST_URL=$(${curl}/bin/curl -s "$API_URL" | \
    ${jq}/bin/jq -r --arg arch "$ARCH" '
      [.[] | select(.platform == "linux" and .architecture == $arch and (.file_name | test("tar\\.xz$")) and (.file_name | test("sha256") | not))] |
      sort_by(.file_mtime) | reverse | .[0].url // empty
    ')
  
  echo "Found URL: $LATEST_URL"

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
    
    # Patch Blender binary for NixOS dynamic linking
    echo "Patching Blender binary for NixOS..."
    if [[ -f "$BUILD_DIR/blender" ]]; then
      ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "$BUILD_DIR/blender"
      ${pkgs.patchelf}/bin/patchelf --set-rpath "${pkgs.lib.makeLibraryPath [
        pkgs.glibc
        pkgs.gcc-unwrapped.lib
        pkgs.xorg.libX11
        pkgs.xorg.libXi
        pkgs.xorg.libXrender
        pkgs.xorg.libXxf86vm
        pkgs.libGL
        pkgs.freetype
        pkgs.zlib
        pkgs.glib
        pkgs.alsa-lib
        pkgs.pulseaudio
      ]}" "$BUILD_DIR/blender"
      echo "Blender binary patched successfully"
    else
      echo "Warning: Blender binary not found at $BUILD_DIR/blender"
    fi

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
