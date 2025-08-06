#!/bin/bash
echo "Testing systemctl commands..."

echo "Checking pipewire service..."
systemctl --user status pipewire.service || echo "pipewire not available"

echo "Checking if services exist..."
systemctl --user list-unit-files | grep -E "(pipewire|wireplumber|xdg-desktop)" || echo "No matching services found"

echo "Testing start command with timeout..."
timeout 3 systemctl --user start pipewire.service && echo "pipewire started" || echo "pipewire failed/timeout"