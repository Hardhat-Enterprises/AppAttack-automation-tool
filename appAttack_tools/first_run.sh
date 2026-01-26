#!/bin/bash
# Source other scripts using absolute paths

#for install tool functions
source "./install_tools.sh"

#for update tool functions
source "./update_tools.sh"

#for install_ai_insights_dependencies
source "./utilities.sh"

#checking and updating tools
echo "Performing initial setup tasks..."

# Check if npm is installed; if not, install it
if ! command -v npm &> /dev/null; then
    install_npm
fi
# Check if Go is installed; if not, install it
if ! command -v go &> /dev/null; then
    install_go
fi
    #check and install ollama
install_ollama
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

# Check for updates for the installed tools
check_updates


#runs main file
source "./main.sh"

