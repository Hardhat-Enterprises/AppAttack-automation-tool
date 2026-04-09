#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config FIRST (colours, display_banner, etc.) ===
source "$SCRIPT_DIR/config.sh"

# === Module sources ===
source "$SCRIPT_DIR/recon.sh"
source "$SCRIPT_DIR/recon_workflows.sh"
source "$SCRIPT_DIR/attack_workflows.sh"
source "$SCRIPT_DIR/reporting.sh"
source "$SCRIPT_DIR/mobile.sh"
source "$SCRIPT_DIR/workflow.sh"
source "$SCRIPT_DIR/run_tools.sh"

# NOTE: display_banner is now defined in config.sh and accepts an optional
# subtitle argument.  The local copy that was here has been removed.

# ---------------------------------------------------------------------------
# Menu display functions
# ---------------------------------------------------------------------------
display_main_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Main Menu            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Penetration Testing Tools${NC}"
    echo -e "${BCyan}2)${NC} ${White}Secure Code Review Tools${NC}"
    echo -e "${BCyan}3)${NC} ${White}IoT Security Tools${NC}"
    echo -e "${BCyan}4)${NC} ${White}Step by Step Guide${NC}"
    echo -e "${BCyan}5)${NC} ${White}Automated Processes${NC}"
    echo -e "${BCyan}6)${NC} ${White}Container Security Tools${NC}"
    echo -e "${BCyan}7)${NC} ${White}Cloud Security Tools${NC}"
    echo -e "${BCyan}8)${NC} ${White}Mobile Security Tools${NC}"
    echo -e "${BCyan}0)${NC} ${White}Exit${NC}"
    echo -e "${BYellow}╚════════════════════════════════╝${NC}"
}

display_mobile_security_tools_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Mobile Security Tools             ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}MobSF: Mobile Security Framework${NC}"
    echo -e "${BCyan}2)${NC} ${White}Start Android Emulator with mitmproxy${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

display_container_security_tools_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Container Security Tools            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Trivy: Scan Docker/OCI images for vulnerabilities${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

display_penetration_testing_tools_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Penetration Testing Tools           ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC}  ${BWhite}nmap${NC}: Network exploration and security auditing tool"
    echo -e "${BCyan}2)${NC}  ${BWhite}nikto${NC}: Web server scanner"
    echo -e "${BCyan}3)${NC}  ${BWhite}LEGION${NC}: Automated web application security scanner"
    echo -e "${BCyan}4)${NC}  ${BWhite}OWASP ZAP${NC}: Web application security testing tool"
    echo -e "${BCyan}5)${NC}  ${BWhite}John the Ripper${NC}: Password cracking tool"
    echo -e "${BCyan}6)${NC}  ${BWhite}SQLmap${NC}: SQL Injection and database takeover tool"
    echo -e "${BCyan}7)${NC}  ${BWhite}Metasploit Framework${NC}: Penetration testing framework"
    echo -e "${BCyan}8)${NC}  ${BWhite}Wapiti${NC}: Web Application Vulnerability Scanner"
    echo -e "${BCyan}9)${NC}  ${BWhite}Gobuster${NC}: Directory and DNS brute-forcing tool"
    echo -e "${BCyan}10)${NC} ${BWhite}Subfinder${NC}: Subdomain enumeration"
    echo -e "${BCyan}11)${NC} ${BWhite}Automated Scan${NC}: Run an automated vulnerability scan"
    echo -e "${BCyan}0)${NC}  ${BWhite}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

display_secure_code_review_tools_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Secure Code Review Tools            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}osv-scanner: Scan a directory for vulnerabilities${NC}"
    echo -e "${BCyan}2)${NC} ${White}snyk cli: Test code locally or monitor for vulnerabilities${NC}"
    echo -e "${BCyan}3)${NC} ${White}brakeman: Scan a Ruby on Rails application for security vulnerabilities${NC}"
    echo -e "${BCyan}4)${NC} ${White}bandit: Security linter for Python code${NC}"
    echo -e "${BCyan}5)${NC} ${White}Gitleaks: Secret scanning tool${NC}"
    echo -e "${BCyan}6)${NC} ${White}SonarQube: Continuous inspection of code quality and security${NC}"
    echo -e "${BCyan}7)${NC} ${White}Dredd: API Security Testing (OpenAPI/Swagger)${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

display_iot_security_tools_menu() {
    echo -e "\n${BYellow}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║            IoT Security Tools            ║${NC}"
    echo -e "${BYellow}╚══════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC}  ${White}Aircrack-ng${NC}"
    echo -e "${BCyan}2)${NC}  ${White}Bettercap${NC}"
    echo -e "${BCyan}3)${NC}  ${White}Binwalk${NC}"
    echo -e "${BCyan}4)${NC}  ${White}Hashcat${NC}"
    echo -e "${BCyan}5)${NC}  ${White}Miranda${NC}"
    echo -e "${BCyan}6)${NC}  ${White}Ncrack${NC}"
    echo -e "${BCyan}7)${NC}  ${White}Nmap${NC}"
    echo -e "${BCyan}8)${NC}  ${White}Reaver${NC}"
    echo -e "${BCyan}9)${NC}  ${White}Scapy${NC}"
    echo -e "${BCyan}10)${NC} ${White}Umap${NC}"
    echo -e "${BCyan}11)${NC} ${White}Wifiphisher${NC}"
    echo -e "${BCyan}12)${NC} ${White}Wireshark${NC}"
    echo -e "${BCyan}0)${NC}  ${White}Go Back${NC}"
    echo -e "${BYellow}╚═══════════════════════════════════════════╝${NC}"
}

display_step_by_step_guide_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Step by Step Guide               ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Learn about Pen Testing tools${NC}"
    echo -e "${BCyan}2)${NC} ${White}Learn about Secure code review tools${NC}"
    echo -e "${BCyan}3)${NC} ${White}Learn about IoT Security tools${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

display_automated_processes_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Automated Processes               ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC}  ${White}Reconnaissance${NC}"
    echo -e "${BCyan}2)${NC}  ${White}Vulnerability Scanning${NC}"
    echo -e "${BCyan}3)${NC}  ${White}Exploitation${NC}"
    echo -e "${BCyan}4)${NC}  ${White}Post-Exploitation${NC}"
    echo -e "${BCyan}5)${NC}  ${White}Reporting${NC}"
    echo -e "${BCyan}6)${NC}  ${White}Web Application Footprinting${NC}"
    echo -e "${BCyan}7)${NC}  ${White}API Reconnaissance${NC}"
    echo -e "${BCyan}8)${NC}  ${White}Delta Report Generation${NC}"
    echo -e "${BCyan}9)${NC}  ${White}Trend Analysis Report Generation${NC}"
    echo -e "${BCyan}10)${NC} ${White}Automated Mobile Scan${NC}"
    echo -e "${BCyan}11)${NC} ${White}Workflow Builder${NC}"
    echo -e "${BCyan}0)${NC}  ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

display_cloud_security_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Cloud Security Tools             ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}ScoutSuite (Audit AWS/Azure/GCP)${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

# Inline step-by-step summary displays (these are informational text, not menus)
display_step_by_step_guide_pen_testing() {
    echo -e "${YELLOW}Penetration Testing Tools step by step guide:${NC}"
    echo -e "${CYAN}1) nmap${NC}: Network exploration and security auditing tool"
    echo -e "${MAGENTA}2) nikto${NC}: Web server scanner"
    echo -e "${CYAN}3) LEGION${NC}: Automated web application security scanner"
    echo -e "${MAGENTA}4) OWASP ZAP${NC}: Web application security testing tool"
    echo -e "${CYAN}5) John the Ripper${NC}: Password cracking tool"
    echo -e "${MAGENTA}6) SQLmap${NC}: SQL Injection and database takeover tool"
    echo -e "${CYAN}7) Metasploit Framework${NC}: Penetration testing framework"
    echo -e "${MAGENTA}8) Wapiti${NC}: Web Application Vulnerability Scanner"
    echo -e "${YELLOW}0) Go Back${NC}"
}

display_step_by_step_guide_secure_code_review() {
    echo -e "${YELLOW}Secure Code Review Tools:${NC}"
    echo -e "${CYAN}1) osv-scanner${NC}: Scan a directory for vulnerabilities"
    echo -e "${MAGENTA}2) snyk cli${NC}: Test code locally or monitor for vulnerabilities"
    echo -e "${CYAN}3) brakeman${NC}: Scan a Ruby on Rails application for security vulnerabilities"
    echo -e "${MAGENTA}4) bandit${NC}: Security linter for Python code"
    echo -e "${CYAN}5) SonarQube${NC}: Continuous inspection of code quality and security"
    echo -e "${YELLOW}0) Go Back${NC}"
}

display_step_by_step_guide_iot_security_tools() {
    echo -e "${YELLOW}IoT Security Tools:${NC}"
    echo -e "${CYAN}1) Aircrack-ng${NC}: Crack WEP/WPA-PSK keys using captured data packets"
    echo -e "${MAGENTA}2) Bettercap${NC}: Perform reconnaissance and MITM attacks on IoT and wireless networks"
    echo -e "${CYAN}3) Scapy${NC}: Forge, analyze, and manipulate network packets for testing and debugging"
    echo -e "${MAGENTA}4) Wifiphisher${NC}: Simulate rogue access points for phishing and credential gathering"
    echo -e "${CYAN}5) Reaver${NC}: Perform brute-force attacks on WPS-enabled Wi-Fi networks"
    echo -e "${YELLOW}0) Go Back${NC}"
}

# ---------------------------------------------------------------------------
# Menu handler functions
# ---------------------------------------------------------------------------
handle_penetration_testing_tools() {
    local OUTPUT_DIR=$1
    local choice
    while true; do
        display_penetration_testing_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1)  run_nmap "$OUTPUT_DIR" "false" ;;
            2)  run_nikto "$OUTPUT_DIR" ;;
            3)  run_legion "$OUTPUT_DIR" ;;
            4)  run_owasp_zap "$OUTPUT_DIR" ;;
            5)  run_john "$OUTPUT_DIR" ;;
            6)  run_sqlmap "$OUTPUT_DIR" ;;
            7)  run_metasploit "$OUTPUT_DIR" ;;
            8)  run_wapiti "$OUTPUT_DIR" ;;
            9)  run_gobuster "$OUTPUT_DIR" ;;
            10) run_subfinder "$OUTPUT_DIR" ;;
            11) run_automated_scan ;;
            0)  break ;;
            *)  echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_secure_code_review_tools() {
    local OUTPUT_DIR=$1
    local choice
    while true; do
        display_secure_code_review_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_osv_scanner "$OUTPUT_DIR" ;;
            2) run_snyk "$OUTPUT_DIR" ;;
            3) run_brakeman "$OUTPUT_DIR" ;;
            4) run_bandit "$OUTPUT_DIR" ;;
            5) run_gitleaks_scan "$OUTPUT_DIR" ;;
            6) run_sonarqube "$OUTPUT_DIR" ;;
            7) run_dredd "$OUTPUT_DIR" ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_iot_security_tools() {
    local OUTPUT_DIR=$1
    local choice
    while true; do
        display_iot_security_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1)  run_aircrack "$OUTPUT_DIR" ;;
            2)  run_bettercap "$OUTPUT_DIR" ;;
            3)  run_binwalk "$OUTPUT_DIR" ;;
            4)  run_hashcat "$OUTPUT_DIR" ;;
            5)  run_miranda "$OUTPUT_DIR" ;;
            6)  run_ncrack "$OUTPUT_DIR" ;;
            7)  run_nmap "$OUTPUT_DIR" "true" ;;
            8)  run_reaver "$OUTPUT_DIR" ;;
            9)  run_scapy "$OUTPUT_DIR" ;;
            10) run_umap "$OUTPUT_DIR" ;;
            11) run_wifiphisher "$OUTPUT_DIR" ;;
            12) run_tshark "$OUTPUT_DIR" ;;
            0)  break ;;
            *)  echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_step_by_step_guide() {
    local choice
    while true; do
        display_step_by_step_guide_menu
        read -p "Choose an option: " choice
        case $choice in
            1) handle_step_by_step_guide_Pentest ;;
            2) handle_step_by_step_guide_SCR ;;
            3) handle_step_by_step_guide_IoT ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_automated_processes_menu() {
    local choice
    while true; do
        display_automated_processes_menu
        read -p "Choose an option: " choice
        case $choice in
            1)  run_automated_scan ;;
            2)  run_automated_vulnerability_scan ;;
            3)  run_exploitation_menu ;;
            4)  automate_post_exploitation ;;
            5)  automate_reporting ;;
            6)  run_footprinting_workflow ;;
            7)  run_api_recon_process ;;
            8)  create_delta_report ;;
            9)  create_trend_analysis_report ;;
            10) run_automated_mobile_scan ;;
            11) handle_workflow_builder ;;
            0)  break ;;
            *)  echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_container_security_tools() {
    local OUTPUT_DIR=$1
    local choice
    while true; do
        display_container_security_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_trivy "$OUTPUT_DIR" ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_cloud_security_tools() {
    while true; do
        display_cloud_security_menu
        read -p "Choose a cloud security tool: " cloud_choice
        case $cloud_choice in
            1)
                read -p "Enter cloud provider (aws/azure/gcp): " provider
                read -p "Enter profile (leave blank for default): " profile
                run_scoutsuite_scan "$provider" "$profile"
                ;;
            0) break ;;
            *) echo "Invalid choice, try again." ;;
        esac
    done
}

handle_mobile_security_tools() {
    local choice
    while true; do
        display_mobile_security_tools_menu
        read -p "Choose a mobile security tool: " choice
        case $choice in
            1) run_mobsf ;;
            2) start_android_emulator ;;
            0) break ;;
            *) echo "Invalid choice, try again." ;;
        esac
    done
}

handle_step_by_step_guide_SCR() {
    local choice
    while true; do
        display_step_by_step_guide_secure_code_review
        read -p "Choose an option: " choice
        case $choice in
            1) handle_step_by_step_SCR_OSV_Scanner ;;
            2) handle_step_by_step_SCR_Snyk ;;
            3) handle_step_by_step_SCR_brakeman ;;
            4) handle_step_by_step_SCR_bandit ;;
            5) handle_step_by_step_SCR_sonar ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_step_by_step_guide_Pentest() {
    local choice
    while true; do
        display_step_by_step_guide_pen_testing
        read -p "Choose an option: " choice
        case $choice in
            1) handle_step_by_step_pentest_nmap ;;
            2) handle_step_by_step_pentest_nitko ;;
            3) handle_step_by_step_pentest_legion ;;
            4) handle_step_by_step_pentest_owasp_zap ;;
            5) handle_step_by_step_pentest_John_the_ripper ;;
            6) handle_step_by_step_pentest_SQLmap ;;
            7) handle_step_by_step_pentest_metasploit ;;
            8) handle_step_by_step_pentest_wapiti ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

handle_step_by_step_guide_IoT() {
    local choice
    while true; do
        display_step_by_step_guide_iot_security_tools
        read -p "Choose an option: " choice
        case $choice in
            1) handle_step_by_step_IoT_aircrack ;;
            2) handle_step_by_step_IoT_bettercap ;;
            3) handle_step_by_step_IoT_scapy ;;
            4) handle_step_by_step_IoT_wifiphisher ;;
            5) handle_step_by_step_IoT_reaver ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# Reporting pipeline helper (wires output dirs into automate_reporting.sh)
# ---------------------------------------------------------------------------
run_reporting_process() {
    local base_dir="$SCRIPT_DIR/../output"
    local report_file="$base_dir/final_report.md"
    mkdir -p "$(dirname "$report_file")"
    : > "$report_file"
    for phase in Reconnaissance Scanning Exploitation "Post-Exploitation"; do
        local phase_dir="$base_dir/$phase"
        if [[ -d "$phase_dir" ]]; then
            for input in "$phase_dir"/*; do
                [[ -f "$input" ]] || continue
                local tool_name; tool_name=$(basename "$input" | sed 's/\..*//')
                "$SCRIPT_DIR/automate_reporting.sh" \
                    -t "$tool_name" -i "$input" -o "$report_file" -p "$phase" -f md
            done
        fi
    done
    echo "Final report generated at $report_file"
}

run_api_recon_process() {
    automate_api_recon_process
}
