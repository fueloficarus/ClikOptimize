#!/usr/bin/env bash
# ------------------------------------------------------------
# clikdisplay Quick Display Mode Swap Script
# Target: Raspberry Pi Zero (Raspberry Pi OS Lite)
# Author: Benjamin J. Baker
# ------------------------------------------------------------
set -e

usage() {
    echo "Usage: sudo $0 --on | --off [--norestart]"
    exit 1
}

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo)."
    exit 1
fi

RESTART=true

# Parse flags
for arg in "$@"; do
    case "$arg" in
        --off)
            ACTION="off"
            ;;
        --on)
            ACTION="on"
            ;;
        --norestart)
            RESTART=false
            ;;
        *)
            usage
            ;;
    esac
done

case "$ACTION" in
    off)
        echo "Disabling Raspberry Pi desktop UI (boot to console)…"
        systemctl set-default multi-user.target
        ;;
    on)
        echo "Enabling Raspberry Pi desktop UI (boot to graphical)…"
        systemctl set-default graphical.target
        ;;
    *)
        usage
        ;;
esac

if $RESTART; then
    echo "Rebooting to apply changes…"
    reboot
else
    echo "Change applied. Reboot required for effect, but skipped due to --norestart."
fi
