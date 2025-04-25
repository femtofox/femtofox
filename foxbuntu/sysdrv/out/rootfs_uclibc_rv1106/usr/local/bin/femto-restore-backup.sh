#!/bin/bash
# Restore Script
# This script performs the following:
# 1. Restores the /home/femto directory from the latest backup at /mnt/usb/femto.
# 2. Restores configuration files from the backup directory (/home/femto/meshConfig)
#    back to their original location (/etc/meshtasticd/config.d/).
# 3. Cleans up additional backup files created during the backup process.
# 4. Restores owner of Home directory
#
# Note: The /mnt/usb/backups folder is not touched during restoration.

# Define paths
VOLUME="/mnt/usb"
USB_FEMTO="$VOLUME/femto"
HOME_FEMTO="/home/femto"
MESH_CONFIG_BACKUP="$HOME_FEMTO/meshConfig"
DEST_CONFIG="/etc/meshtasticd/config.d"

# Check if the latest backup exists
if [ ! -d "$USB_FEMTO" ]; then
    echo "Error: Latest backup directory $USB_FEMTO not found. Exiting."
    exit 1
fi

# Restore the home directory from the latest backup
echo "Restoring home directory from $USB_FEMTO to $HOME_FEMTO"
sudo rsync -a --info=progress2 "$USB_FEMTO"/ "$HOME_FEMTO"/
echo "Home directory restore completed."

# Restore configuration files to /etc/meshtasticd/config.d/
if [ -d "$MESH_CONFIG_BACKUP" ]; then
    echo "Restoring configuration files from $MESH_CONFIG_BACKUP to $DEST_CONFIG"
    # Ensure the destination directory exists (requires sudo if /etc is not writable)
    sudo mkdir -p "$DEST_CONFIG"
    sudo cp -r "$MESH_CONFIG_BACKUP/"* "$DEST_CONFIG"/
    echo "Configuration files restored to $DEST_CONFIG."
else
    echo "No meshConfig backup found in $HOME_FEMTO. Skipping configuration restoration."
fi

# Clean up additional backup files added to the home directory during backup
echo "Cleaning up additional backup files in $HOME_FEMTO"
#rm -f "$HOME_FEMTO"/nodeBackup_*.yaml
#rm -f "$HOME_FEMTO"/config.ini_*
rm -rf "$HOME_FEMTO"/meshConfig
echo "Cleanup completed."

# Update Owner of Home folder and all sub-folders
echo "Updating Owner of Home Directory"
sudo chown -R femto:femto /home/femto

echo "Restore process completed."
