#!/bin/bash
# =============================================================================
# recon_workflows.sh — Automated footprinting and API reconnaissance workflows
#
# Replaces: automate_footprinting.sh, automate_api_recon.sh
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, display_banner, LOG_FILE, etc.) ===
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# =============================================================================
# SECTION 1 — WEB APPLICATION FOOTPRINTING
# Subdomain discovery → live host probing → port scan
# =============================================================================

run_footprinting_workflow() {
    display_banner "Automated Web Application Footprinting Workflow"

    read -p "Enter target domain: " target_domain

    local OUTPUT_DIR="footprinting_logs"
    mkdir -p "$OUTPUT_DIR"

    echo -e "${BGreen}[*] Running subfinder on $target_domain...${NC}"
    subfinder -d "$target_domain" -o "$OUTPUT_DIR/subdomains.txt"

    echo -e "${BGreen}[*] Running httpx on discovered subdomains...${NC}"
    httpx -l "$OUTPUT_DIR/subdomains.txt" -o "$OUTPUT_DIR/live_hosts.txt"

    echo -e "${BGreen}[*] Running nmap on live hosts...${NC}"
    nmap -iL "$OUTPUT_DIR/live_hosts.txt" -oN "$OUTPUT_DIR/nmap_scan.txt"

    echo -e "${BGreen}[+] Footprinting workflow completed. Results in $OUTPUT_DIR${NC}"
}

# =============================================================================
# SECTION 2 — API RECONNAISSANCE
# Validates API spec with Dredd, then scans with Nmap and Nikto
# =============================================================================

automate_api_recon_process() {
    display_banner "API Reconnaissance Workflow"

    read -p "Enter the target API endpoint (e.g., http://localhost:3000): " target
    read -p "Enter the path to the API description document (e.g., /path/to/api.yaml): " api_description

    local log_file="api_recon_$(date +%Y-%m-%d_%H-%M-%S).log"
    exec > >(tee -a "$log_file") 2>&1

    echo -e "${BGreen}Logging output to $log_file${NC}"

    echo -e "${BYellow}Running Dredd...${NC}"
    dredd "$api_description" "$target" \
        || { echo -e "${BRed}Dredd failed. Aborting.${NC}"; return 1; }

    echo -e "${BYellow}Running Nmap...${NC}"
    nmap -p- -sV "$target" \
        || { echo -e "${BRed}Nmap failed. Aborting.${NC}"; return 1; }

    echo -e "${BYellow}Running Nikto...${NC}"
    nikto -h "$target" \
        || { echo -e "${BRed}Nikto failed. Aborting.${NC}"; return 1; }

    echo -e "${BGreen}API Reconnaissance Workflow completed successfully.${NC}"
}
