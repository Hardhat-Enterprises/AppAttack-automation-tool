#!/bin/bash
# Function to check for updates for the installed security tools
check_updates() {
    log_message "Checking for updates..."
    
    # Update APT package lists if they haven't been updated in the last day
    if [ $(sudo find /var/lib/apt/lists -type f -mtime +1 | wc -l) -gt 0 ]; then
        sudo apt update -qq
    fi
    
    # Update individual tools
    update_brakeman
    update_snyk
    update_owasp_zap
    update_nikto
    update_nmap
    update_aircrack
    update_reaver
    update_ncrack
    update_john
    update_sqlmap
    update_metasploit
    update_wapiti
    update_miranda
    update_umap
}

# Function to check for updates
check_updates() {
    
    # Prompt user to check for updates

    while true; do
        read -p "Do you want to check for updates? (y/n): " check_updates
        case "$check_updates" in
            [Yy])         
                log_message "Checking for updates..."
                update_brakeman
                update_bandit
                update_owasp_zap
                update_nikto
                update_nmap
                update_aircrack
                update_reaver
                update_ncrack
                update_john
                update_sqlmap
                update_metasploit
                update_wapiti
                update_miranda
                update_umap
            # Display success message
                echo -e "${GREEN}Updates checked successfully.${NC}"
                break ;;
            
            [Nn]) 
                echo -e "${YELLOW}Skipping updates check.${NC}"
                break  ;;
            *)
                echo "Please answer 'y' or 'n'."
                ;;
        esac
    done
    # If the user agrees to check for updates
    # if [[ "$check_updates" == "y" ]]; then
    #     # Log message indicating update check
    #     log_message "Checking for updates..."
    #     update_brakeman
    #     update_bandit
    #     update_owasp_zap
    #     update_nikto
    #     update_nmap
    #     update_aircrack
    #     update_reaver
    #     update_ncrack
    #     update_john
    #     update_sqlmap
    #     update_metasploit
	#     update_wapiti
    #     update_miranda
    #     update_umap
    #     # Display success message
    #     echo -e "${GREEN}Updates checked successfully.${NC}"
    # else
    #     # Display message indicating skipping of updates check
    #     echo -e "${YELLOW}Skipping updates check.${NC}"
    # fi
}



# Function to update Brakeman (a security scanner for Ruby on Rails applications)
update_brakeman() {
    sudo gem update brakeman > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log_message "Gems already up-to-date: brakeman"
    else
        log_message "Failed to update brakeman"
    fi
}

# Function to update OWASP ZAP (a web application security scanner)
update_owasp_zap() {
    if ! command -v zaproxy &> /dev/null; then
        sudo apt install -y zaproxy > /dev/null 2>&1
        log_message "OWASP ZAP installed"
    else
        current_version=$(dpkg -s zaproxy | grep '^Version:' | awk '{print $2}')
        latest_version=$(apt-cache policy zaproxy | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y zaproxy > /dev/null 2>&1
            log_message "OWASP ZAP updated to version $latest_version"
        else
            log_message "OWASP ZAP is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Nikto (a web server scanner)
update_nikto() {
    if ! command -v nikto &> /dev/null; then
        sudo apt install -y nikto > /dev/null 2>&1
        log_message "Nikto installed"
    else
        cd /tmp
        if [ -d "nikto" ]; then
            sudo rm -rf nikto
        fi
        git clone https://github.com/sullo/nikto.git > /dev/null 2>&1
        cd nikto/program
        sudo cp nikto.pl /usr/local/bin/nikto > /dev/null 2>&1
        sudo chmod +x /usr/local/bin/nikto
        log_message "Nikto updated"
    fi
}

# Function to update Nmap (a network exploration and security auditing tool)
update_nmap() {
    if ! command -v nmap &> /dev/null; then
        sudo apt install -y nmap > /dev/null 2>&1
        log_message "Nmap installed"
    else
        # Check the installed version against the latest available version
        current_version=$(nmap --version | head -n 1 | awk '{print $3}')
        latest_version=$(apt-cache policy nmap | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y nmap > /dev/null 2>&1
            log_message "Nmap updated to version $latest_version"
        else
            log_message "Nmap is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update aircrack-ng (a network exploration and security auditing tool)
update_aircrack() {
    if ! command -v aircrack-ng &> /dev/null; then
        sudo apt install -y aircrack-ng > /dev/null 2>&1
        log_message "Aircrack-ng installed"
    else
        # Check the installed version against the latest available version
        current_version=$(aircrack-ng --version | head -n 1 | awk '{print $3}')
        latest_version=$(apt-cache policy aircrack-ng | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y aircrack-ng > /dev/null 2>&1
            log_message "Aircrack-ng updated to version $latest_version"
        else
            log_message "Aircrack-ng is up-to-date (version $current_version)"
        fi
    fi
}


# Function to update Reaver (a network exploration and security auditing tool)
update_reaver() {
    if ! command -v reaver &> /dev/null; then
        sudo apt install -y reaver > /dev/null 2>&1
        log_message "Reaver installed"
    else
        # Check the installed version against the latest available version
        current_version=$(reaver --version | head -n 1 | awk '{print $3}')
        latest_version=$(apt-cache policy reaver | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y reaver > /dev/null 2>&1
            log_message "Reaver updated to version $latest_version"
        else
            log_message "Reaver is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Ncrack (a network exploration and security auditing tool)
update_ncrack() {
    if ! command -v ncrack &> /dev/null; then
        sudo apt install -y ncrack > /dev/null 2>&1
        log_message "Ncrack installed"
    else
        # Check the installed version against the latest available version
        current_version=$(ncrack --version | head -n 1 | awk '{print $3}')
        latest_version=$(apt-cache policy ncrack | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y ncrack > /dev/null 2>&1
            log_message "Ncrack updated to version $latest_version"
        else
            log_message "Ncrack is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update John the Ripper (a password cracking tool)
update_john() {
    if ! command -v john &> /dev/null; then
        echo -e "${MAGENTA}Installing John the Ripper...${NC}"
        sudo apt install -y john > /dev/null 2>&1
        log_message "John the Ripper installed"
    else
        # Get the current installed version using the package manager
        current_version=$(dpkg-query -W -f='${Version}' john 2>/dev/null)
        # Get the latest available version
        latest_version=$(apt-cache policy john | grep 'Candidate:' | awk '{print $2}')
        
        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating John the Ripper...${NC}"
            sudo apt install -y john > /dev/null 2>&1
            log_message "John the Ripper updated to version $latest_version"
        else
            log_message "John the Ripper is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update bandit
update_bandit() {
    if ! command -v bandit &> /dev/null; then
        sudo apt install -y bandit > /dev/null 2>&1
        log_message "Bandit installed"
    else
        current_version=$(dpkg-query -W -f='${Version}' bandit 2>/dev/null)
        latest_version=$(apt-cache policy bandit | grep 'Candidate:' | awk '{print $2}')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Bandit...${NC}"
            sudo apt install -y bandit > /dev/null 2>&1
            log_message "Bandit updated to version $latest_version"
        else
            log_message "Bandit is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update sqlmap
update_sqlmap() {
    if ! command -v sqlmap &> /dev/null; then
        echo -e "${MAGENTA}sqlmap is not installed. Installing sqlmap...${NC}"
        sudo apt update && sudo apt install -y sqlmap
        log_message "sqlmap installed"
    else
        # Check if sqlmap needs an update
        output=$(sqlmap 2>&1)
        if echo "$output" | grep -q "you haven't updated sqlmap"; then
            echo -e "${MAGENTA}sqlmap update available. Updating...${NC}"
            sudo sqlmap --update
            log_message "sqlmap updated"
            elif echo "$output" | grep -q "your sqlmap version is outdated"; then
            echo -e "${MAGENTA}sqlmap version is outdated. Updating...${NC}"
            sudo sqlmap --update
            log_message "sqlmap updated"
        else
            log_message "sqlmap is up-to-date"
        fi
    fi
}

# Function to update Metasploit Framework
update_metasploit() {
    if ! command -v msfconsole &> /dev/null; then
        sudo apt update
        sudo apt install -y metasploit-framework > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log_message "Metasploit Framework installed"
        else
            log_message "Failed to install Metasploit Framework"
            exit 1
        fi
    else
        # Check the installed version against the latest available version
        current_version=$(msfconsole --version | head -n 1 | awk '{print $3}')
        latest_version=$(apt-cache policy metasploit-framework | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt update
            sudo apt install -y metasploit-framework > /dev/null 2>&1
            log_message "Metasploit Framework updated to version $latest_version"
        else
            log_message "Metasploit Framework is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Wapiti
update_wapiti() {
    if ! command -v wapiti &> /dev/null; then
        sudo apt install -y wapiti > /dev/null 2>&1
        log_message "Wapiti installed"
    else
        current_version=$(dpkg-query -W -f='${Version}' wapiti 2>/dev/null)
        latest_version=$(apt-cache policy wapiti | grep 'Candidate:' | awk '{print $2}')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Wapiti...${NC}"
            sudo apt install -y wapiti > /dev/null 2>&1
            log_message "Wapiti updated to version $latest_version"
        else
            log_message "Wapiti is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Tshark (Wireshark CLI)
update_tshark() {
    if ! command -v tshark &> /dev/null; then
        sudo apt install -y tshark > /dev/null 2>&1
        log_message "Tshark installed"
    else 
        current_version=$(dpkg-query -W -f='${Version}' tshark 2>/dev/null)
        latest_version=$(apt-cache policy tshark | grep 'Candidate:' | awk '{print $2}')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Tshark...${NC}"
            sudo apt install -y tshark > /dev/null 2>&1
            log_message "Tshark updated to version $latest_version"
        else
            log_message "Tshark is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Binwalk (Firmware analyzer)
update_binwalk() {
    if ! command -v binwalk &> /dev/null; then
        sudo apt install -y binwalk > /dev/null 2>&1
        log_message "Binwalk installed"
    else 
        current_version=$(dpkg-query -W -f='${Version}' binwalk 2>/dev/null)
        latest_version=$(apt-cache policy binwalk | grep 'Candidate:' | awk '{print $2}')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Binwalk...${NC}"
            sudo apt install -y binwalk > /dev/null 2>&1
            log_message "Binwalk updated to version $latest_version"
        else
            log_message "Binwalk is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Hashcat (Fast password recovery, cracking)
update_hashcat() {
    if ! command -v hashcat &> /dev/null; then
        sudo apt install -y hashcat > /dev/null 2>&1
        log_message "Hashcat installed"
    else 
        current_version=$(dpkg-query -W -f='${Version}' hashcat 2>/dev/null)
        latest_version=$(apt-cache policy hashcat | grep 'Candidate:' | awk '{print $2}')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Hashcat...${NC}"
            sudo apt install -y hashcat > /dev/null 2>&1
            log_message "Hashcat updated to version $latest_version"
        else
            log_message "Hashcat is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Miranda
update_miranda() {
    if ! command -v miranda &> /dev/null; then
        sudo apt install -y miranda > /dev/null 2>&1
        log_message "Miranda installed"
    else
        current_version=$(dpkg -s miranda | grep '^Version:' | awk '{print $2}')
        latest_version=$(apt-cache policy miranda | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y miranda > /dev/null 2>&1
            log_message "Miranda updated to version $latest_version"
        else
            log_message "Miranda is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update umap
update_umap() {
    if ! command -v umap &> /dev/null; then
        sudo apt install -y umap > /dev/null 2>&1
        log_message "Umap installed"
    else
        current_version=$(dpkg -s umap | grep '^Version:' | awk '{print $2}')
        latest_version=$(apt-cache policy umap | grep 'Candidate:' | awk '{print $2}')
        if [ "$current_version" != "$latest_version" ]; then
            sudo apt install -y umap > /dev/null 2>&1
            log_message "Umap updated to version $latest_version"
        else
            log_message "Umap is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update bettercap
update_bettercap() {
    if ! command -v bettercap &> /dev/null; then
        echo -e "${MAGENTA}Installing Bettercap...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y bettercap > /dev/null 2>&1
        log_message "Bettercap installed"
    else
        current_version=$(bettercap --version | awk '{print $2}')
        latest_version=$(curl -s https://github.com/bettercap/bettercap/releases/latest | grep -oP 'v\K[0-9.]+')
        
        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Bettercap...${NC}"
            sudo apt remove -y bettercap > /dev/null 2>&1
            curl -L https://github.com/bettercap/bettercap/releases/download/v$latest_version/bettercap_linux_amd64 -o /tmp/bettercap > /dev/null 2>&1
            sudo mv /tmp/bettercap /usr/local/bin/bettercap
            sudo chmod +x /usr/local/bin/bettercap
            log_message "Bettercap updated to version $latest_version"
        else
            log_message "Bettercap is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update scapy
update_scapy() {
    if ! command -v scapy &> /dev/null; then
        echo -e "${MAGENTA}Installing Scapy...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y python3-scapy > /dev/null 2>&1
        log_message "Scapy installed"
    else
        current_version=$(scapy --version | awk '{print $2}')
        latest_version=$(pip search scapy | grep -oP '^scapy \(\K[0-9.]+' | head -n 1)

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Scapy...${NC}"
            sudo pip install --upgrade scapy > /dev/null 2>&1
            log_message "Scapy updated to version $latest_version"
        else
            log_message "Scapy is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Wifiphisher
update_wifiphisher() {
    if ! command -v wifiphisher &> /dev/null; then
        echo -e "${MAGENTA}Installing Wifiphisher...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y wifiphisher > /dev/null 2>&1
        log_message "Wifiphisher installed"
    else
        current_version=$(wifiphisher --version 2>&1 | awk '{print $NF}')
        latest_version=$(curl -s https://github.com/wifiphisher/wifiphisher/releases/latest | grep -oP 'v\K[0-9.]+' | head -n 1)

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Wifiphisher...${NC}"
            sudo apt remove -y wifiphisher > /dev/null 2>&1
            git clone https://github.com/wifiphisher/wifiphisher.git /tmp/wifiphisher > /dev/null 2>&1
            cd /tmp/wifiphisher || exit
            sudo python3 setup.py install > /dev/null 2>&1
            cd ~ || exit
            sudo rm -rf /tmp/wifiphisher
            log_message "Wifiphisher updated to version $latest_version"
        else
            log_message "Wifiphisher is up-to-date (version $current_version)"
        fi
    fi
}

# Function to update Reaver
update_reaver() {
    if ! command -v reaver &> /dev/null; then
        echo -e "${MAGENTA}Installing Reaver...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y reaver > /dev/null 2>&1
        log_message "Reaver installed"
    else
        current_version=$(reaver -h 2>&1 | grep -oP '(?<=Reaver v)[0-9.]+')
        latest_version=$(curl -s https://github.com/t6x/reaver-wps-fork-t6x/releases/latest | grep -oP 'v\K[0-9.]+')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating Reaver...${NC}"
            cd /tmp
            if [ -d "reaver-wps-fork-t6x" ]; then
                sudo rm -rf reaver-wps-fork-t6x
            fi
            git clone https://github.com/t6x/reaver-wps-fork-t6x.git > /dev/null 2>&1
            cd reaver-wps-fork-t6x/src || exit
            ./configure > /dev/null 2>&1
            make > /dev/null 2>&1
            sudo make install > /dev/null 2>&1
            cd ~ || exit
            sudo rm -rf /tmp/reaver-wps-fork-t6x
            log_message "Reaver updated to version $latest_version"
        else
            log_message "Reaver is up-to-date (version $current_version)"
        fi
    fi
}