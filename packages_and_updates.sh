#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must run as root." >&2
    exit 1
fi

REQUIRED_PACKAGES=("curl" "tar" "tmux" "bind-utils")

echo "=== Managing Packages and Repositories via DNF ==="

# Check enabled repositories
echo "Active Repositories:"
dnf repolist --enabled

# Query and install missing packages idempotently
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
        echo "Package '$pkg' is already installed."
    else
        echo "Installing '$pkg'..."
        dnf install -y "$pkg"
    fi
done

echo "[SUCCESS] Package baseline verification complete."