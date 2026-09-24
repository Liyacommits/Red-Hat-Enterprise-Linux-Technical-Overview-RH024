#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="/tmp/rhel_audit"
REPORT_FILE="${REPORT_DIR}/system_summary.txt"

mkdir -p "$REPORT_DIR"

echo "=== System Architecture & Shell Diagnostics ===" | tee "$REPORT_FILE"

# Kernel, OS release, and Host metadata
{
    echo "Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    echo "Hostname: $(hostname -f 2>/dev/null || hostname)"
    echo "Kernel Release: $(uname -r)"
    echo "OS Details:"
    grep -E '^(NAME|VERSION)=' /etc/os-release
    echo "Uptime & Load:"
    uptime
} >> "$REPORT_FILE"

# Redirection demo: standard output vs error stream capture
echo "Testing stream redirection..."
{
    echo "Standard output capture test"
    # Deliberately attempt a non-existent path to demonstrate error redirection
    ls /non_existent_directory_test 2>&1 || true
} >> "$REPORT_FILE"

echo "[SUCCESS] System and shell report written to $REPORT_FILE"