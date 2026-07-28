#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/atlas-ui.service"

if [ ! -f "$SERVICE_FILE" ]; then
  echo "Error: atlas-ui.service not found in $SCRIPT_DIR"
  exit 1
fi

echo "Installing Atlas UI service..."
echo "Make sure you've edited atlas-ui.service with your username and paths first!"
echo ""

sudo cp "$SERVICE_FILE" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable atlas-ui
sudo systemctl start atlas-ui
sudo systemctl status atlas-ui
