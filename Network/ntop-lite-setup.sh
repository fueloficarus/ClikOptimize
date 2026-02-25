#!/usr/bin/env bash
# ------------------------------------------------------------
# ntopng Light Mode Setup Script
# Target: Raspberry Pi Zero (Raspberry Pi OS Lite)
# Author: B.
# Purpose: Install and configure ntopng in lightweight mode
# ------------------------------------------------------------

set -euo pipefail

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "[ERROR] This script must be run as root."
        exit 1
    fi
}

install_ntopng() {
    echo "[INFO] Installing ntopng (light mode)..."

    apt update
    apt install -y ntopng redis-server
}

configure_ntopng() {
    echo "[INFO] Configuring ntopng for lightweight operation..."

    CONFIG_DIR="/etc/ntopng"
    CONFIG="$CONFIG_DIR/ntopng.conf"

    # Ensure directory exists
    mkdir -p "$CONFIG_DIR"

    # Backup existing config if present
    if [[ -f "$CONFIG" ]]; then
        cp "$CONFIG" "${CONFIG}.bak.$(date +%s)"
    fi

    cat <<EOF > "$CONFIG"
# ------------------------------
# ntopng Light Mode Configuration
# ------------------------------

# Bind to all interfaces
--interface=eth0

# Web UI port
--http-port=3000

# Disable heavy nDPI categories
--disable-autologout
--disable-alerts
--disable-flows-vlan
--disable-l7-protocols
--disable-dns-resolution

# Reduce memory footprint
--max-num-flows=2000
--max-num-hosts=256

# Disable local flow DB (too heavy for Pi Zero)
--disable-flow-db

# Local timezone
--local-networks="10.0.6.0/24"
EOF
}
