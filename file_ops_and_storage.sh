#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/lab_storage"
BACKUP_DIR="/tmp/lab_backup"

echo "=== Running File Operations & Directory Setup ==="

# Create standard application directory structure
mkdir -p "${BASE_DIR}"/{bin,config,logs,data}
touch "${BASE_DIR}/config/app.env"
touch "${BASE_DIR}/logs/audit.log"

cat <<EOF > "${BASE_DIR}/config/app.env"
APP_ENV=production
LOG_LEVEL=info
DATA_PATH=${BASE_DIR}/data
EOF

# Verify files exist and create a backup archive
if [[ -d "$BASE_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -r "$BASE_DIR" "${BACKUP_DIR}/lab_storage_$(date +%Y%m%d%H%M%S)"
    echo "Backup created in $BACKUP_DIR"
fi

# Cleanup demo
echo "Directory verification:"
ls -lR "$BASE_DIR"
