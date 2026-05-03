install_function() {
    local name="$1"
    if ! command -v "$name" &> /dev/null; then
    echo -e "${MAGENTA}Installing ${name}...${NC}"
    sudo apt update && sudo apt install -y "$name"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}${name} installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install ${name}.${NC}"
    fi
else
    echo -e "${GREEN}${name} is already installed.${NC}"
fi
}


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
    cd update-golang  || return 1
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

#Function to install Trivy for Container image scanning  
install_trivy() {
    echo "[*] Checking for Trivy..."
    
    if command -v trivy &> /dev/null; then
        echo "[+] Trivy is already installed"
        trivy version
        return
    fi

    echo "[*] Installing Trivy via official script..."

    # Ensure curl exists
    sudo apt update
    sudo apt install -y curl

    # Run install script and capture output
    sudo sh -c "$(curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh)"
    if [ -f ./bin/trivy ]; then
        sudo mv ./bin/trivy /usr/local/bin/trivy
        sudo chmod +x /usr/local/bin/trivy
        echo "[+] Trivy moved to /usr/local/bin"
    fi

    # Ensure PATH includes /usr/local/bin
    export PATH=$PATH:/usr/local/bin
    if ! grep -q "/usr/local/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    fi

    # Verify installation
    if command -v trivy &> /dev/null; then
        echo "[+] Trivy successfully installed"
        trivy version
    else
        echo "[!] Trivy installation failed."
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


# Function to install npm (Node.js package manager) if not already installed
install_npm() {
    echo -e "${CYAN}Installing npm...${NC}"
    sudo apt update && sudo apt install -y npm
    if [ $? -eq 0 ]; then
        sudo chown -R $(whoami) ~/.npm
        echo -e "${GREEN}npm installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install npm.${NC}"
        return 1
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
        echo -e "${YELLOW}Note: Snyk requires authentication before use.${NC}"
        echo -e "${YELLOW}To authenticate later, run: snyk auth${NC}"
        echo -e "${YELLOW}Or set a token directly with: SNYK_TOKEN=<your_token> snyk auth${NC}"
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
            return 1
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






# Function to install Metasploit if not already installed
install_metasploit() {
    if ! command -v msfconsole &> /dev/null; then
        echo -e "${MAGENTA}Installing Metasploit...${NC}"
        sudo apt update && sudo apt install -y metasploit-framework
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Metasploit installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Metasploit.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}Metasploit is already installed.${NC}"
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
                return 1
            fi
        else
            # Display failure message if download failed and exit script
            echo -e "${RED}Failed to download Miranda.${NC}"
            return 1
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
                return 1
            fi
        else
            # Display failure message if download failed and exit script
            echo -e "${RED}Failed to download Umap.${NC}"
            return 1
        fi
    else
        # Display message if Umap is already installed
        echo -e "${GREEN}Umap is already installed.${NC}"
    fi
}



# Function to install Subfinder
install_subfinder() {
    # Check if Subfinder is already installed
    if command -v subfinder &> /dev/null; then
        echo -e "${GREEN}Subfinder is already installed.${NC}"
        return
    fi

    echo -e "${CYAN}Installing Subfinder...${NC}"

    # Install via apt (preferred for Debian/Kali/Ubuntu)
    sudo apt update && sudo apt install -y subfinder
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Subfinder installed successfully via apt!${NC}"
    else
        # Fallback: Install via Go if apt fails
        echo -e "${YELLOW}apt install failed. Using Go fallback...${NC}"

        # Install Go if not available
        if ! command -v go &> /dev/null; then
            echo -e "${CYAN}Installing Go...${NC}"
            sudo apt install -y golang
        fi

        # Install Subfinder using Go
        GO111MODULE=on go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        if [ $? -eq 0 ]; then
            # Update PATH to include Go binaries
            echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc
            source ~/.bashrc
            echo -e "${GREEN}Subfinder installed successfully via Go!${NC}"
        else
            echo -e "${RED}Failed to install Subfinder.${NC}"
            return 1
        fi
    fi

    # Verify installation
    if command -v subfinder &> /dev/null; then
        echo -e "${GREEN}Subfinder ready: $(subfinder -version)${NC}"
    else
        echo -e "${RED}Subfinder installation failed.${NC}"
        return 1
    fi
}

install_httpx() {
    # Check if httpx is already installed
    if command -v httpx &> /dev/null; then
        echo -e "${GREEN}httpx is already installed.${NC}"
        return
    fi

    echo -e "${CYAN}Installing httpx...${NC}"

    # Install via apt (preferred for Debian/Kali/Ubuntu)
    sudo apt update && sudo apt install -y httpx
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}httpx installed successfully via apt!${NC}"
    else
        # Fallback: Install via Go if apt fails
        echo -e "${YELLOW}apt install failed. Using Go fallback...${NC}"

        # Install Go if not available
        if ! command -v go &> /dev/null; then
            echo -e "${CYAN}Installing Go...${NC}"
            sudo apt install -y golang
        fi

        # Install httpx using Go
        GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        if [ $? -eq 0 ]; then
            # Update PATH to include Go binaries
            echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc
            source ~/.bashrc
            echo -e "${GREEN}httpx installed successfully via Go!${NC}"
        else
            echo -e "${RED}Failed to install httpx.${NC}"
            return 1
        fi
    fi

    # Verify installation
    if command -v httpx &> /dev/null; then
        echo -e "${GREEN}httpx ready: $(httpx -version)${NC}"
    else
        echo -e "${RED}httpx installation failed.${NC}"
        return 1
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
            return 1
        fi

        # Fix Python compatibility issue with ConfigParser
        echo -e "${CYAN}Fixing Python compatibility issue in hostapdconfig.py...${NC}"
        sed -i 's/from ConfigParser import SafeConfigParser/from configparser import ConfigParser/' /tmp/wifiphisher/roguehostapd/config/hostapdconfig.py

        # Install Python dependencies and setup
        cd /tmp/wifiphisher || return 1
        echo -e "${CYAN}Installing Python dependencies...${NC}"
        sudo pip3 install -r requirements.txt

        echo -e "${CYAN}Running setup.py...${NC}"
        sudo python3 setup.py install

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Wifiphisher installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Wifiphisher.${NC}"
            return 1
        fi

        # Clean up
        echo -e "${YELLOW}Cleaning up...${NC}"
        cd ~ || return 1
        sudo rm -rf /tmp/wifiphisher
    else
        echo -e "${GREEN}Wifiphisher is already installed.${NC}"
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
# Function to install Dredd (API testing tool)
install_dredd() {
    if ! command -v dredd &> /dev/null; then
        echo -e "${CYAN}Installing Dredd (API Security Testing Tool)...${NC}"

        # Ensure npm is installed first
        if ! command -v npm &> /dev/null; then
            echo -e "${YELLOW}npm not found. Installing npm first...${NC}"
            sudo apt update && sudo apt install -y npm
        fi

        # Install Dredd globally
        sudo npm install -g dredd

        # Verify installation
        if command -v dredd &> /dev/null; then
            echo -e "${GREEN}Dredd installed successfully!${NC}"
        else
            echo -e "${RED}Failed to install Dredd.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}Dredd is already installed.${NC}"
    fi

}

install_scoutsuite() {
    if command -v scoutsuite &> /dev/null; then
        echo "ScoutSuite is already installed."
        return
    fi
    echo "Installing ScoutSuite..."
    pip3 install scoutsuite
    echo "ScoutSuite installed successfully."
}

install_mobsf() {
    if [ -d "/opt/Mobile-Security-Framework-MobSF" ]; then
        echo -e "${GREEN}MobSF is already installed.${NC}"
        return
    fi

    echo -e "${CYAN}Installing MobSF...${NC}"
    sudo apt update
    sudo apt install -y git python3-venv python3-pip
    git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git /opt/Mobile-Security-Framework-MobSF
    cd /opt/Mobile-Security-Framework-MobSF
    ./setup.sh
    echo -e "${GREEN}MobSF installed successfully!${NC}"
}

install_android_sdk() {
    if [ -d "/opt/android-sdk" ]; then
        echo -e "${GREEN}Android SDK is already installed.${NC}"
        return
    fi

    echo -e "${CYAN}Installing Android SDK...${NC}"
    sudo apt update
    sudo apt install -y wget unzip
    mkdir -p /opt/android-sdk
    cd /opt/android-sdk
    wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
    unzip commandlinetools-linux-6858069_latest.zip
    rm commandlinetools-linux-6858069_latest.zip
    yes | tools/bin/sdkmanager --licenses
    tools/bin/sdkmanager "platform-tools" "platforms;android-29" "system-images;android-29;google_apis;x86_64"
    echo 'export ANDROID_HOME=/opt/android-sdk' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
    source ~/.bashrc
    echo -e "${GREEN}Android SDK installed successfully!${NC}"
}

create_avd() {
    echo -e "${CYAN}Creating Android Virtual Device...${NC}"
    echo "no" | /opt/android-sdk/tools/bin/avdmanager create avd -n test_avd -k "system-images;android-29;google_apis;x86_64"
    echo -e "${GREEN}Android Virtual Device created successfully!${NC}"
}

install_mitmproxy() {
    if command -v mitmproxy &> /dev/null; then
        echo -e "${GREEN}mitmproxy is already installed.${NC}"
        return
    fi

    echo -e "${CYAN}Installing mitmproxy...${NC}"
    sudo apt update
    sudo apt install -y python3-pip
    pip3 install mitmproxy
    echo -e "${GREEN}mitmproxy installed successfully!${NC}"
}

install_ollama(){
    #check if ollama is installed
    if command -v ollama &> /dev/null; then
        echo "ollama is already installed at: $(command -v ollama)"
    else
    #if ollama isnt installed, we will install it

    #first we ensure curl exists
        if ! command -v curl &> /dev/null; then
            sudo apt update
            sudo apt install -y curl
        fi
    #then we try to install ollama using curl with the official download link
        curl -fsSL https://ollama.com/install.sh | sudo sh
    fi
}

# Function to install Hydra (network login cracker)
install_hydra() {
    if command -v hydra &> /dev/null; then
        echo -e "${GREEN}Hydra is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing Hydra...${NC}"
    sudo apt update && sudo apt install -y hydra
    if command -v hydra &> /dev/null; then
        echo -e "${GREEN}Hydra installed successfully!${NC}"
        hydra -h 2>&1 | head -3
    else
        echo -e "${RED}Failed to install Hydra.${NC}"
    fi
}

# Function to install Feroxbuster (fast content discovery tool)
install_feroxbuster() {
    if command -v feroxbuster &> /dev/null; then
        echo -e "${GREEN}Feroxbuster is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing Feroxbuster...${NC}"
    curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | sudo bash -s /usr/local/bin
    if command -v feroxbuster &> /dev/null; then
        echo -e "${GREEN}Feroxbuster installed successfully!${NC}"
        feroxbuster --version
    else
        # Fallback: try cargo install
        echo -e "${YELLOW}Trying cargo install as fallback...${NC}"
        if ! command -v cargo &> /dev/null; then
            sudo apt install -y cargo
        fi
        cargo install feroxbuster
        if [ -f "$HOME/.cargo/bin/feroxbuster" ]; then
            sudo ln -sf "$HOME/.cargo/bin/feroxbuster" /usr/local/bin/feroxbuster
            echo -e "${GREEN}Feroxbuster installed via cargo!${NC}"
        else
            echo -e "${RED}Failed to install Feroxbuster.${NC}"
        fi
    fi
}

# Function to install theHarvester (OSINT email/domain harvesting tool)
install_theharvester() {
    if command -v theHarvester &> /dev/null || [ -f /usr/bin/theHarvester ]; then
        echo -e "${GREEN}theHarvester is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing theHarvester...${NC}"
    sudo apt update && sudo apt install -y theharvester
    if command -v theHarvester &> /dev/null; then
        echo -e "${GREEN}theHarvester installed successfully!${NC}"
    else
        # Fallback: pip install
        echo -e "${YELLOW}Trying pip install as fallback...${NC}"
        pip3 install theHarvester --break-system-packages
        if command -v theHarvester &> /dev/null; then
            echo -e "${GREEN}theHarvester installed via pip!${NC}"
        else
            echo -e "${RED}Failed to install theHarvester.${NC}"
        fi
    fi
}

# Function to install enum4linux (SMB/Samba enumeration tool)
install_enum4linux() {
    if command -v enum4linux &> /dev/null; then
        echo -e "${GREEN}enum4linux is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing enum4linux...${NC}"
    sudo apt update && sudo apt install -y enum4linux
    if command -v enum4linux &> /dev/null; then
        echo -e "${GREEN}enum4linux installed successfully!${NC}"
    else
        echo -e "${RED}Failed to install enum4linux.${NC}"
    fi
}

# Function to install WhatWeb (web technology fingerprinting tool)
install_whatweb() {
    if command -v whatweb &> /dev/null; then
        echo -e "${GREEN}WhatWeb is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing WhatWeb...${NC}"
    sudo apt update && sudo apt install -y whatweb
    if command -v whatweb &> /dev/null; then
        echo -e "${GREEN}WhatWeb installed successfully!${NC}"
        whatweb --version
    else
        echo -e "${RED}Failed to install WhatWeb.${NC}"
    fi
}

# Function to install Amass (network mapping and attack surface discovery)
install_amass() {
    if command -v amass &> /dev/null; then
        echo -e "${GREEN}Amass is already installed.${NC}"
        return
    fi
    echo -e "${CYAN}Installing Amass...${NC}"
    sudo apt update && sudo apt install -y amass
    if command -v amass &> /dev/null; then
        echo -e "${GREEN}Amass installed successfully!${NC}"
        amass -version
    else
        # Fallback: snap install
        echo -e "${YELLOW}Trying snap install as fallback...${NC}"
        sudo snap install amass
        if command -v amass &> /dev/null; then
            echo -e "${GREEN}Amass installed via snap!${NC}"
        else
            echo -e "${RED}Failed to install Amass.${NC}"
        fi
    fi
}

case $1 in 
    gobuster)   install_function gobuster ;;
    trivy)   install_trivy ;;
    go)   install_go ;;
    sonarqube)   install_sonarqube ;;
    bandit)   install_function bandit ;;
    npm)   install_npm ;;
    snykcli)   install_snyk_cli ;;
    brakeman)   install_brakeman ;;
    osvscanner)   install_osv_scanner ;;
    nmap)   install_function nmap ;;
    aircrack)   install_function aircrack-ng ;;
    reaver)   install_function reaver ;;
    ncrack)   install_function ncrack ;;
    nikto)   install_function nikto ;;
    legion)   install_function legion ;;
    owaspzap)   install_function zaproxy ;;
    john)   install_function john ;;
    sqlmap)   install_function sqlmap ;;
    metasploit)   install_metasploit ;;
    wapiti)   install_function wapiti ;;
    tshark)   install_function tshark ;;
    binwalk)   install_function binwalk ;;
    hashcat)   install_function hashcat ;;
    miranda)   install_miranda ;;
    umap)   install_umap ;;
    bettercap)   install_function bettercap ;;
    scapy)   install_function scapy ;;
    wifiphisher)   install_wifiphisher ;;
    dredd)   install_dredd ;;
    subfinder)   install_subfinder ;;
    ollama)   install_ollama ;;
    hydra)   install_hydra ;;
    feroxbuster)   install_feroxbuster ;;
    theharvester)   install_theharvester ;;
    enum4linux)   install_enum4linux ;;
    whatweb)   install_whatweb ;;
    amass)   install_amass ;;
    *)
    ;;
esac
