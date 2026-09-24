#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must run as root." >&2
    exit 1
fi

TARGET_USER="labadmin"
TARGET_GROUP="engineers"
USER_HOME="/home/${TARGET_USER}"

echo "=== Provisioning User & Security Boundaries ==="

# Ensure target group exists
if ! getent group "$TARGET_GROUP" >/dev/null 2>&1; then
    groupadd "$TARGET_GROUP"
    echo "Created group: $TARGET_GROUP"
fi

# Create user idempotently
if ! id "$TARGET_USER" >/dev/null 2>&1; then
    useradd -m -g "$TARGET_GROUP" -s /bin/bash "$TARGET_USER"
    echo "Created user: $TARGET_USER"
else
    usermod -g "$TARGET_GROUP" "$TARGET_USER"
    echo "User $TARGET_USER exists. Ensured primary group $TARGET_GROUP."
fi

# SSH key generation and boundary enforcement
SSH_DIR="${USER_HOME}/.ssh"
mkdir -p "$SSH_DIR"
chmod 0700 "$SSH_DIR"

if [[ ! -f "${SSH_DIR}/id_ed25519" ]]; then
    ssh-keygen -t ed25519 -N "" -f "${SSH_DIR}/id_ed25519" -C "${TARGET_USER}@lab"
    cat "${SSH_DIR}/id_ed25519.pub" >> "${SSH_DIR}/authorized_keys"
fi

chmod 0600 "${SSH_DIR}/authorized_keys"
chown -R "${TARGET_USER}:${TARGET_GROUP}" "$SSH_DIR"

# Safe sudo configuration via visudo validation
SUDO_FILE="/etc/sudoers.d/${TARGET_USER}"
echo "${TARGET_USER} ALL=(ALL) NOPASSWD: ALL" > "$SUDO_FILE"
chmod 0440 "$SUDO_FILE"

if visudo -cf "$SUDO_FILE" >/dev/null 2>&1; then
    echo "[SUCCESS] Sudo drop-in validated and applied for $TARGET_USER"
else
    rm -f "$SUDO_FILE"
    echo "[ERROR] Invalid syntax in $SUDO_FILE. Reverted." >&2
    exit 1
fi
