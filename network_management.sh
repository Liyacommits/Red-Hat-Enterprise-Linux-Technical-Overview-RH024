#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must run as root." >&2
    exit 1
fi

echo "=== Network & Firewall Audit ==="

# Active Interfaces & Addresses
echo "--- Network Interfaces ---"
ip -br addr show

# Open listening TCP/UDP ports
echo "--- Listening Sockets ---"
ss -tulpn

# Ensure firewalld is running
if ! systemctl is-active --quiet firewalld; then
    echo "Starting firewalld..."
    systemctl enable --now firewalld
fi

# Example rule: Idempotently configure custom port for an internal service
CUSTOM_PORT="8080/tcp"
if ! firewall-cmd --list-ports | grep -qw "$CUSTOM_PORT"; then
    echo "Opening port $CUSTOM_PORT..."
    firewall-cmd --permanent --add-port="$CUSTOM_PORT"
    firewall-cmd --reload
    echo "Port $CUSTOM_PORT opened."
else
    echo "Port $CUSTOM_PORT already open in firewall."
fi

echo "Current Active Firewall Configuration:"
firewall-cmd --list-all