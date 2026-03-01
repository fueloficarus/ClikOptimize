#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
#  Raspberry Pi Zero 2 W — Spotify Touchscreen Controller Setup
# ------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo ./spotify-controller-setup.sh"
    exit 1
fi

# --- CONFIG ------------------------------------------------------------
SPOTIFY_USER="spotify"
SPOTIFY_HOME="/home/${SPOTIFY_USER}"
SPOTIFY_URL="https://open.spotify.com/collection/tracks"

# --- BLUETOOTH CHECK + INSTALL -----------------------------------------
ensure_bluetooth_installed() {
    echo "[INFO] Checking Bluetooth stack..."

    # Check if bluez is installed
    if ! dpkg -l | grep -q "^ii  bluez "; then
        echo "[INFO] Installing bluez (Bluetooth stack)..."
        apt install -y bluez
    fi

    # Check if pi-bluetooth firmware is installed
    if ! dpkg -l | grep -q "^ii  pi-bluetooth "; then
        echo "[INFO] Installing pi-bluetooth firmware..."
        apt install -y pi-bluetooth
    fi

    # Ensure the bluetooth service exists
    if ! systemctl list-unit-files | grep -q "^bluetooth.service"; then
        echo "[INFO] Installing bluetooth service package..."
        apt install -y bluez-tools
    fi

    echo "[INFO] Bluetooth stack present."
}

ensure_bluetooth_installed

# --- 1. Disable Pi-hole + ntopng services -------------------------------
disable_service() {
    local svc="$1"
    if systemctl list-unit-files | grep -q "^${svc}.service"; then
        systemctl disable --now "${svc}.service" || true
    fi
}

disable_service pihole-FTL
disable_service lighttpd
disable_service ntopng

# --- 2. Ensure Wi-Fi + Bluetooth are enabled ----------------------------
rfkill unblock wifi || true
rfkill unblock bluetooth || true
systemctl enable bluetooth || true

# --- 3. Create non‑privileged kiosk user --------------------------------
if ! id "${SPOTIFY_USER}" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" "${SPOTIFY_USER}"
fi

usermod -aG video,input "${SPOTIFY_USER}"

# --- 4. Autologin --------------------------------------------------------
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat >/etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${SPOTIFY_USER} --noclear %I \$TERM
EOF

# --- 5. Install Firefox + X11 -------------------------------------------
apt update
apt install -y --no-install-recommends \
    xserver-xorg \
    xinit \
    openbox \
    firefox-esr \
    x11-xserver-utils

# --- 6. Prevent screen blanking -----------------------------------------
mkdir -p "${SPOTIFY_HOME}/.config/openbox"
cat >"${SPOTIFY_HOME}/.config/openbox/autostart" <<EOF
xset s off
xset -dpms
xset s noblank
firefox-esr --kiosk "${SPOTIFY_URL}"
EOF
chown -R "${SPOTIFY_USER}:${SPOTIFY_USER}" "${SPOTIFY_HOME}/.config"

# --- 7. Auto-start X on login -------------------------------------------
cat >"${SPOTIFY_HOME}/.bash_profile" <<'EOF'
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx -- -nocursor
fi
EOF
chown "${SPOTIFY_USER}:${SPOTIFY_USER}" "${SPOTIFY_HOME}/.bash_profile"

# --- 8. Force HDMI -------------------------------------------------------
if ! grep -q "hdmi_force_hotplug" /boot/config.txt; then
cat >>/boot/config.txt <<EOF

hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
EOF
fi

# --- 9. Done -------------------------------------------------------------
echo "Setup complete. Reboot recommended."
