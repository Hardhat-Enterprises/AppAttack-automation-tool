#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Color Codes ===
BYellow="\033[1;33m"
BRed="\033[1;31m"
BGreen="\033[1;32m"
BBlue="\033[1;34m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"

# === Banner ===
display_banner() {
    clear
    echo -e "${BRed}"
    echo -e " █████╗ ██████╗ ██████╗     ███████╗██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗"
    echo -e "██╔══██╗██╔══██╗██╔══██╗    ██╔════╝╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║"
    echo -e "███████║██████╔╝██████╔╝    █████╗   ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║   ███████║   ██║   ██║██║   ██║██╔██╗ ██║"
    echo -e "██╔══██║██╔═══╝ ██╔═══╝     ██╔══╝   ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║   ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║"
    echo -e "██║  ██║██║     ██║         ███████╗██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║   ██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║"
    echo -e "╚═╝  ╚═╝╚═╝     ╚═╝         ╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo -e "${NC}"
    echo -e "${BYellow}              Delta Report Generation${NC}"
    echo -e "${BBlue}           A Professional Penetration Testing Toolkit${NC}"
    echo -e ""
}

# === Delta Report Generation ===
create_delta_report() {
    display_banner
    read -p "Enter the path to the first scan report: " report1
    read -p "Enter the path to the second scan report: " report2

    if [ ! -f "$report1" ] || [ ! -f "$report2" ]; then
        echo -e "${BRed}Error: One or both report files not found.${NC}"
        exit 1
    fi

    echo -e "${BGreen}[*] Generating delta report...${NC}"

    delta_report="delta_report_$(date +%F_%H-%M-%S).txt"

    echo -e "${BYellow}### New Vulnerabilities ###${NC}" > "$delta_report"
    diff -u "$report1" "$report2" | grep -E '^\+' | sed 's/^\+//' >> "$delta_report"

    echo -e "\n${BYellow}### Fixed Vulnerabilities ###${NC}" >> "$delta_report"
    diff -u "$report1" "$report2" | grep -E '^\-' | sed 's/^\-//' >> "$delta_report"

    echo -e "${BGreen}[+] Delta report generated: $delta_report${NC}"
}

# === Main Execution ===

# create_delta_report
