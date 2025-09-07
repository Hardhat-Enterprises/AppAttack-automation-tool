# Function to install Go (programming language) if not already installed
install_go() {
    # Check current Go version
    if command -v go &> /dev/null; then
        version=$(go version | awk '{print $3}')
    else
        version=""
    fi
    release=$(wget -qO- "https://golang.org/VERSION?m=text")
    if [[ $version == "$release" ]]; then
        echo "Go is already up-to-date."
        return
    fi
    git clone https://github.com/udhos/update-golang &> /dev/null
    cd update-golang  || exit 1
    # Run the update script, suppress all output
    {
        sudo ./update-golang.sh &> /dev/null
    } || {
        echo "Failed to update Go."
        return
    }
    # Update PATH
    echo "export PATH=\$PATH:${HOME}/apps/go/bin" >> ~/.bashrc
    source ~/.bashrc
    source /etc/profile.d/golang_path.sh  # Update current shell's PATH

    # Verify installation
    version=$(go version | awk '{print $3}' 2>/dev/null) || true
    if [ -n "$version" ]; then
        echo -e "${GREEN}Dependencies installed successfully!${NC}"
    else
        echo "Failed to get Go version."
    fi
}

install_gobuster() { 
    #Check if Gobuster is already installed 
    echo "[*] Checking for Gobuster..."
    if command -v gobuster >/dev/null 2>&1; then 
        echo "[+] Gobuster is already installed at: $(command -v gobuster)"
    #Install Gobuster
    else 
        echo "[*] INstalling Gobuster..."
        sudo apt update
        sudo apt install -y gobuster
        if command -v gobuster >/dev/null 2>&1; then 
            echo "[+] Gobuster successfully installed"
        else 
            echo "[!] Gobuster installation failed."
        fi
    fi
}

install_sonarqube() {
    # Check if SonarQube Docker container is already installed
    if ! sudo docker images | grep -q sonarqube; then
        echo -e "${CYAN}Pulling SonarQube Docker image...${NC}"
        sudo docker pull sonarqube
        
        echo -e "${CYAN}Downloading and installing SonarScanner...${NC}"
        wget -O sonarscanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.1.0.4477-linux-x64.zip?_gl=1*1vsu6fm*_gcl_au*MTA1MTc2MzQ4NS4xNzI1NTQ4Njcw*_ga*MTIzMjQ3ODQ1OC4xNzI1NTQ4Njcw*_ga_9JZ0GZ5TC6*MTcyNTU0ODY3MC4xLjEuMTcyNTU0OTY2MS42MC4wLjA.
        sudo unzip sonarscanner-cli.zip -d /opt/sonarscanner

        #Add path to ./bashrc
        echo 'export PATH=$PATH:/opt/sonarscanner/sonar-scanner-6.1.0.4477-linux-x64/bin' >> ~/.bashrc
        source ~/.bashrc
        
        echo -e "${GREEN}SonarQube and SonarScanner installed successfully!${NC}"
    else
        echo -e "${GREEN}SonarQube is already installed.${NC}"
    fi
}

install_bandit() {
    if ! command -v bandit &> /dev/null; then
        echo -e "${CYAN}Installing Bandit...${NC}"
        sudo apt update && sudo apt install -y bandit
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Bandit installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Bandit.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Bandit is already installed.${NC}"
    fi
}

# Function to install npm (Node.js package manager) if not already installed
install_npm() {
    echo -e "${CYAN}Installing npm...${NC}"
    sudo apt update && sudo apt install -y npm
    if [ $? -eq 0 ]; then
        sudo chown -R $(whoami) ~/.npm
        echo -e "${GREEN}npm installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install npm.${NC}"
        exit 1
    fi
}

# Function to install Snyk CLI (a vulnerability scanner) if not already installed
install_snyk_cli() {
    if ! command -v npm &> /dev/null; then
        install_npm
    fi
    if ! command -v snyk &> /dev/null; then
        echo -e "${CYAN}Installing snyk cli...${NC}"
        sudo npm install -g snyk
        echo -e "${GREEN}Snyk cli installed successfully!${NC}"
        echo -e "${YELLOW}Authenticating snyk...${NC}"
        echo -e "${RED}Please authenticate by clicking 'Authenticate' in the browser to continue.${NC}"
        snyk auth
    else
        echo -e "${GREEN}snyk cli is already installed.${NC}"
    fi
}

# Function to install Brakeman if not already installed
install_brakeman() {
    if ! command -v brakeman &> /dev/null; then
        echo -e "${MAGENTA}Installing brakeman...${NC}"
        sudo gem install brakeman
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Brakeman installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install brakeman.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}brakeman is already installed.${NC}"
    fi
}

# Function to install osv-scanner (a vulnerability scanner) if not already installed
install_osv_scanner() {
    install_go
    if ! command -v osv-scanner &> /dev/null; then
        echo -e "${CYAN}Installing osv-scanner...${NC}"
        go install github.com/google/osv-scanner/cmd/osv-scanner@v1
        echo -e "${GREEN}osv-scanner installed successfully!${NC}"
        # Add osv-scanner to the user's PATH
        echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc
        source ~/.bashrc
    else
        echo -e "${GREEN}osv-scanner is already installed.${NC}"
    fi
}


# Function to install Nmap if not already installed
install_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${MAGENTA}Installing nmap...${NC}"
        sudo apt update && sudo apt install -y nmap
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}nmap installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install nmap.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}nmap is already installed.${NC}"
    fi
}

# Function to install Aircrack if not already installed
install_aircrack() {
    if ! command -v aircrack-ng &> /dev/null; then
        echo -e "${MAGENTA}Installing aircrack-ng...${NC}"
        sudo apt update && sudo apt install -y aircrack-ng
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}aircrack-ng installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install aircrack-ng.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}aircrack-ng is already installed.${NC}"
    fi
}

# Function to install Reaver if not already installed
install_reaver() {
    if ! command -v reaver &> /dev/null; then
        echo -e "${MAGENTA}Installing reaver...${NC}"
        sudo apt update && sudo apt install -y reaver
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}reaver installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install reaver.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}reaver is already installed.${NC}"
    fi
}

# Function to install Ncrack if not already installed
install_ncrack() {
    if ! command -v ncrack &> /dev/null; then
        echo -e "${MAGENTA}Installing ncrack...${NC}"
        sudo apt update && sudo apt install -y ncrack
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}ncrack installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install ncrack.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}ncrack is already installed.${NC}"
    fi
}

# Function to install nikto
install_nikto() {
    # Check if nikto is not installed
    if ! command -v nikto &> /dev/null; then
        # Display message indicating nikto installation
        echo -e "${CYAN}Installing nikto...${NC}"
        # Update package list and install nikto
        sudo apt update && sudo apt install -y nikto
        # Check if the installation was successful
        if [ $? -eq 0 ]; then
            # Display success message
            echo -e "${GREEN}nikto installed successfully!${NC}"
        else
            #   Display failure message and exit script
            echo -e "${RED}Failed to install nikto.${NC}"
            exit 1
        fi
    else
        # Display message if nikto is already installed
        echo -e "${GREEN}nikto is already installed.${NC}"
    fi
}
# Function to install LEGION
install_legion() {
    # Check if legion is not installed
    if ! command -v legion &> /dev/null; then
        # Display message indicating LEGION installation
        echo -e "${MAGENTA}Installing LEGION...${NC}"
        # Update package list
        sudo apt update
        # Install legion
        sudo apt install -y legion
        # Check if the installation was successful
        if [ $? -eq 0 ]; then
            # Display success message
            echo -e "${GREEN}LEGION installed successfully!${NC}"
        else
            # Display failure message and exit script
            echo -e "${RED}Failed to install LEGION.${NC}"
            exit 1
        fi
    else
        # Display message if LEGION is already installed
        echo -e "${GREEN}LEGION is already installed.${NC}"
    fi
}

# Function to install OWASP ZAP
install_owasp_zap() {
    # Check if OWASP ZAP is not installed by checking its directory
    if [ ! -d "/opt/owasp-zap/" ]; then
        # Display message indicating OWASP ZAP installation
        echo -e "${CYAN}Installing OWASP ZAP...${NC}"
        # Download OWASP ZAP tar file to /tmp directory
        wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -P /tmp
        # Check if the download was successful
        if [ $? -eq 0 ]; then
            # Create directory for OWASP ZAP in /opt
            sudo mkdir -p /opt/owasp-zap
            # Change ownership of the OWASP ZAP directory to the current user
            sudo chown -R $(whoami):$(whoami) /opt/owasp-zap
            # Extract the downloaded tar file to the OWASP ZAP directory
            tar -xf /tmp/ZAP_2.15.0_Linux.tar.gz -C /opt/owasp-zap/
            # Create a symbolic link for the OWASP ZAP executable in /usr/local/bin
            sudo ln -s /opt/owasp-zap/ZAP_2.15.0/zap.sh /usr/local/bin/zap
            # Check if the symbolic link creation was successful
            if [ $? -eq 0 ]; then
                # Display success message
                echo -e "${GREEN}OWASP ZAP installed successfully!${NC}"
            else
                # Display failure message and exit script
                echo -e "${RED}Failed to move OWASP ZAP.${NC}"
                exit 1
            fi
        else
            # Display failure message if download failed and exit script
            echo -e "${RED}Failed to download OWASP ZAP.${NC}"
            exit 1
        fi
    else
        # Display message if OWASP ZAP is already installed
        echo -e "${GREEN}OWASP ZAP is already installed.${NC}"
    fi
}

# Function to install John the Ripper if not already installed
install_john() {
    if ! command -v john &> /dev/null; then
        echo -e "${MAGENTA}Installing John the Ripper...${NC}"
        sudo apt update && sudo apt install -y john
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}John the Ripper installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install John the Ripper.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}John the Ripper is already installed.${NC}"
    fi
}

# Function to install sqlmap if not already installed
install_sqlmap() {
    if ! command -v sqlmap &> /dev/null; then
        echo -e "${MAGENTA}Installing sqlmap...${NC}"
        sudo apt update && sudo apt install -y sqlmap
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}sqlmap installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install sqlmap.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}sqlmap is already installed.${NC}"
    fi
}

# Function to install Metasploit if not already installed
install_metasploit() {
    if ! command -v msfconsole &> /dev/null; then
        echo -e "${MAGENTA}Installing Metasploit...${NC}"
        sudo apt update && sudo apt install -y metasploit-framework
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Metasploit installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Metasploit.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Metasploit is already installed.${NC}"
    fi
}

# Function to install Wapiti (a vulnerability scanner) if not already installed
install_wapiti() {
    if ! command -v wapiti &> /dev/null; then
        echo -e "${CYAN}Installing Wapiti...${NC}"
        sudo apt update && sudo apt install -y wapiti
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Wapiti installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Wapiti.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Wapiti is already installed.${NC}"
    fi
}

# Function to install Tshark (Wireshark CLI), if it is not already installed
install_tshark() {
    if ! command -v tshark &> /dev/null; then
        echo -e "${CYAN}Installing TShark...${NC}"
        sudo apt update && sudo apt install -y tshark
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}TShark installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install TShark.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}TShark is already installed.${NC}"
    fi
}

# Function to install Binwalk (Firmware analyzer), if it is not already installed
install_binwalk() {
    if ! command -v binwalk &> /dev/null; then
        echo -e "${CYAN}Installing Binwalk...${NC}"
        sudo apt update && sudo apt install -y binwalk
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Binwalk installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Binwalk.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Binwalk is already installed.${NC}"
    fi
}

# Function to install Hashcat (Fast password recovery, cracking), if it is not already installed
install_hashcat() {
    if ! command -v hashcat &> /dev/null; then
        echo -e "${CYAN}Installing Hashcat...${NC}"
        sudo apt update && sudo apt install -y hashcat
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Hashcat installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Hashcat.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Hashcat is already installed.${NC}"
    fi
}

# Function to install Miranda (UPnP testing tool), if it is not already installed
install_miranda() {
            # Check if Miranda is not installed by checking its directory
    if [ ! -d "/opt/miranda/" ]; then
        # Display message indicating Miranda installation
        echo -e "${CYAN}Installing Miranda...${NC}"
        # Download Miranda tar file to /tmp directory
        wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/miranda-upnp/miranda-1.3.tar.gz -P /tmp
        # Check if the download was successful
        if [ $? -eq 0 ]; then
            # Create directory for Miranda in /opt
            sudo mkdir -p /opt/miranda
            # Change ownership of the Miranda directory to the current user
            sudo chown -R $(whoami):$(whoami) /opt/miranda
            # Extract the downloaded tar file to the Miranda directory
            tar -xf /tmp/umap-0.8.tar.gz -C /opt/miranda/
            cd /opt/miranda
            make && make install
            cd
            # Create a symbolic link for the Miranda executable in /usr/local/bin
            sudo ln -s /opt/miranda-1.3/miranda.py /usr/local/bin/miranda
            # Check if the symbolic link creation was successful
            if [ $? -eq 0 ]; then
                # Display success message
                echo -e "${GREEN}Miranda installed successfully!${NC}"
            else
                # Display failure message and exit script
                echo -e "${RED}Failed to move Miranda.${NC}"
                exit 1
            fi
        else
            # Display failure message if download failed and exit script
            echo -e "${RED}Failed to download Miranda.${NC}"
            exit 1
        fi
    else
        # Display message if Miranda is already installed
        echo -e "${GREEN}Miranda is already installed.${NC}"
    fi
}


# Function to install Umap (Fast password recovery, cracking), if it is not already installed
install_umap() {
        # Check if Umap is not installed by checking its directory
    if [ ! -d "/opt/umap/" ]; then
        # Display message indicating Umap installation
        echo -e "${CYAN}Installing Umap...${NC}"
        # Download OWASP ZAP tar file to /tmp directory
        wget https://toor.do/umap-0.8.tar.gz -P /tmp
        pip install SOAPpy
        pip install iplib
        # Check if the download was successful
        if [ $? -eq 0 ]; then
            # Create directory for Umap in /opt
            sudo mkdir -p /opt/umap
            # Change ownership of the Umap directory to the current user
            sudo chown -R $(whoami):$(whoami) /opt/umap
            # Extract the downloaded tar file to the Umap directory
            tar -xf /tmp/umap-0.8.tar.gz -C /opt/umap/
            cd /opt/umap
            make && make install
            cd
            # Create a symbolic link for the Umap executable in /usr/local/bin
            sudo ln -s python3 /opt/umap/umap-0.8/umap.py /usr/local/bin/umap
            # Check if the symbolic link creation was successful
            if [ $? -eq 0 ]; then
                # Display success message
                echo -e "${GREEN}Umap installed successfully!${NC}"
            else
                # Display failure message and exit script
                echo -e "${RED}Failed to move Umap.${NC}"
                exit 1
            fi
        else
            # Display failure message if download failed and exit script
            echo -e "${RED}Failed to download Umap.${NC}"
            exit 1
        fi
    else
        # Display message if Umap is already installed
        echo -e "${GREEN}Umap is already installed.${NC}"
    fi
}

# Function to install Bettercap if not already installed

install_bettercap() {
    if ! command -v bettercap &> /dev/null; then
        echo -e "${CYAN}Installing Bettercap...${NC}"
        sudo apt update && sudo apt install -y bettercap
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Bettercap installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Bettercap.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Bettercap is already installed.${NC}"
    fi
}

# Function to install scapy if not already installed
install_scapy() {
    if ! command -v scapy &> /dev/null; then
        echo -e "${CYAN}Installing Scapy...${NC}"
        sudo apt update > /dev/null 2>&1
        sudo apt install -y python3-scapy > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Scapy installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Scapy.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Scapy is already installed.${NC}"
    fi
}

install_wifiphisher() {
    # Colors for output
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RED='\033[0;31m'
    NC='\033[0m'  # No Color

    # Check if Wifiphisher is already installed
    if ! command -v wifiphisher &> /dev/null; then
        echo -e "${CYAN}Installing Wifiphisher...${NC}"

        # Ensure no existing directory conflicts
        if [ -d "/tmp/wifiphisher" ]; then
            echo -e "${YELLOW}Removing existing /tmp/wifiphisher directory...${NC}"
            sudo rm -rf /tmp/wifiphisher
        fi

        # Update and install necessary dependencies
        echo -e "${CYAN}Updating package list and installing dependencies...${NC}"
        sudo apt update -y
        sudo apt install -y git python3-pip libnl-3-dev libnl-genl-3-dev python3-dev

        # Clone the Wifiphisher repository
        echo -e "${CYAN}Cloning Wifiphisher repository...${NC}"
        git clone https://github.com/wifiphisher/wifiphisher.git /tmp/wifiphisher

        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to clone Wifiphisher repository.${NC}"
            exit 1
        fi

        # Fix Python compatibility issue with ConfigParser
        echo -e "${CYAN}Fixing Python compatibility issue in hostapdconfig.py...${NC}"
        sed -i 's/from ConfigParser import SafeConfigParser/from configparser import ConfigParser/' /tmp/wifiphisher/roguehostapd/config/hostapdconfig.py

        # Install Python dependencies and setup
        cd /tmp/wifiphisher || exit
        echo -e "${CYAN}Installing Python dependencies...${NC}"
        sudo pip3 install -r requirements.txt

        echo -e "${CYAN}Running setup.py...${NC}"
        sudo python3 setup.py install

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Wifiphisher installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Wifiphisher.${NC}"
            exit 1
        fi

        # Clean up
        echo -e "${YELLOW}Cleaning up...${NC}"
        cd ~ || exit
        sudo rm -rf /tmp/wifiphisher
    else
        echo -e "${GREEN}Wifiphisher is already installed.${NC}"
    fi
}



# Function to install Reaver if not already installed
install_reaver() {
    if ! command -v reaver &> /dev/null; then
        echo -e "${CYAN}Installing Reaver...${NC}"
        sudo apt update && sudo apt install -y build-essential libpcap-dev aircrack-ng git > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install dependencies for Reaver.${NC}"
            exit 1
        fi

        git clone https://github.com/t6x/reaver-wps-fork-t6x.git /tmp/reaver-wps-fork-t6x > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to clone Reaver repository.${NC}"
            exit 1
        fi

        cd /tmp/reaver-wps-fork-t6x/src || exit
        ./configure > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Configuration failed during Reaver installation.${NC}"
            exit 1
        fi

        make > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to compile Reaver.${NC}"
            exit 1
        fi

        sudo make install > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Reaver installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Reaver.${NC}"
            exit 1
        fi

        # Clean up
        cd ~ || exit
        sudo rm -rf /tmp/reaver-wps-fork-t6x
    else
        echo -e "${GREEN}Reaver is already installed.${NC}"
    fi
}
install_gitleaks() {
    if command -v gitleaks &> /dev/null; then
        echo -e "${GREEN}Gitleaks is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing Gitleaks...${NC}"
    latest_url=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d '"' -f 4)
    if [ -z "$latest_url" ]; then
        echo -e "${RED}Failed to fetch Gitleaks download URL.${NC}"
        return 1
    fi
    wget -O /tmp/gitleaks.tar.gz "$latest_url"
    tar -xzf /tmp/gitleaks.tar.gz -C /tmp
    sudo mv /tmp/gitleaks /usr/local/bin/gitleaks
    sudo chmod +x /usr/local/bin/gitleaks
    rm /tmp/gitleaks.tar.gz
    echo -e "${GREEN}Gitleaks installed successfully!${NC}"
}
case $1 in 
    gobuster)   install_gobuster ;;
    go)   install_go ;;
    sonarqube)   install_sonarqube ;;
    bandit)   install_bandit ;;
    npm)   install_npm ;;
    snykcli)   install_snyk_cli ;;
    brakeman)   install_brakeman ;;
    osvscanner)   install_osv_scanner ;;
    nmap)   install_nmap ;;
    aircrack)   install_aircrack ;;
    reaver)   install_reaver ;;
    ncrack)   install_ncrack ;;
    nikto)   install_nikto ;;
    legion)   install_legion ;;
    owaspzap)   install_owasp_zap ;;
    john)   install_john ;;
    sqlmap)   install_sqlmap ;;
    metasploit)   install_metasploit ;;
    wapiti)   install_wapiti ;;
    tshark)   install_tshark ;;
    binwalk)   install_binwalk ;;
    hashcat)   install_hashcat ;;
    miranda)   install_miranda ;;
    umap)   install_umap ;;
    bettercap)   install_bettercap ;;
    scrapy)   install_scrapy ;;
    wifiphisher)   install_wifiphisher ;;
    *)
    ;;
esac
