#!/usr/bin/env bash
set -euo pipefail

TEMPLATE="secrets.op.nix"
FILLED="secrets.nix"

# Allow host to be passed as an argument, or use current hostname
HOST="${1:-$(hostname)}"

if [[ -f "$TEMPLATE" ]]; then
  touch "$FILLED"
  echo "[INFO] Generating $FILLED from $TEMPLATE with secrets..."
  if ! op inject -f -i "$TEMPLATE" -o "$FILLED"; then
    echo "[ERROR] op inject failed." >&2
    exit 1
  fi
  echo "[INFO] Running sudo nixos-rebuild switch --flake .#${HOST} ..."
  if ! sudo nixos-rebuild switch --flake .#"${HOST}"; then
    echo "[ERROR] nixos-rebuild failed." >&2
    exit 1
  fi
  echo "[SUCCESS] Home Manager config applied with secrets."
else
  echo "[ERROR] $TEMPLATE not found. Aborting." >&2
  exit 1
fi
