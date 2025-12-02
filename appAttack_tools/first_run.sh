#!/bin/bash
# Source other scripts using absolute paths
source "./colours.sh"
source "./menus.sh"
source "./install_tools.sh"
source "./update_tools.sh"
source "./run_tools.sh"
source "./utilities.sh"
source "./step_by_step.sh"

# Main function to check and install tools
main() {

    echo "Performing initial setup tasks..."
    
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
    #check and install ollama
    install_ollama

    # Check for updates for the installed tools
    check_updates
}

main