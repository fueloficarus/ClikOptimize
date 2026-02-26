#!/usr/bin/env bash
# ------------------------------------------------------------
# ntopng Light Mode Setup Script
# Target: Raspberry Pi Zero (Raspberry Pi OS Lite)
# Author: Benjamin J. Baker
# Purpose: Install, configure, repair, debug, or uninstall ntopng in lightweight mode
# ------------------------------------------------------------

set -euo pipefail

CONFIG_DIR="/etc/ntopng"
CONFIG="$CONFIG_DIR/ntopng.conf"

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "[ERROR] This script must be run as root."
        exit 1
    fi
}

# -------------------------
# INSTALL
# -------------------------
install_ntopng() {
    echo "[INFO] Installing ntopng (light mode)..."
    apt update
    apt install -y ntopng redis-server
}

# -------------------------
# CONFIG WRITER
# -------------------------
write_clean_config() {
    mkdir -p "$CONFIG_DIR"

    echo "[INFO] Writing clean ntopng configuration to $CONFIG"

    cat <<EOF > "$CONFIG"
# ------------------------------
# ntopng Light Mode Configuration
# ------------------------------

--interface=eth0
--http-port=3000

--disable-autologout
--disable-alerts
--disable-flows-vlan
--disable-l7-protocols
--disable-dns-resolution

--max-num-flows=2000
--max-num-hosts=256

--disable-flow-db

--local-networks="10.0.6.0/24"
EOF
}

configure_ntopng() {
    echo "[INFO] Configuring ntopng..."
    write_clean_config
}

# -------------------------
# ENABLE SERVICES
# -------------------------
enable_services() {
    echo "[INFO] Enabling ntopng and redis services..."
    systemctl enable redis-server
    systemctl enable ntopng
    systemctl restart redis-server
    systemctl restart ntopng
}

# -------------------------
# STATUS
# -------------------------
status_ntopng() {
    echo "[INFO] ntopng service status:"
    systemctl status ntopng --no-pager || true

    echo
    echo "[INFO] Listening ports:"
    ss -tulnp | grep ntopng || echo "ntopng not listening"

    echo
    echo "[INFO] Last 20 log lines:"
    journalctl -u ntopng --no-pager | tail -n 20
}

# -------------------------
# DEBUG
# -------------------------
debug_ntopng() {
    echo "[DEBUG] Running ntopng diagnostics..."

    echo
    echo "[DEBUG] Checking interface availability:"
    ip a

    echo
    echo "[DEBUG] Checking ntopng config:"
    cat "$CONFIG"

    echo
    echo "[DEBUG] Checking Redis status:"
    systemctl status redis-server --no-pager || true

    echo
    echo "[DEBUG] Checking ntopng logs:"
    journalctl -u ntopng --no-pager | tail -n 50
}

# -------------------------
# REPAIR
# -------------------------
repair_ntopng() {
    echo "[INFO] Repairing ntopng configuration..."
    write_clean_config

    echo "[INFO] Restarting services..."
    systemctl restart redis-server
    systemctl restart ntopng

    sleep 2

    if systemctl is-active --quiet ntopng; then
        echo "[INFO] ntopng is running successfully."
    else
        echo "[ERROR] ntopng failed to start. Use --debug for details."
        exit 1
    fi
}

# -------------------------
# UNINSTALL
# -------------------------
uninstall_ntopng() {
    echo "[INFO] Uninstalling ntopng and cleaning up..."

    systemctl stop ntopng 2>/dev/null || true
    systemctl disable ntopng 2>/dev/null || true

    systemctl stop redis-server 2>/dev/null || true
    systemctl disable redis-server 2>/dev/null || true

    apt purge -y ntopng redis-server || true
    apt autoremove -y

    rm -rf /etc/ntopng
    rm -rf /var/lib/ntopng
    rm -rf /var/log/ntopng

    echo "[INFO] Uninstall complete."
}

# -------------------------
# MAIN
# -------------------------
main() {
    require_root

    case "${1:-}" in
        --uninstall)
            uninstall_ntopng
            exit 0
            ;;
        --repair)
            repair_ntopng
            exit 0
            ;;
        --status)
            status_ntopng
            exit 0
            ;;
        --debug)
            debug_ntopng
            exit 0
            ;;
    esac

    install_ntopng
    configure_ntopng
    enable_services

    echo "[INFO] ntopng light mode setup complete."
    echo "[INFO] Access the UI at: http://<PI_IP>:3000"
}

main "$@"
