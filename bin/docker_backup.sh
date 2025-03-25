#!/bin/bash
# From ChatGPT

# === CONFIGURATION ===
CONTAINER_NAME="mc"  # Set your container name here
BACKUP_DIR="$HOME/docker_backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/$CONTAINER_NAME-$TIMESTAMP"
VOLUME_BACKUP="$BACKUP_PATH/volumes"
CONTAINER_BACKUP="$BACKUP_PATH/container.tar"

# Create backup directory
mkdir -p "$VOLUME_BACKUP"

echo "📌 Backing up container: $CONTAINER_NAME"

# === STEP 1: Export the container ===
echo "🚀 Exporting container filesystem..."
docker export "$CONTAINER_NAME" -o "$CONTAINER_BACKUP" && lbzip2 -k "$CONTAINER_BACKUP" && rm "$CONTAINER_BACKUP"

# === STEP 2: Backup container volumes ===
echo "🔍 Finding volumes..."
VOLUME_PATHS=$(docker inspect "$CONTAINER_NAME" | grep -i "Mountpoint" | awk -F '"' '{print $4}')

if [ -n "$VOLUME_PATHS" ]; then
    echo "📦 Backing up volumes..."
    for VOLUME_PATH in $VOLUME_PATHS; do
        VOLUME_NAME=$(basename "$VOLUME_PATH")
        tar -czf "$VOLUME_BACKUP/$VOLUME_NAME.tar.gz" -C "$VOLUME_PATH" .
    done
else
    echo "⚠️ No volumes found, skipping volume backup."
fi

echo "✅ Backup completed: $BACKUP_PATH"

# === STEP 3: Optional - Cleanup old backups ===
# Keep only the last 5 backups
find "$BACKUP_DIR" -type d -mtime +5 -exec rm -rf {} \;
echo "🧹 Old backups cleaned up (if older than 5 days)."

### Add to chrontab
# crontab -e
# 0 2 * * * /path/to/docker_backup.sh >> /path/to/backup.log 2>&1
