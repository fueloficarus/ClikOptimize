# clikdisplay.sh

Toggle the Raspberry Pi desktop UI on or off using systemd targets.

## Usage
```bash
sudo ./clikdisplay.sh --on              # Enable graphical desktop (reboot)
sudo ./clikdisplay.sh --off             # Disable desktop, boot to console (reboot)
sudo ./clikdisplay.sh --on --norestart  # Enable UI without rebooting
sudo ./clikdisplay.sh --off --norestart # Disable UI without rebooting

A reboot is required for changes to take effect unless --norestart is used.