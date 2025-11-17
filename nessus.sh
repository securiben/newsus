#!/bin/bash
set -e

CONTAINER_NAME="nessus-latest"
PORT="8834"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------
# Fetch latest Nessus version tag from Docker Hub
# ---------------------------------------------------------
get_latest_nessus() {
    echo "[+] Fetching latest Nessus version from Docker Hub..."

    LATEST_TAG=$(curl -s "https://registry.hub.docker.com/v2/repositories/tenable/nessus/tags?page_size=1" \
        | jq -r '.results[0].name')

    if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
        echo "[!] Failed to detect latest version!"
        exit 1
    fi

    IMAGE="tenable/nessus:${LATEST_TAG}"
    echo "[+] Latest Nessus version detected: $IMAGE"
}

# ---------------------------------------------------------
# Install Nessus Docker using latest version
# ---------------------------------------------------------
install_nessus() {
    get_latest_nessus

    echo "[+] Pulling Nessus image: $IMAGE"
    docker pull "$IMAGE"

    echo "[+] Running Nessus container: $CONTAINER_NAME"
    docker run --name "$CONTAINER_NAME" -d -p ${PORT}:8834 "$IMAGE"

    echo "[✓] Installation complete."
    echo "[+] Access Nessus at: https://localhost:${PORT}"
}

# ---------------------------------------------------------
# Uninstall / Reset Nessus
# ---------------------------------------------------------
uninstall_nessus() {
    echo "[!] Stopping and removing Nessus container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true

    echo "[!] Optional cleanup: removing unused Docker data"
    docker system prune -f

    echo "[✓] Nessus Docker reset completed."
}

# ---------------------------------------------------------
# Run nessuslicense.py
# ---------------------------------------------------------
run_license_script() {
    if [ -f "$SCRIPT_DIR/nessuslicense.py" ]; then
        echo "[+] Running nessuslicense.py..."
        python3 "$SCRIPT_DIR/nessuslicense.py"
    else
        echo "[!] nessuslicense.py not found!"
    fi
}

# ---------------------------------------------------------
# Run GrabLicenseKey.sh
# ---------------------------------------------------------
run_grablicense() {
    if [ -f "$SCRIPT_DIR/GrabLicenseKey.sh" ]; then
        echo "[+] Running GrabLicenseKey.sh..."
        bash "$SCRIPT_DIR/GrabLicenseKey.sh"
    else
        echo "[!] GrabLicenseKey.sh not found!"
    fi
}

# ---------------------------------------------------------
# MENU
# ---------------------------------------------------------
menu() {
    echo "=============================="
    echo "     Nessus Docker Manager"
    echo "=============================="
    echo "1. Install Nessus (Latest Version)"
    echo "2. Uninstall / Reset Nessus"
    echo "3. Run nessuslicense.py"
    echo "4. Run GrabLicenseKey.sh"
    echo "0. Exit"
    echo -n "Choose an option: "
    read opt

    case $opt in
        1) install_nessus ;;
        2) uninstall_nessus ;;
        3) run_license_script ;;
        4) run_grablicense ;;
        0) exit 0 ;;
        *) echo "[!] Invalid option";;
    esac
}

menu
