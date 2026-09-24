#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] This script must run as root." >&2
    exit 1
fi

SERVICE_NAME="system-heartbeat"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
SCRIPT_EXEC="/usr/local/bin/heartbeat.sh"

echo "=== Creating and Managing a Systemd Unit ==="

# 1. Create a dummy daemon payload
cat <<'EOF' > "$SCRIPT_EXEC"
#!/usr/bin/env bash
while true; do
    echo "Heartbeat tick: $(date -u +'%Y-%m-%dT%H:%M:%SZ') - Memory Free: $(awk '/MemFree/ {print $2}' /proc/meminfo) kB"
    sleep 30
done
EOF
chmod 0755 "$SCRIPT_EXEC"

# 2. Write custom unit file
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=RH024 Lab Heartbeat Service
After=network.target

[Service]
Type=simple
ExecStart=${SCRIPT_EXEC}
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

chmod 0644 "$SERVICE_FILE"

# 3. Reload daemon and start service
systemctl daemon-reload
systemctl enable --now "${SERVICE_NAME}.service"

echo "Service status:"
systemctl is-active --quiet "$SERVICE_NAME" && echo "Status: ACTIVE"

# 4. View immediate logs
echo "Recent service logs:"
journalctl -u "$SERVICE_NAME" -n 5 --no-pager