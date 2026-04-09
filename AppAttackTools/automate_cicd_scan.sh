#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# CI mode: non-interactive fast path (runs before sourcing anything heavy)
if [[ "${CI:-}" == "true" ]]; then
    echo "[CI] Non-interactive mode: running Trivy + Gitleaks"
    trivy fs -q --format json -o trivy_output.json \
        --severity CRITICAL,HIGH --exit-code 0 .
    gitleaks detect --source . --report-format json \
        --report-path gitleaks_output.json || true
    exit 0
fi

set -euo pipefail

# === Shared config (colours, etc.) ===
source "$SCRIPT_DIR/config.sh"

echo -e "${BGreen}[+] CI/CD Security Scan Menu${NC}"
echo "1) Run Trivy only"
echo "2) Run Gitleaks only"
echo "3) Run Both (Trivy + Gitleaks)"
echo "4) Exit"

read -p "Select an option [1-4]: " choice

case $choice in
    1)
        echo "[*] Running Trivy..."
        trivy fs --quiet --format json --output trivy_output.json .
        echo -e "${BGreen}[+] Trivy scan done. Output: trivy_output.json${NC}"
        ;;
    2)
        echo "[*] Running Gitleaks..."
        gitleaks detect --source . --report-format json --report-path gitleaks_output.json
        echo -e "${BGreen}[+] Gitleaks scan done. Output: gitleaks_output.json${NC}"
        ;;
    3)
        echo "[*] Running Trivy..."
        trivy fs --quiet --format json --output trivy_output.json .
        echo "[*] Running Gitleaks..."
        gitleaks detect --source . --report-format json --report-path gitleaks_output.json
        echo -e "${BGreen}[+] Both scans completed. Outputs: trivy_output.json & gitleaks_output.json${NC}"
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${BRed}[!] Invalid option. Please run again.${NC}"
        exit 1
        ;;
esac
