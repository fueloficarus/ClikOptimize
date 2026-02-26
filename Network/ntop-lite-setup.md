ntopng Light Mode Setup

Important:  
	Before running this script, edit the local network value inside ntopng.conf to match your own LAN.
	The default in the script is: --local-networks="10.0.6.0/24"
	Update this to reflect your actual subnet!

	A lightweight, low‑impact traffic visibility tool for Raspberry Pi Zero (Raspberry Pi OS Lite).
	This script installs and configures ntopng in light mode, optimized for minimal CPU, RAM, and storage usage.

Purpose - It is designed for home networks, low‑power devices, and Pi‑hole appliances where resource usage must remain extremely low.

The goal is to provide basic network flow visibility without the heavy overhead of full nDPI classification or flow database storage.

This setup transforms a Raspberry Pi Zero into a small, efficient monitoring node with:
		ntopng in light‑mode
		Minimal memory footprint
		No flow database
		No heavy protocol analysis
		Clean, reproducible configuration
		Optional uninstall mode

What the Script Does
	Installation
	Installs ntopng
	Installs redis‑server (required by ntopng)
	Ensures all dependencies are present

Light‑Mode Configuration
	Creates /etc/ntopng/ntopng.conf
		Binds ntopng to eth0
		Sets Web UI to port 3000
		Disables heavy features:
		nDPI protocol classification
		Alerts
		VLAN flow tracking
		DNS resolution
		Flow database

Reduces memory usage:
	Limits hosts
	Limits flows

Defines local network:
	10.0.6.0/24
	Service Management
	Enables ntopng and redis-server
	Restarts both services
	Ensures ntopng starts automatically on boot

Uninstall Mode
	The script includes a full rollback option:
	Stops ntopng and redis
	Disables both services
	Purges ntopng and redis packages
	Removes ntopng config, logs, and data directories
	Runs autoremove to clean unused dependencies

Usage
	Install ntopng (default)
		sudo ./ntop-lite-setup.sh

	Uninstall ntopng
		sudo ./ntop-lite-setup.sh --uninstall

Additional Script Flags

	Status Mode
		Displays service state, listening ports, and recent logs.
				sudo ./ntop-lite-setup.sh --status

		Debug Mode
			Runs a full diagnostic sweep including:
													Interfaces
													Config file
													Redis status
													ntopng logs
				sudo ./ntop-lite-setup.sh --debug
		
		Repair Mode
			Rewrites a clean ntopng configuration, restarts services, and validates that ntopng is running.
				sudo ./ntop-lite-setup.sh --repair

		Uninstall Mode
			Stops services, purges packages, removes config and logs.
				sudo ./ntop-lite-setup.sh --uninstall


After Installation
	Access ntopng Web UI:
		http://<PI_IP>:3000

	ntopng will begin collecting lightweight flow metadata immediately.
	No flow database is stored; all data is in‑memory and ephemeral.

	Enable OUI lookups in ntopng:
		sudo curl -L https://www.wireshark.org/download/automated/data/manuf -o /usr/share/wireshark/manuf
		sudo rm /usr/share/ntopng/httpdocs/other/EtherOUI.txt
		sudo ln -s /usr/share/wireshark/manuf /usr/share/ntopng/httpdocs/other/EtherOUI.txt

Target Environment
	Raspberry Pi Zero / Zero W / Zero 2 W
	Raspberry Pi OS Lite (Trixie or similar)
	Networks where low‑impact monitoring is preferred
	Pi‑hole appliances needing optional traffic visibility