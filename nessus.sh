#!/bin/bash

set -e

IMAGE="tenable/nessus:10.9.4-ubuntu-20250928"
CONTAINER_NAME="nessus-10.9.4"
PORT="8834"

install_nessus() {
    echo "[+] Pulling Nessus image: $IMAGE"
    docker pull "$IMAGE"

    echo "[+] Running Nessus container: $CONTAINER_NAME"
    docker run --name "$CONTAINER_NAME" -d -p ${PORT}:8834 "$IMAGE"

    echo "[+] Installation complete. Access Nessus at: https://localhost:${PORT}"
}

uninstall_nessus() {
    echo "[!] Stopping and removing Nessus container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true

    echo "[!] Removing unused Docker data (optional cleanup)"
    docker system prune -f

    echo "[+] Nessus Docker reset completed."
}

menu() {
    echo "=============================="
    echo "   Nessus Docker Manager"
    echo "=============================="
    echo "1. Install Nessus Docker"
    echo "2. Uninstall / Reset Nessus Docker"
    echo "3. Run nessuslisense.py"
echo "4. Run GrabLicense"
echo "0. Exit"
    echo -n "Choose an option: "
    read opt

    case $opt in
        1) install_nessus ;;
        2) uninstall_nessus ;;
        3) python3 nessuslisense.py ;;
        4) python3 GrabLicense ;;
        0) exit 0 ;;
        *) echo "Invalid option" ;;
    esac
}

menu
