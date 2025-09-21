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
    echo -e "${BYellow}              Trend Analysis Report Generation${NC}"
    echo -e "           A Professional Penetration Testing Toolkit${NC}"
    echo -e ""
}

# === Trend Analysis Report Generation ===
create_trend_analysis_report() {
    read -p "Enter the directory containing the scan reports: " reports_dir

    if [ ! -d "$reports_dir" ]; then
        echo -e "${BRed}Error: Directory not found.${NC}"
        exit 1
    fi

    echo -e "${BGreen}[*] Generating trend analysis report...${NC}"

    trend_report="trend_analysis_report_$(date +%F_%H-%M-%S).txt"

    echo -e "${BYellow}### Trend Analysis Report ###${NC}" > "$trend_report"

    for report in "$reports_dir"/*;
    do
        if [ -f "$report" ]; then
            echo -e "\n${BCyan}--- Report: $report ---${NC}" >> "$trend_report"
            echo -e "${White}" >> "$trend_report"
            cat "$report" >> "$trend_report"
        fi
    done

    echo -e "${BGreen}[+] Trend analysis report generated: $trend_report${NC}"
}

# === Main Execution ===
display_banner
create_trend_analysis_report
