Pi‑hole Minimal Appliance Setup

Important:  
	Before running this script, edit the local network value inside ntopng.conf to match your own LAN.
	The default in the script is: --local-networks="10.0.6.0/24"
	Update this to reflect your actual subnet!

A lightweight, hardened DNS filtering appliance for Raspberry Pi Zero (Raspberry Pi OS Lite).
This script configures a clean, secure Pi‑hole deployment with optional ntopng light‑mode monitoring.

Purpose - The goal is a lean, stable, low‑maintenance DNS resolver suitable for home networks.
	This setup transforms a Raspberry Pi Zero into a dedicated DNS appliance with:
	Pi‑hole for DNS filtering
	Hardened SSH
	Minimal OS footprint
	Disabled unnecessary services
	Optional IPv6 disablement
	UFW firewall with strict inbound rules
	Optional ntopng light‑mode traffic visibility


What the Script Does
	System Preparation
	Updates all packages
	Removes printing stack, Avahi, Bluetooth, triggerhappy
	Disables related systemd services

Security Hardening
	Disables SSH password authentication
	Disallows root SSH login

Enables UFW with only required ports:
	53 DNS
	80/tcp Pi‑hole UI
	66/tcp custom SSH
	22/tcp legacy SSH (optional)
	3000/tcp ntopng Web UI

Pi‑hole Installation
	Installs Pi‑hole via official installer
	Prepares system for DNS‑only operation

Optional Enhancements
	Disables IPv6
	Disables Wi‑Fi, Bluetooth, and audio kernel modules
	Installs ntopng in light mode for low‑impact traffic monitoring

Usage
	Run as root:
		bash
			sudo ./pihole-minsetup.sh
	A reboot is recommended after completion.

After Installation
	Access Pi‑hole UI:
		http://<PI_IP>/admin

	Access ntopng (if enabled):
		http://<PI_IP>:3000

	Point your router or clients to the Pi’s IP as their DNS server.

	Enable OUI lookups in ntopng:
		sudo curl -L https://www.wireshark.org/download/automated/data/manuf -o /usr/share/wireshark/manuf
		sudo rm /usr/share/ntopng/httpdocs/other/EtherOUI.txt
		sudo ln -s /usr/share/wireshark/manuf /usr/share/ntopng/httpdocs/other/EtherOUI.txt


Target Environment
	Raspberry Pi Zero / Zero W / Zero 2 W
	Raspberry Pi OS Lite (Trixie or similar)
	Wired or wireless network depending on your appliance design