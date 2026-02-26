#!/usr/bin/env bash
# ------------------------------------------------------------
# Pi-hole Minimal Appliance Setup Script
# Target: Raspberry Pi Zero (Raspberry Pi OS Lite)
# Author: Benjamin J. Baker
# Purpose: Configure a lean, hardened Pi-hole DNS appliance with optional ntopng light mode
# ------------------------------------------------------------

set -euo pipefail

CONFIG_DIR_NTOP="/etc/ntopng"
CONFIG_NTOP="$CONFIG_DIR_NTOP/ntopng.conf"

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

    apt purge -y cups cups-daemon || true
    systemctl disable --now avahi-daemon || true
    apt purge -y avahi-daemon || true
    systemctl disable --now bluetooth || true
    apt purge -y bluez || true
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

# ------------------------------------------------------------
# ntopng Light Mode (Modular, Safe)
# ------------------------------------------------------------

write_ntop_config() {
    mkdir -p "$CONFIG_DIR_NTOP"

    cat <<EOF > "$CONFIG_NTOP"
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

install_ntopng_light() {
    echo "[INFO] Installing ntopng (light mode)..."
    apt update
    apt install -y ntopng redis-server

    echo "[INFO] Writing ntopng config..."
    write_ntop_config

    echo "[INFO] Enabling ntopng services..."
    systemctl enable redis-server
    systemctl enable ntopng
    systemctl restart redis-server
    systemctl restart ntopng
}

repair_ntopng_light() {
    echo "[INFO] Repairing ntopng configuration..."
    write_ntop_config
    systemctl restart redis-server
    systemctl restart ntopng

    if systemctl is-active --quiet ntopng; then
        echo "[INFO] ntopng is running successfully."
    else
        echo "[ERROR] ntopng failed to start. Use --ntop-debug."
        exit 1
    fi
}

status_ntopng_light() {
    echo "[INFO] ntopng status:"
    systemctl status ntopng --no-pager || true
    echo
    echo "[INFO] Listening ports:"
    ss -tulnp | grep ntopng || echo "ntopng not listening"
}

debug_ntopng_light() {
    echo "[DEBUG] ntopng diagnostics:"
    echo
    ip a
    echo
    cat "$CONFIG_NTOP"
    echo
    journalctl -u ntopng --no-pager | tail -n 50
}

uninstall_ntopng_light() {
    echo "[INFO] Uninstalling ntopng..."
    systemctl stop ntopng || true
    systemctl disable ntopng || true
    systemctl stop redis-server || true
    systemctl disable redis-server || true
    apt purge -y ntopng redis-server || true
    apt autoremove -y
    rm -rf /etc/ntopng /var/lib/ntopng /var/log/ntopng
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

    ufw allow 53
    ufw allow 80/tcp
    ufw allow 66/tcp
    ufw allow 22/tcp
    ufw allow 3000/tcp

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

    case "${1:-}" in
        --ntop-repair) repair_ntopng_light; exit 0 ;;
        --ntop-status) status_ntopng_light; exit 0 ;;
        --ntop-debug)  debug_ntopng_light; exit 0 ;;
        --ntop-uninstall) uninstall_ntopng_light; exit 0 ;;
    esac

    system_update
    remove_unneeded
    harden_ssh
    install_pihole
    install_ntopng_light
    disable_ipv6
    configure_firewall
    disable_kernel_modules

    echo "[INFO] Setup complete. Reboot recommended."
}

main "$@"
