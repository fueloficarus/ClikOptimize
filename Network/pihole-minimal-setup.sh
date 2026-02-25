#!/usr/bin/env bash
# ------------------------------------------------------------
# Pi-hole Minimal Appliance Setup Script
# Target: Raspberry Pi Zero (Raspberry Pi OS Lite)
# Author: Benjamin J. Baker
# Purpose: Configure a lean, hardened Pi-hole DNS appliance
# ------------------------------------------------------------

set -euo pipefail

# -------------------------
# Helper: Require root
# -------------------------
require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "[ERROR] This script must be run as root."
        exit 1
    fi
}

# -------------------------
# System Update
# -------------------------
system_update() {
    echo "[INFO] Updating system packages..."
    apt update
    apt full-upgrade -y
    apt autoremove -y
}

# -------------------------
# Remove Unneeded Services
# -------------------------
remove_unneeded() {
    echo "[INFO] Removing unnecessary packages..."

    # Printing stack
    apt purge -y cups cups-daemon || true

    # Avahi (mDNS)
    systemctl disable --now avahi-daemon || true
    apt purge -y avahi-daemon || true

    # Bluetooth stack
    systemctl disable --now bluetooth || true
    apt purge -y bluez || true

    # Triggerhappy (input hotplug daemon)
    apt purge -y triggerhappy || true
}

# -------------------------
# Harden SSH
# -------------------------
harden_ssh() {
    echo "[INFO] Hardening SSH configuration..."

    SSHD="/etc/ssh/sshd_config"

    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD"
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' "$SSHD"

    systemctl restart ssh
}

install_ntopng_light() {
    echo "[INFO] Installing ntopng (light mode)..."

    apt update
    apt install -y ntopng redis-server

    echo "[INFO] Configuring ntopng for lightweight operation..."

    CONFIG="/etc/ntopng/ntopng.conf"
    cp "$CONFIG" "${CONFIG}.bak.$(date +%s)" 2>/dev/null || true

    cat <<EOF > "$CONFIG"
install_ntopng_light() {
    echo "[INFO] Installing ntopng (light mode)..."

    apt update
    apt install -y ntopng redis-server

    echo "[INFO] Configuring ntopng for lightweight operation..."

    CONFIG_DIR="/etc/ntopng"
    CONFIG="$CONFIG_DIR/ntopng.conf"

    mkdir -p "$CONFIG_DIR"

    # Backup only if the file exists
    if [[ -f "$CONFIG" ]]; then
        cp "$CONFIG" "${CONFIG}.bak.$(date +%s)"
    fi

    cat <<EOF > "$CONFIG"
    
# ------------------------------
# ntopng Light Mode Configuration
# ------------------------------

--interface=eth0
--http-port=3000

# Disable heavy nDPI features
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

# Local network definition
--local-networks="192.168.0.0/16"
EOF

    echo "[INFO] Enabling ntopng and redis services..."
    systemctl enable redis-server
    systemctl enable ntopng
    systemctl restart redis-server
    systemctl restart ntopng

    echo "[INFO] ntopng light mode setup complete. UI available at http://<PI_IP>:3000"
}


# -------------------------
# Install Pi-hole
# -------------------------
install_pihole() {
    echo "[INFO] Installing Pi-hole..."
    curl -sSL https://install.pi-hole.net | bash
}

# -------------------------
# Disable IPv6 (optional)
# -------------------------
disable_ipv6() {
    echo "[INFO] Disabling IPv6..."

    SYSCTL="/etc/sysctl.conf"

    grep -q "disable_ipv6" "$SYSCTL" || cat <<EOF >> "$SYSCTL"

# Disable IPv6 for Pi-hole appliance
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

    sysctl -p
}

# -------------------------
# Configure Firewall
# -------------------------
configure_firewall() {
    echo "[INFO] Configuring UFW firewall..."

    apt install -y ufw

    ufw allow 53          # DNS (TCP/UDP)
    ufw allow 80/tcp      # Pi-hole Web UI
    ufw allow 66/tcp      # SSH (custom port)
    ufw allow 22/tcp      # SSH (legacy port, optional)

    ufw --force enable
}

# -------------------------
# Optional Kernel Module Disables
# -------------------------
disable_kernel_modules() {
    echo "[INFO] Disabling optional kernel modules..."

    CONFIG="/boot/config.txt"

    grep -q "disable-bt" "$CONFIG" || echo "dtoverlay=disable-bt" >> "$CONFIG"
    grep -q "disable-wifi" "$CONFIG" || echo "dtoverlay=disable-wifi" >> "$CONFIG"
    grep -q "dtparam=audio=off" "$CONFIG" || echo "dtparam=audio=off" >> "$CONFIG"
}

# -------------------------
# Main
# -------------------------
main() {
    require_root
    system_update
    remove_unneeded
    harden_ssh
    install_pihole
    disable_ipv6
    configure_firewall
    disable_kernel_modules

    echo "[INFO] Setup complete. Reboot recommended."
}

main "$@"
