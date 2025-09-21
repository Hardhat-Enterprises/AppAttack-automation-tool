#!/bin/bash

# Dynamically determine the directory of the script
if [[ -L "$0" ]]; then
    # If executed via a symlink, resolve to the installation directory
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
else
    # If running directly, use the source directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Source other scripts using absolute paths
source "$SCRIPT_DIR/colours.sh"
source "$SCRIPT_DIR/menus.sh"
source "$SCRIPT_DIR/install_tools.sh"
source "$SCRIPT_DIR/update_tools.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"
source "$SCRIPT_DIR/step_by_step.sh"
source "$SCRIPT_DIR/automate.sh"

# Discover and load plugins from plugins directory
PLUGIN_DIR="$SCRIPT_DIR/plugins"
if [[ -d "$PLUGIN_DIR" ]]; then
    for plugin in "$PLUGIN_DIR"/*.sh; do
        source "$plugin"
        if declare -f run_plugin > /dev/null; then
            echo "Loaded plugin: $TOOL_NAME"
            PLUGIN_LIST+=("$TOOL_NAME")
        fi
    done
else
    echo "Plugin directory not found: $PLUGIN_DIR"
fi





# Main function to check and install tools
main() {
    
    # Initialize log file by clearing its contents
    echo "" > "$LOG_FILE"
    
    # Check if npm is installed; if not, install it
    if ! command -v npm &> /dev/null; then
        install_npm
    fi
    # Check if Go is installed; if not, install it
    if ! command -v go &> /dev/null; then
        install_go
    fi

    # Check and install osv-scanner
    install_osv_scanner
    # Check and install snyk cli
    install_snyk_cli
    # Check and install brakeman
    install_brakeman
    # Check and install bandit
    install_bandit
    # Check and install nmap
    install_nmap
    # Check and install ncrack
    install_ncrack
    # Check and install nikto
    install_nikto
    # Check and install legion
    install_legion
    # Check and install OWASP ZAP
    install_owasp_zap
    # Check and install generate_ai_insights dependencies
    install_generate_ai_insights_dependencies
    # Check and install John
    install_john
    # Check and install sqlmap
    install_sqlmap
    # Check and install metasploit
    install_metasploit
    # install sonarqube
    install_sonarqube
    # Check and install wapiti
    install_wapiti
    # Check and install tshark
    install_tshark
    # Check and install binwalk
    install_binwalk
    # Check and install hashcat
    install_hashcat
    # Check and install aircrack
    install_aircrack
    # Check and install miranda
    install_miranda
    # Check and install umap
    install_umap
    # Check and install bettercap
	install_bettercap
	# Check and install scapy
	install_scapy
	# Check and install wifiphisher
    install_wifiphisher
	# Check and install reaver
	install_reaver
   #check and install gobuster
   install_gobuster
   #check and install Trivy
   install_trivy
   install_mobsf
   install_android_sdk
   create_avd
   install_mitmproxy
    
    # Check for updates for the installed tools
    check_updates
    
    # Ask if the user wants to output to a file
    # Ask if the user wants to output results to a file
    read -p "Do you want to output results to a file? (y/n): " output_to_file
    if [[ "$output_to_file" == "y" ]]; then
        read -p "Enter the output file path: " OUTPUT_DIR
        if [[ ! -d "$OUTPUT_DIR" ]]; then
            mkdir -p "$OUTPUT_DIR"
        fi
    fi
    
    USER_ROLE=${USER_ROLE:-"guest"}
    while true; do
        display_main_menu
        read -p "Choose an option: " main_choice
        case $main_choice in
            1)
                if [[ "$USER_ROLE" != "admin" ]]; then
                    echo "Access denied."
                    log_message "Unauthorized access attempt"
                    continue
                fi
                echo "Available plugins: ${PLUGIN_LIST[*]}"
                read -p "Enter plugin name to run: " plugin_name
                for plugin in "$PLUGIN_DIR"/*.sh; do
                    source "$plugin"
                    if [[ "$TOOL_NAME" == "$plugin_name" ]]; then
                        run_plugin
                        break
                    fi
                done
                ;;
            2) handle_penetration_testing_tools "$OUTPUT_DIR" ;;
            3) handle_secure_code_review_tools "$OUTPUT_DIR" ;;
            4) handle_iot_security_tools "$OUTPUT_DIR" ;;
            5) handle_step_by_step_guide ;;
            6) handle_automated_processes_menu ;;
            7) handle_container_security_tools "$OUTPUT_DIR" ;;
            8) handle_mobile_security_tools "$OUTPUT_DIR" ;;
            9) echo -e "${YELLOW}Exiting...${NC}"
                log_message "Script ended"
            exit 0 ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}"
            log_message "Invalid user input" ;;
        esac
    done
}

export LOG_FILE="$HOME/appattack_toolkit.log"

# Execute main function to start the script
main
