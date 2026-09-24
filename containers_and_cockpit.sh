#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must run as root." >&2
    exit 1
fi

echo "=== Modern RHEL Tools: Cockpit & Containers ==="

# 1. Cockpit Web Console Setup
echo "Ensuring Cockpit is installed and running on port 9090..."
if ! rpm -q cockpit >/dev/null 2>&1; then
    dnf install -y cockpit
fi

systemctl enable --now cockpit.socket
firewall-cmd --permanent --add-service=cockpit >/dev/null 2>&1 || true
firewall-cmd --reload >/dev/null 2>&1

echo "[INFO] Cockpit active at: https://$(hostname -I | awk '{print $1}'):9090"

# 2. Container Runtime Setup (Podman)
if ! rpm -q podman >/dev/null 2>&1; then
    echo "Installing Podman..."
    dnf install -y podman
fi

echo "Starting lightweight Nginx test container..."
# Stop and remove container if it already exists
podman rm -f test-web >/dev/null 2>&1 || true

podman run -d --name test-web \
    -p 8080:80 \
    docker.io/library/nginx:alpine

echo "Active containers:"
podman ps --format "{{.ID}} | {{.Names}} | {{.Status}} | {{.Ports}}"