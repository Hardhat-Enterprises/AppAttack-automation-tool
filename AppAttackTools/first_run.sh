#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config + all install/update functions ===
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/setup.sh"

echo "Performing initial setup tasks..."

install_all_tools
check_updates

source "$SCRIPT_DIR/main.sh"
