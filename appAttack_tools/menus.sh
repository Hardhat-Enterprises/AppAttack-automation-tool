#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/automate_recon.sh"
source "$SCRIPT_DIR/automate_reconnaissance.sh"
source "$SCRIPT_DIR/automate_vulnerability_scan.sh"
source "$SCRIPT_DIR/auto_exploitation.sh"
source "$SCRIPT_DIR/automate_post_exploitation.sh"
source "$SCRIPT_DIR/automate_reporting.sh"




# Display the Banner
echo -e "${BYellow}                                                                           ${Color_Off}"
echo -e "${BRed} █████╗ ██████╗ ██████╗     █████╗ ████████╗████████╗ █████╗  ██████╗██╗  ██╗${Color_Off}"
echo -e "${BRed}██╔══██╗██╔══██╗██╔══██╗   ██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝${Color_Off}"
echo -e "${BGreen}███████║██████╔╝██████╔╝   ███████║   ██║      ██║   ███████║██║     █████╔╝ ${Color_Off}"
echo -e "${BGreen}██╔══██║██╔═══╝ ██╔═══╝    ██╔══██║   ██║      ██║   ██╔══██║██║     ██╔═██╗ ${Color_Off}"
echo -e "${BBlue}██║  ██║██║     ██║        ██║  ██║   ██║      ██║   ██║  ██║╚██████╗██║  ██╗${Color_Off}"
echo -e "${BBlue}╚═╝  ╚═╝╚═╝     ╚═╝        ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝${Color_Off}"
echo -e "${BYellow}                                                                           ${Color_Off}"
echo -e "${BPurple}              A Professional Pen-Testing/Secure Code Review Toolkit        ${Color_Off}"
#echo -e "${BCyan}Usage:${Color_Off} ./app-attack.sh [options]"


display_main_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Main Menu            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Penetration Testing Tools${NC}"
    echo -e "${BCyan}2)${NC} ${White}Secure Code Review Tools${NC}"
	echo -e "${BCyan}3)${NC} ${White}IoT Security Tools${NC}"
    echo -e "${BCyan}4)${NC} ${White}Step by Step Guide${NC}"
    echo -e "${BCyan}5)${NC} ${White}Automated Processes${NC}"  
    echo -e "${BCyan}6)${NC} ${White}Exit${NC}" 
    echo -e "${BYellow}╚════════════════════════════════╝${NC}"
}


# Function to display asterisks in order to make the display uncluttered.
#display_asterisk(){
   # echo -e "${YELLOW}"
    # Using a loop
   # for i in {1..100}; do
     #   echo -n "*"
 #   done
 #   echo  # Move to the next line after printing all asterisks
    
#}


# Function to display Penetration Testing Tools menu
display_penetration_testing_tools_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Penetration Testing Tools           ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${BWhite}nmap${NC}: Network exploration and security auditing tool"
    echo -e "${BCyan}2)${NC} ${BWhite}nikto${NC}: Web server scanner"
    echo -e "${BCyan}3)${NC} ${BWhite}LEGION${NC}: Automated web application security scanner"
    echo -e "${BCyan}4)${NC} ${BWhite}OWASP ZAP${NC}: Web application security testing tool"
    echo -e "${BCyan}5)${NC} ${BWhite}John the Ripper${NC}: Password cracking tool"
    echo -e "${BCyan}6)${NC} ${BWhite}SQLmap${NC}: SQL Injection and database takeover tool"
    echo -e "${BCyan}7)${NC} ${BWhite}Metasploit Framework${NC}: Penetration testing framework"
    echo -e "${BCyan}8)${NC} ${BWhite}Wapiti${NC}: Web Application Vulnerability Scanner"
    echo -e "${BCyan}9)${NC} ${BWhite}Automated Scan${NC}: Run an automated vulnerability scan"
    echo -e "${BCyan}0)${NC} ${BWhite}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}


# Function to display Secure Code Review Tools menu
display_secure_code_review_tools_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Secure Code Review Tools            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}osv-scanner: Scan a directory for vulnerabilities${NC}"
    echo -e "${BCyan}2)${NC} ${White}snyk cli: Test code locally or monitor for vulnerabilities${NC}"
    echo -e "${BCyan}3)${NC} ${White}brakeman: Scan a Ruby on Rails application for security vulnerabilities${NC}"
    echo -e "${BCyan}4)${NC} ${White}bandit: Security linter for Python code${NC}"
    echo -e "${BCyan}5)${NC} ${White}SonarQube: Continuous inspection of code quality and security${NC}"
    echo -e "${BCyan}6)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

# Function to display IoT Tools menu
display_iot_security_tools_menu() {
    echo -e "\n${BYellow}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║            IoT Security Tools            ║${NC}"
    echo -e "${BYellow}╚══════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Aircrack-ng${NC}"
    echo -e "${BCyan}2)${NC} ${White}Bettercap${NC}"
    echo -e "${BCyan}3)${NC} ${White}Binwalk${NC}"
    echo -e "${BCyan}4)${NC} ${White}Hashcat${NC}"
    echo -e "${BCyan}5)${NC} ${White}Miranda${NC}"
    echo -e "${BCyan}6)${NC} ${White}Ncrack${NC}"
    echo -e "${BCyan}7)${NC} ${White}Nmap${NC}"
    echo -e "${BCyan}8)${NC} ${White}Reaver${NC}"
    echo -e "${BCyan}9)${NC} ${White}Scapy${NC}"
    echo -e "${BCyan}10)${NC} ${White}Umap${NC}"
    echo -e "${BCyan}11)${NC} ${White}Wifiphisher${NC}"
    echo -e "${BCyan}12)${NC} ${White}Wireshark${NC}"
    echo -e "${BCyan}13)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚═══════════════════════════════════════════╝${NC}"
}

# Function to display Step by Step Guide menu
display_step_by_step_guide_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Step by Step Guide               ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Learn about Pen Testing tools${NC}"
    echo -e "${BCyan}2)${NC} ${White}Learn about Secure code review tools${NC}"
	echo -e "${BCyan}3)${NC} ${White}Learn about IoT Security tools${NC}"
    echo -e "${BCyan}4)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

# Function to display Automated Processes menu
display_automated_processes_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║        Automated Processes               ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Reconnaissance${NC}"
    echo -e "${BCyan}2)${NC} ${White}Vulnerability Scanning${NC}"
    echo -e "${BCyan}3)${NC} ${White}Exploitation${NC}"
    echo -e "${BCyan}4)${NC} ${White}Post-Exploitation${NC}"
    echo -e "${BCyan}5)${NC} ${White}Reporting${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

# Function to display the step by step guide of the penetration testing tools.
display_step_by_step_guide_pen_testing(){
    
    echo -e "${YELLOW}Penetration Testing Tools step by step guide :${NC}"
    echo -e "${CYAN}1) nmap: Network exploration and security auditing tool${NC}"
    echo -e "${MAGENTA}2) nikto: Web server scanner${NC}"
    echo -e "${CYAN}3) LEGION: Automated web application security scanner${NC}"
    echo -e "${MAGENTA}4) OWASP ZAP: Web application security testing tool${NC}"
    echo -e "${CYAN}5) John the Ripper: Password cracking tool${NC}"
    echo -e "${MAGENTA}6) SQLmap: SQL Injection and database takeover tool${NC}"
    echo -e "${CYAN}7) Metasploit Framework: Penetration testing framework${NC}"
    echo -e "${MAGENTA}8) Wapiti: Web Application Vulnerability Scanner${NC}"
    echo -e "${YELLOW}9) Go Back${NC}"
   # display_asterisk
    
}

# Function to display the step by step guide of the Secure Code Review tools.

display_step_by_step_guide_secure_code_review(){
    
    echo -e "${YELLOW}Secure Code Review Tools:${NC}"
    echo -e "${CYAN}1) osv-scanner: Scan a directory for vulnerabilities${NC}"
    echo -e "${MAGENTA}2) snyk cli: Test code locally or monitor for vulnerabilities${NC}"
    echo -e "${CYAN}3) brakeman: Scan a Ruby on Rails application for security vulnerabilities${NC}"
    echo -e "${MAGENTA}4) bandit: Security linter for Python code${NC}"
    echo -e "${CYAN}5) SonarQube: Continuous inspection of code quality and security${NC}"
    echo -e "${YELLOW}6) Go Back"
  #  display_asterisk
    
}

display_step_by_step_guide_iot_security_tools(){
    
    echo -e "${YELLOW}IoT Security Tools:${NC}"
    echo -e "${CYAN}1) Aircrack-ng: Crack WEP/WPA-PSK keys using captured data packets${NC}"
    echo -e "${MAGENTA}2) Bettercap: Perform reconnaissance and MITM attacks on IoT and wireless networks${NC}"
    echo -e "${CYAN}3) Scapy: Forge, analyze, and manipulate network packets for testing and debugging.${NC}"
    echo -e "${MAGENTA}4) Wifiphisher: Simulate rogue access points for phishing and credential gathering.${NC}"
	echo -e "${CYAN}5) Reaver: Perform brute-force attacks on WPS-enabled Wi-Fi networks to recover the WPA/WPA2 passphrase.${NC}"
    echo -e "${YELLOW}6) Go Back"
  #  display_asterisk
}


#Handle Options

# Function for Penetration Testing Tools
handle_penetration_testing_tools() {
    # Run Wapiti scan
    local OUTPUT_DIR=$1
    local choice
    while true; do
        display_penetration_testing_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_nmap "$OUTPUT_DIR" "false" ;;
            2) run_nikto "$OUTPUT_DIR" ;;
            3) run_legion "$OUTPUT_DIR" ;;
            4) run_owasp_zap "$OUTPUT_DIR" ;;
            5) run_john "$OUTPUT_DIR" ;;
            6) run_sqlmap "$OUTPUT_DIR" ;;
            7) run_metasploit "$OUTPUT_DIR" ;;
	        8) run_wapiti "$OUTPUT_DIR" ;;
            9) run_automated_scan ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

# Function for Secure Code Review Tools
handle_secure_code_review_tools() {
    OUTPUT_DIR=$1
    local choice
    while true; do
        display_secure_code_review_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_osv_scanner "$OUTPUT_DIR" ;;
            2) run_snyk "$OUTPUT_DIR" ;;
            3) run_brakeman "$OUTPUT_DIR" ;;
            4) run_bandit "$OUTPUT_DIR" ;;
            5) run_sonarqube "$OUTPUT_DIR" ;;
            6) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

# Function for IoT Security Tools
handle_iot_security_tools() {
    local OUTPUT_DIR=$1
    local choice
    while true; do
        display_iot_security_tools_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_aircrack "$OUTPUT_DIR" ;;
            2) run_bettercap "$OUTPUT_DIR" ;;
            3) run_binwalk "$OUTPUT_DIR" ;;
            4) run_hashcat "$OUTPUT_DIR" ;;
            5) run_miranda "$OUTPUT_DIR" ;;
            6) run_ncrack "$OUTPUT_DIR" ;;
            7) run_nmap "$OUTPUT_DIR" "true" ;;
            8) run_reaver "$OUTPUT_DIR" ;;
            9) run_scapy "$OUTPUT_DIR" ;;
            10) run_umap "$OUTPUT_DIR" ;;
            11) run_wifiphisher "$OUTPUT_DIR" ;;
            12) run_tshark "$OUTPUT_DIR" ;;
            13) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

# Function for handling the step by step guide
handle_step_by_step_guide(){
    
    local choice
    
    while true; do
        
        display_step_by_step_guide_menu
        
        read -p "Choose an option: " choice
        
        case $choice in
            
            1) handle_step_by_step_guide_Pentest;;
            2) handle_step_by_step_guide_SCR;;
			3) handle_step_by_step_guide_IoT;;
            4) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
            
        esac
        
    done
    
}
# Function to handle Automated Processes menu
handle_automated_processes_menu() {
    local choice
    while true; do
     

   display_automated_processes_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_automated_reconnaissance_scan ;; # Placeholder for Reconnaissance
            2) run_vulnerability_scanning_process ;; # Placeholder
            3) run_exploitation_process ;; # Placeholder
            4) run_post_exploitation_process ;; # Placeholder
            5) run_reporting_process ;; # Placeholder
            0) break ;; # Go back to main menu
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

# Placeholder functions for automated processes (to be implemented later)
run_automated_reconnaissance_scan() {
    echo "Running Automated Reconnaissance Scan..."
    run_reconnaissance_menu
}

run_vulnerability_scanning_process() {
    echo "Running Vulnerability Scanning Process..."
    run_vulnerability_scanning_menu
}

run_exploitation_process() {
    echo "Running Exploitation Process..."
    run_exploitation_menu
}

run_post_exploitation_process() {
    echo "Running Post-Exploitation Process..."
    run_post_exploitation_menu
}

run_reporting_process() {
    echo "Running Reporting Process..."
    local base_dir="$SCRIPT_DIR/../output"
    local report_file="$base_dir/final_report.md"
    mkdir -p "$(dirname "$report_file")"
    > "$report_file"
    for phase in Reconnaissance Scanning Exploitation "Post-Exploitation"; do
        phase_dir="$base_dir/$phase"
        if [[ -d "$phase_dir" ]]; then
            for input in "$phase_dir"/*; do
                if [[ -f "$input" ]]; then
                    tool_name=$(basename "$input" | sed 's/\..*//')
                    "$SCRIPT_DIR/automate_reporting.sh" -t "$tool_name" -i "$input" -o "$report_file" -p "$phase" -f md
                fi
            done
        fi
    done
    echo "Final report generated at $report_file"
}

handle_step_by_step_guide_SCR(){
    
    local choice
    
    while true; do
        
        display_step_by_step_guide_secure_code_review
        
        read -p "Choose an option: " choice
        
        case $choice in
            
            1) handle_step_by_step_SCR_OSV_Scanner;;
            2) handle_step_by_step_SCR_Snyk ;;
            3) handle_step_by_step_SCR_brakeman;;
            4) handle_step_by_step_SCR_bandit;;
            5) handle_step_by_step_SCR_sonar ;;
            6) break;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
            
        esac
        
    done
    
    
    
}

handle_step_by_step_guide_Pentest(){
    
    local choice
    
    while true; do
        
        display_step_by_step_guide_pen_testing
        
        read -p "Choose an option: " choice
        
        case $choice in
            
            1) handle_step_by_step_pentest_nmap;;
            2) handle_step_by_step_pentest_nitko;;
            3) handle_step_by_step_pentest_legion;;
            4) handle_step_by_step_pentest_owasp_zap;;
            5) handle_step_by_step_pentest_John_the_ripper;;
            6) handle_step_by_step_pentest_SQLmap;;
            7) handle_step_by_step_pentest_metasploit;;
	        8) handle_step_by_step_pentest_wapiti ;;  
            9) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
            
        esac
        
    done
}

handle_step_by_step_guide_IoT(){
    
    local choice
    
    while true; do
        
        display_step_by_step_guide_iot_security_tools
        
        read -p "Choose an option: " choice
        
        case $choice in
            
            1) handle_step_by_step_IoT_aircrack;;
            2) handle_step_by_step_IoT_bettercap;;
            3) handle_step_by_step_IoT_scapy;;
            4) handle_step_by_step_IoT_wifiphisher;;
			5) handle_step_by_step_IoT_reaver;;
            6) break;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
            
        esac
        
    done
}
