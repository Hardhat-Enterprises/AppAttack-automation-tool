#!/bin/bash
# Function to check for updates
check_updates() {
    
    # Prompt user to check for updates

    while true; do
        read -p "Do you want to check for updates? (y/n): " check_updates
        case "$check_updates" in
            [Yy])         
                log_message "Checking for updates..."
                # Update the APT package lists if they havent been updated in the last day
                # if [ $(sudo find /var/lib/apt/lists -type f -mtime +1 | wc -l) -gt 0 ]; then
                #     sudo apt update -qq
                # fi

                local tool_directory=$(pwd)
                
                update_nikto
                update_brakeman
                update_sqlmap
                update_metasploit
                update_tool_dpkg bandit
                update_tool_dpkg zaproxy
                update_tool_dpkg wapiti
                update_tool_dpkg miranda
                update_tool_dpkg umap
                update_tool_dpkg nmap
                update_tool_dpkg aircrack-ng
                update_tool_dpkg reaver
                update_tool_dpkg ncrack
                update_tool_dpkg john

                cd "$tool_directory"

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

}


update_tool_dpkg() {
    local name="$1"
    if ! command -v "$name" &> /dev/null; then
        sudo apt install -y "$name" > /dev/null 2>&1
        log_message "${name} installed"
    else
        current_version=$(dpkg-query -W -f='${Version}' "${name}" 2>/dev/null)
        latest_version=$(apt-cache policy "$name" | grep 'Candidate:' | awk '{print $2}')

        if [ "$current_version" != "$latest_version" ]; then
            echo -e "${MAGENTA}Updating ${name}...${NC}"
            sudo apt install -y "$name" > /dev/null 2>&1
            log_message "${name} updated to version $latest_version"
        else
            log_message "${name} is up-to-date (version $current_version)"
        fi
    fi
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
            return 1
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
            cd /tmp/wifiphisher || return 1
            sudo python3 setup.py install > /dev/null 2>&1
            cd ~ || return 1
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
            cd reaver-wps-fork-t6x/src || return 1
            ./configure > /dev/null 2>&1
            make > /dev/null 2>&1
            sudo make install > /dev/null 2>&1
            cd ~ || return 1
            sudo rm -rf /tmp/reaver-wps-fork-t6x
            log_message "Reaver updated to version $latest_version"
        else
            log_message "Reaver is up-to-date (version $current_version)"
        fi
    fi
}
