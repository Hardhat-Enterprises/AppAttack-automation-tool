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

# install_function reaver
# install_function gobuster
# install_function bandit


install_ollama
install_osv_scanner
install_snyk_cli
install_brakeman
# install_owasp_zap
install_generate_ai_insights_dependencies
install_metasploit
install_sonarqube
install_function john
install_function sqlmap
install_function bandit
install_function nmap
install_function nikto
install_function legion
install_function wapiti
install_function zaproxy
install_hydra
install_feroxbuster
install_theharvester
install_enum4linux
install_whatweb
install_amass
