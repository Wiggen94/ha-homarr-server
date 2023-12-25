#!/bin/sh

# Define paths for Homarr's data
HOMARR_CONFIG_PATH="/app/data/configs"
HOMARR_DATA_PATH="/data"
HOMARR_ICON_PATH="/app/public/icons"

# Mapped directories from the host
PERSISTENT_CONFIG_PATH="/share/homarr/configs"
PERSISTENT_DATA_PATH="/share/homarr/data"
PERSISTENT_ICON_PATH="/share/homarr/icon"

# Ensure the persistent directories exist
mkdir -p $PERSISTENT_CONFIG_PATH
mkdir -p $PERSISTENT_DATA_PATH
mkdir -p $PERSISTENT_ICON_PATH

# Function to sync data from Homarr's directories to persistent storage
sync_to_persistent() {
    while true; do
        cp -R $HOMARR_CONFIG_PATH/* $PERSISTENT_CONFIG_PATH/ 2>/dev/null
        cp -R $HOMARR_DATA_PATH/* $PERSISTENT_DATA_PATH/ 2>/dev/null
        cp -R $HOMARR_ICON_PATH/* $PERSISTENT_ICON_PATH/ 2>/dev/null
        sleep 60  # Sync every 60 seconds, adjust as needed
    done
}

# Sync data to Homarr's directories on startup
cp -R $PERSISTENT_CONFIG_PATH/* $HOMARR_CONFIG_PATH/ 2>/dev/null
cp -R $PERSISTENT_DATA_PATH/* $HOMARR_DATA_PATH/ 2>/dev/null
cp -R $PERSISTENT_ICON_PATH/* $HOMARR_ICON_PATH/ 2>/dev/null

# Start continuous sync in the background
sync_to_persistent &

# Exporting hostname
echo "Exporting hostname..."
export NEXTAUTH_URL_INTERNAL="http://$HOSTNAME:${PORT:-7575}"

# Migrating database
echo "Migrating database..."
cd ./migrate; yarn db:migrate & PID=$!
# Wait for migration to finish
wait $PID

# Check and copy default.json if necessary
cp -n /app/data/default.json /app/data/configs/default.json

# Starting Homarr
echo "Starting production server..."
node /app/server.js & PID=$!

# Wait for Homarr server process to end
wait $PID
