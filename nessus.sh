#!/bin/bash
set -e

PORT="8834"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------
# Detect Nessus containers by IMAGE name (robust)
# ---------------------------------------------------------
detect_nessus_containers() {
    docker ps -a --format "{{.ID}} {{.Image}}" | \
    grep "tenable/nessus" | awk '{print $1}'
}

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

    echo "[+] Removing old Nessus containers (if any)..."
    uninstall_nessus >/dev/null 2>&1 || true

    echo "[+] Running Nessus container..."
    docker run -d \
        --name nessus \
        -p ${PORT}:8834 \
        "$IMAGE"

    echo "[✓] Installation complete."
    echo "[+] Access Nessus at: https://localhost:${PORT}"
}

# ---------------------------------------------------------
# Uninstall Nessus
# ---------------------------------------------------------
uninstall_nessus() {
    echo "[!] Searching for Nessus containers..."

    CONTAINERS=$(detect_nessus_containers)

    if [ -z "$CONTAINERS" ]; then
        echo "[!] No Nessus containers found."
        return
    fi

    for CID in $CONTAINERS; do
        echo "[!] Stopping container $CID..."
        docker stop "$CID" 2>/dev/null || true

        echo "[!] Removing container $CID..."
        docker rm "$CID" 2>/dev/null || true
    done

    echo "[✓] Nessus containers removed."
}

# ---------------------------------------------------------
# Keygen Nessus
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
# Renew Nessus
# ---------------------------------------------------------
renew_license() {
    CID=$(detect_nessus_containers | head -n1)

    if [ -z "$CID" ]; then
        echo "[!] Nessus container is not running!"
        return
    fi

    echo -n "Enter new Nessus License: "
    read LICENSE

    if [ -z "$LICENSE" ]; then
        echo "[!] License cannot be empty!"
        return
    fi

    echo "[+] Registering license inside container $CID ..."
    docker exec -it "$CID" /opt/nessus/sbin/nessuscli fetch --register "$LICENSE"

    echo "[✓] License registration executed."
}

# ---------------------------------------------------------
# MENU
# ---------------------------------------------------------
menu() {
    echo "=============================="
    echo "     Nessus Docker Manager"
    echo "=============================="
    echo "1. Install Nessus (Latest Version)"
    echo "2. Uninstall Nessus"
    echo "3. Keygen Nessus"
    echo "4. Renew Nessus"
    echo "0. Exit"
    echo -n "Choose an option: "
    read opt

    case $opt in
        1) install_nessus ;;
        2) uninstall_nessus ;;
        3) run_license_script ;;
        4) renew_license ;;
        0) exit 0 ;;
        *) echo "[!] Invalid option" ;;
    esac
}

menu
