

#!/bin/bash


# Dynamically determine the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required libraries with absolute paths
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# === Color Codes ===

# === Color Codes ===
BYellow="\033[1;33m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"


display_reconnaissance_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Reconnaissance Workflows         ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Basic Host Discovery (Nmap Ping Scan)${NC}"
    echo -e "${BCyan}2)${NC} ${White}Full Port & Service Scan (Nmap)${NC}"
    echo -e "${BCyan}3)${NC} ${White}Web Server Vulnerability Scan (Nikto)${NC}"
    echo -e "${BCyan}4)${NC} ${White}Passive Web Recon (Wapiti Spidering)${NC}"
    echo -e "${BCyan}5)${NC} ${White}Packet Capture (Tshark)${NC}"
    echo -e "${BCyan}6)${NC} ${White}GUI Recon Tool (Legion)${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back (to Main Menu)${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

# === Recon Tool Execution Functions ===
run_basic_host_discovery() {
    read -p "Enter target subnet (e.g. 192.168.1.0/24): " target
    echo "[*] Running Nmap Ping Scan on $target..."
    nmap -sn "$target"
    echo "[+] Ping scan finished."
}

run_full_port_scan() {
    read -p "Enter target IP or domain: " target
    echo "[*] Running full port scan on $target..."
    nmap -p- -sV "$target"
    echo "[+] Full port scan complete."
}

run_web_server_scan() {
    read -p "Enter target IP or domain: " target
    read -p "Enter port (default 80): " port
    port=${port:-80}
    nikto -h "$target" -p "$port"
}

run_passive_web_recon() {
    read -p "Enter target URL (e.g. http://example.com): " url
    echo "[*] Running Wapiti scan on $url..."
    wapiti -u "$url" -f html -o "wapiti_report.html"
    echo "[+] Wapiti scan completed. Report saved to wapiti_report.html"
}



run_packet_capture() {
    read -p "Enter interface to sniff (e.g. eth0): " iface
    tshark -i "$iface" -a duration:10 -w "capture.pcap"
    echo "[+] Packet capture saved to capture.pcap"
}

run_legion() {
    echo "[*] Starting Legion GUI..."
    legion &
}

# === Recon Menu Dispatcher ===
run_reconnaissance_menu() {
    while true; do
        display_reconnaissance_menu
        read -p "Choose a Reconnaissance option: " choice
        case $choice in
            1) run_basic_host_discovery ;;
            2) run_full_port_scan ;;
            3) run_web_server_scan ;;
            4) run_passive_web_recon ;;
            5) run_packet_capture ;;
            6) run_legion ;;
            0) return ;;
            *) echo "Invalid option. Please choose again." ;;
        esac
        echo "\nPress Enter to continue..."; read
    done
}

