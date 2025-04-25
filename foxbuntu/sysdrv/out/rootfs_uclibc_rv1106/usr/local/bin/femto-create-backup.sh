#!/bin/bash
# Backup Script
# This script performs the following steps:
# 1. Checks if the backup volume (/mnt/usb) is mounted.
# 2. If a folder named "femto" already exists at /mnt/usb, it moves that folder
#    to /mnt/usb/backups with a timestamp appended.
# 3. Copies /opt/meshing-around/config.ini (if it exists) to /home/femto/ with a date appended.
# 4. Runs the meshtastic export-config command to save a node backup in /home/femto/.
# 5. Copies any configuration files from /etc/meshtasticd/config.d/ to /home/femto/meshConfig/.
# 6. Uses rsync to back up the /home/femto folder to /mnt/usb/femto (the most recent backup).

# Set a date variable (format: YYYYMMDD_HHMMSS)
DATE=$(date +"%Y%m%d_%H%M%S")

# Define paths
VOLUME="/mnt/usb"
USB_FEMTO="$VOLUME/femto"
USB_BACKUPS="$VOLUME/backups"
HOME_FEMTO="/home/femto"

# 1. Check if the volume is mounted
if mountpoint -q "$VOLUME"; then
    echo "Volume $VOLUME is mounted."
else
    echo "Error: Volume $VOLUME is not mounted. Exiting."
    exit 1
fi

# 2. If /mnt/usb/femto exists, move it to /mnt/usb/backups with a date appended
if [ -d "$USB_FEMTO" ]; then
    echo "Existing backup found at $USB_FEMTO. Moving it to $USB_BACKUPS with timestamp."
    sudo mkdir -p "$USB_BACKUPS"
    sudo mv "$USB_FEMTO" "$USB_BACKUPS/femto_backup_$DATE"
fi

# 3. Check if the config file exists and copy it to /home/femto with date appended
CONFIG_SRC="/opt/meshing-around/config.ini"
if [ -f "$CONFIG_SRC" ]; then
    CONFIG_DEST="$HOME_FEMTO/config.ini_$DATE"
    echo "Copying $CONFIG_SRC to $CONFIG_DEST"
    cp "$CONFIG_SRC" "$CONFIG_DEST"
else
    echo "Config file $CONFIG_SRC not found. Skipping config copy."
fi

# 4. Run the meshtastic export-config command and save its output to a node backup file
NODE_BACKUP="$HOME_FEMTO/nodeBackup_$DATE.yaml"
echo "Running meshtastic export-config; outputting to $NODE_BACKUP"
meshtastic --host localhost --export-config > "$NODE_BACKUP"

# 5. Back up any configuration files from /etc/meshtasticd/config.d/ to /home/femto/meshConfig/
CONFIG_D="/etc/meshtasticd/config.d"
MESH_CONFIG="$HOME_FEMTO/meshConfig"
if [ -d "$CONFIG_D" ] && [ "$(ls -A "$CONFIG_D")" ]; then
    echo "Copying files from $CONFIG_D to $MESH_CONFIG"
    mkdir -p "$MESH_CONFIG"
    cp "$CONFIG_D"/* "$MESH_CONFIG"/
else
    echo "No files found in $CONFIG_D. Skipping config.d backup."
fi

# 6. Use rsync to back up /home/femto to /mnt/usb/femto (the most recent backup)
echo "Starting rsync backup of $HOME_FEMTO to $USB_FEMTO"
sudo rsync -a --no-o --no-g --info=progress2 \
  --exclude="lost+found" --exclude=".cache" --exclude=".zgenom" --exclude=".zcompdump" \
  "$HOME_FEMTO"/ "$USB_FEMTO"/

echo "Backup process completed."
