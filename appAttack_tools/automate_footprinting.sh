#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Source Libraries ===
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# === Color Codes ===
BYellow="\033[1;33m"
BRed="\033[1;31m"
BGreen="\033[1;32m"
BBlue="\033[1;34m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"

# === Default Variables ===
OUTPUT_DIR="footprinting_logs"
TARGET_DOMAIN=""

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
    echo -e "${BYellow}              Automated Web Application Footprinting Workflow${NC}"
    echo -e "${BBlue}           A Professional Penetration Testing Toolkit${NC}"
    echo -e ""
}

# === Footprinting Workflow ===
run_footprinting_workflow() {
    read -p "Enter target domain: " target_domain

    mkdir -p "$OUTPUT_DIR"

    echo -e "${BGreen}[*] Running subfinder on $target_domain...${NC}"
    subfinder -d "$target_domain" -o "$OUTPUT_DIR/subdomains.txt"

    echo -e "${BGreen}[*] Running httpx on the discovered subdomains...${NC}"
    httpx -l "$OUTPUT_DIR/subdomains.txt" -o "$OUTPUT_DIR/live_hosts.txt"

    echo -e "${BGreen}[*] Running nmap on the live hosts...${NC}"
    nmap -iL "$OUTPUT_DIR/live_hosts.txt" -oN "$OUTPUT_DIR/nmap_scan.txt"

    echo -e "${BGreen}[+] Footprinting workflow completed. Results in $OUTPUT_DIR${NC}"
}

# === Main Execution ===
display_banner
run_footprinting_workflow
