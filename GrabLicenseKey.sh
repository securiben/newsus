#!/bin/bash

SCRIPT_PATH="/root/nessus/nessuslicense.py"

echo "=========================================="
echo "        GrabLicenseKey Launcher"
echo "=========================================="

echo "[+] Checking Python3..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "[!] python3 not found. Installing..."
    apt update && apt install -y python3
fi

echo "[+] Checking pip3..."
if ! command -v pip3 >/dev/null 2>&1; then
    echo "[!] pip3 not found. Installing..."
    apt update && apt install -y python3-pip
fi

echo "[+] Installing required Python modules..."
pip3 install requests --break-system-packages >/dev/null 2>&1

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "[!] ERROR: Python script not found at:"
    echo "    $SCRIPT_PATH"
    exit 1
fi

echo "[+] Running nessuslicense.py..."
python3 "$SCRIPT_PATH"

echo "[✓] Finished."
echo "=========================================="
