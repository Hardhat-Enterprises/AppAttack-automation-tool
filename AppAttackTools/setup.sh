#!/bin/bash
# =============================================================================
# setup.sh — AppAttack Toolkit setup: install toolkit, install tools, update tools
#
# Usage (run directly):
#   ./setup.sh install         — deploy toolkit to /opt and run first-time setup
#   ./setup.sh install-tools   — install all security tools
#   ./setup.sh update          — check for and apply updates to all tools
#   ./setup.sh install <tool>  — install a single tool (e.g. ./setup.sh install nmap)
#   ./setup.sh update  <tool>  — update a single tool  (e.g. ./setup.sh update nmap)
#
# When sourced by other scripts, all install_* and update_* functions are available.
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, log helpers, etc.) ===
source "$SCRIPT_DIR/config.sh"

# =============================================================================
# SECTION 1 — TOOLKIT DEPLOYMENT
# =============================================================================

INSTALL_DIR="/opt/appAttack_toolkit"
BIN_DIR="/usr/local/bin"
ENTRY_SCRIPT="main.sh"

deploy_toolkit() {
    echo "Installing AppAttack Toolkit to $INSTALL_DIR ..."
    mkdir -p "$INSTALL_DIR"
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR"

    echo "Running first-time setup..."
    chmod +x "$INSTALL_DIR/first_run.sh"
    "$INSTALL_DIR/first_run.sh"

    ln -sf "$INSTALL_DIR/$ENTRY_SCRIPT" "$BIN_DIR/appAttack_toolkit"
    echo "Installation complete. Run the toolkit using 'appAttack_toolkit'."
}

# =============================================================================
# SECTION 2 — INSTALL TOOLS
# =============================================================================

install_go() {
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
    cd update-golang || exit 1
    sudo ./update-golang.sh &> /dev/null || { echo "Failed to update Go."; return; }
    echo "export PATH=\$PATH:${HOME}/apps/go/bin" >> ~/.bashrc
    source ~/.bashrc
    source /etc/profile.d/golang_path.sh
    version=$(go version | awk '{print $3}' 2>/dev/null) || true
    if [ -n "$version" ]; then
        echo -e "${GREEN}Go installed/updated successfully!${NC}"
    else
        echo "Failed to verify Go installation."
    fi
}

install_trivy() {
    if command -v trivy &> /dev/null; then
        echo -e "${GREEN}Trivy is already installed.${NC}"; trivy version; return
    fi
    echo "[*] Installing Trivy..."
    sudo apt update && sudo apt install -y curl
    sudo sh -c "$(curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh)"
    if [ -f ./bin/trivy ]; then
        sudo mv ./bin/trivy /usr/local/bin/trivy
        sudo chmod +x /usr/local/bin/trivy
    fi
    export PATH=$PATH:/usr/local/bin
    grep -q "/usr/local/bin" ~/.bashrc || echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    command -v trivy &> /dev/null \
        && echo -e "${GREEN}Trivy installed successfully.${NC}" \
        || echo "[!] Trivy installation failed."
}

install_gobuster() {
    if command -v gobuster &> /dev/null; then
        echo -e "${GREEN}Gobuster is already installed.${NC}"; return
    fi
    echo "[*] Installing Gobuster..."
    sudo apt update && sudo apt install -y gobuster
    command -v gobuster &> /dev/null \
        && echo -e "${GREEN}Gobuster installed successfully.${NC}" \
        || echo "[!] Gobuster installation failed."
}

install_sonarqube() {
    if sudo docker images | grep -q sonarqube; then
        echo -e "${GREEN}SonarQube is already installed.${NC}"; return
    fi
    echo -e "${CYAN}Pulling SonarQube Docker image...${NC}"
    sudo docker pull sonarqube
    echo -e "${CYAN}Downloading SonarScanner...${NC}"
    wget -O sonarscanner-cli.zip "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.1.0.4477-linux-x64.zip"
    sudo unzip sonarscanner-cli.zip -d /opt/sonarscanner
    echo 'export PATH=$PATH:/opt/sonarscanner/sonar-scanner-6.1.0.4477-linux-x64/bin' >> ~/.bashrc
    source ~/.bashrc
    echo -e "${GREEN}SonarQube and SonarScanner installed successfully!${NC}"
}

install_bandit() {
    command -v bandit &> /dev/null && { echo -e "${GREEN}Bandit is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Bandit...${NC}"
    sudo apt update && sudo apt install -y bandit \
        && echo -e "${GREEN}Bandit installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Bandit.${NC}"; exit 1; }
}

install_npm() {
    echo -e "${CYAN}Installing npm...${NC}"
    sudo apt update && sudo apt install -y npm \
        && { sudo chown -R "$(whoami)" ~/.npm; echo -e "${GREEN}npm installed successfully!${NC}"; } \
        || { echo -e "${RED}Failed to install npm.${NC}"; exit 1; }
}

install_snyk_cli() {
    command -v npm &> /dev/null || install_npm
    command -v snyk &> /dev/null && { echo -e "${GREEN}Snyk CLI is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Snyk CLI...${NC}"
    sudo npm install -g snyk
    echo -e "${GREEN}Snyk CLI installed successfully!${NC}"
    echo -e "${YELLOW}Authenticating Snyk — click 'Authenticate' in your browser to continue.${NC}"
    snyk auth
}

install_brakeman() {
    command -v brakeman &> /dev/null && { echo -e "${GREEN}Brakeman is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing Brakeman...${NC}"
    sudo gem install brakeman \
        && echo -e "${GREEN}Brakeman installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Brakeman.${NC}"; exit 1; }
}

install_osv_scanner() {
    install_go
    command -v osv-scanner &> /dev/null && { echo -e "${GREEN}osv-scanner is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing osv-scanner...${NC}"
    go install github.com/google/osv-scanner/cmd/osv-scanner@v1
    echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc
    source ~/.bashrc
    echo -e "${GREEN}osv-scanner installed successfully!${NC}"
}

install_nmap() {
    command -v nmap &> /dev/null && { echo -e "${GREEN}nmap is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing nmap...${NC}"
    sudo apt update && sudo apt install -y nmap \
        && echo -e "${GREEN}nmap installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install nmap.${NC}"; exit 1; }
}

install_aircrack() {
    command -v aircrack-ng &> /dev/null && { echo -e "${GREEN}aircrack-ng is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing aircrack-ng...${NC}"
    sudo apt update && sudo apt install -y aircrack-ng \
        && echo -e "${GREEN}aircrack-ng installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install aircrack-ng.${NC}"; exit 1; }
}

install_reaver() {
    command -v reaver &> /dev/null && { echo -e "${GREEN}Reaver is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Reaver...${NC}"
    sudo apt update && sudo apt install -y build-essential libpcap-dev aircrack-ng git > /dev/null 2>&1 \
        || { echo -e "${RED}Failed to install Reaver dependencies.${NC}"; exit 1; }
    git clone https://github.com/t6x/reaver-wps-fork-t6x.git /tmp/reaver-wps-fork-t6x > /dev/null 2>&1 \
        || { echo -e "${RED}Failed to clone Reaver repository.${NC}"; exit 1; }
    cd /tmp/reaver-wps-fork-t6x/src || exit
    ./configure > /dev/null 2>&1 && make > /dev/null 2>&1 && sudo make install > /dev/null 2>&1 \
        && echo -e "${GREEN}Reaver installed successfully!${NC}" \
        || { echo -e "${RED}Failed to build/install Reaver.${NC}"; exit 1; }
    cd ~ && sudo rm -rf /tmp/reaver-wps-fork-t6x
}

install_ncrack() {
    command -v ncrack &> /dev/null && { echo -e "${GREEN}ncrack is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing ncrack...${NC}"
    sudo apt update && sudo apt install -y ncrack \
        && echo -e "${GREEN}ncrack installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install ncrack.${NC}"; exit 1; }
}

install_nikto() {
    command -v nikto &> /dev/null && { echo -e "${GREEN}nikto is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing nikto...${NC}"
    sudo apt update && sudo apt install -y nikto \
        && echo -e "${GREEN}nikto installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install nikto.${NC}"; exit 1; }
}

install_legion() {
    command -v legion &> /dev/null && { echo -e "${GREEN}LEGION is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing LEGION...${NC}"
    sudo apt update && sudo apt install -y legion \
        && echo -e "${GREEN}LEGION installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install LEGION.${NC}"; exit 1; }
}

install_owasp_zap() {
    [ -d "/opt/owasp-zap/" ] && { echo -e "${GREEN}OWASP ZAP is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing OWASP ZAP...${NC}"
    wget https://github.com/zaproxy/zaproxy/releases/download/v2.15.0/ZAP_2.15.0_Linux.tar.gz -P /tmp \
        || { echo -e "${RED}Failed to download OWASP ZAP.${NC}"; exit 1; }
    sudo mkdir -p /opt/owasp-zap
    sudo chown -R "$(whoami)":"$(whoami)" /opt/owasp-zap
    tar -xf /tmp/ZAP_2.15.0_Linux.tar.gz -C /opt/owasp-zap/
    sudo ln -s /opt/owasp-zap/ZAP_2.15.0/zap.sh /usr/local/bin/zap \
        && echo -e "${GREEN}OWASP ZAP installed successfully!${NC}" \
        || { echo -e "${RED}Failed to create OWASP ZAP symlink.${NC}"; exit 1; }
}

install_john() {
    command -v john &> /dev/null && { echo -e "${GREEN}John the Ripper is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing John the Ripper...${NC}"
    sudo apt update && sudo apt install -y john \
        && echo -e "${GREEN}John the Ripper installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install John the Ripper.${NC}"; exit 1; }
}

install_sqlmap() {
    command -v sqlmap &> /dev/null && { echo -e "${GREEN}sqlmap is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing sqlmap...${NC}"
    sudo apt update && sudo apt install -y sqlmap \
        && echo -e "${GREEN}sqlmap installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install sqlmap.${NC}"; exit 1; }
}

install_metasploit() {
    command -v msfconsole &> /dev/null && { echo -e "${GREEN}Metasploit is already installed.${NC}"; return; }
    echo -e "${MAGENTA}Installing Metasploit...${NC}"
    sudo apt update && sudo apt install -y metasploit-framework \
        && echo -e "${GREEN}Metasploit installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Metasploit.${NC}"; exit 1; }
}

install_wapiti() {
    command -v wapiti &> /dev/null && { echo -e "${GREEN}Wapiti is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Wapiti...${NC}"
    sudo apt update && sudo apt install -y wapiti \
        && echo -e "${GREEN}Wapiti installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Wapiti.${NC}"; exit 1; }
}

install_tshark() {
    command -v tshark &> /dev/null && { echo -e "${GREEN}TShark is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing TShark...${NC}"
    sudo apt update && sudo apt install -y tshark \
        && echo -e "${GREEN}TShark installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install TShark.${NC}"; exit 1; }
}

install_binwalk() {
    command -v binwalk &> /dev/null && { echo -e "${GREEN}Binwalk is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Binwalk...${NC}"
    sudo apt update && sudo apt install -y binwalk \
        && echo -e "${GREEN}Binwalk installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Binwalk.${NC}"; exit 1; }
}

install_hashcat() {
    command -v hashcat &> /dev/null && { echo -e "${GREEN}Hashcat is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Hashcat...${NC}"
    sudo apt update && sudo apt install -y hashcat \
        && echo -e "${GREEN}Hashcat installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Hashcat.${NC}"; exit 1; }
}

install_miranda() {
    [ -d "/opt/miranda/" ] && { echo -e "${GREEN}Miranda is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Miranda...${NC}"
    wget https://toor.do/umap-0.8.tar.gz -P /tmp \
        || { echo -e "${RED}Failed to download Miranda.${NC}"; exit 1; }
    sudo mkdir -p /opt/miranda
    sudo chown -R "$(whoami)":"$(whoami)" /opt/miranda
    tar -xf /tmp/umap-0.8.tar.gz -C /opt/miranda/
    cd /opt/miranda && make && make install && cd "$SCRIPT_DIR"
    sudo ln -s /opt/miranda-1.3/miranda.py /usr/local/bin/miranda \
        && echo -e "${GREEN}Miranda installed successfully!${NC}" \
        || { echo -e "${RED}Failed to create Miranda symlink.${NC}"; exit 1; }
}

install_umap() {
    [ -d "/opt/umap/" ] && { echo -e "${GREEN}Umap is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Umap...${NC}"
    wget https://toor.do/umap-0.8.tar.gz -P /tmp
    pip install SOAPpy iplib
    sudo mkdir -p /opt/umap
    sudo chown -R "$(whoami)":"$(whoami)" /opt/umap
    tar -xf /tmp/umap-0.8.tar.gz -C /opt/umap/
    cd /opt/umap && make && make install && cd "$SCRIPT_DIR"
    sudo ln -s python3 /opt/umap/umap-0.8/umap.py /usr/local/bin/umap \
        && echo -e "${GREEN}Umap installed successfully!${NC}" \
        || { echo -e "${RED}Failed to create Umap symlink.${NC}"; exit 1; }
}

install_bettercap() {
    command -v bettercap &> /dev/null && { echo -e "${GREEN}Bettercap is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Bettercap...${NC}"
    sudo apt update && sudo apt install -y bettercap \
        && echo -e "${GREEN}Bettercap installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Bettercap.${NC}"; exit 1; }
}

install_scapy() {
    command -v scapy &> /dev/null && { echo -e "${GREEN}Scapy is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Scapy...${NC}"
    sudo apt update > /dev/null 2>&1 && sudo apt install -y python3-scapy > /dev/null 2>&1 \
        && echo -e "${GREEN}Scapy installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Scapy.${NC}"; exit 1; }
}

install_subfinder() {
    command -v subfinder &> /dev/null && { echo -e "${GREEN}Subfinder is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Subfinder...${NC}"
    sudo apt update && sudo apt install -y subfinder && { echo -e "${GREEN}Subfinder installed via apt!${NC}"; return; }
    echo -e "${YELLOW}apt failed; trying Go fallback...${NC}"
    command -v go &> /dev/null || sudo apt install -y golang
    GO111MODULE=on go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
        && { echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc; source ~/.bashrc; echo -e "${GREEN}Subfinder installed via Go!${NC}"; } \
        || { echo -e "${RED}Failed to install Subfinder.${NC}"; return 1; }
}

install_httpx() {
    command -v httpx &> /dev/null && { echo -e "${GREEN}httpx is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing httpx...${NC}"
    sudo apt update && sudo apt install -y httpx && { echo -e "${GREEN}httpx installed via apt!${NC}"; return; }
    echo -e "${YELLOW}apt failed; trying Go fallback...${NC}"
    command -v go &> /dev/null || sudo apt install -y golang
    GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest \
        && { echo 'export PATH=$PATH:'"$(go env GOPATH)"/bin >> ~/.bashrc; source ~/.bashrc; echo -e "${GREEN}httpx installed via Go!${NC}"; } \
        || { echo -e "${RED}Failed to install httpx.${NC}"; return 1; }
}

install_wifiphisher() {
    command -v wifiphisher &> /dev/null && { echo -e "${GREEN}Wifiphisher is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Wifiphisher...${NC}"
    [ -d "/tmp/wifiphisher" ] && sudo rm -rf /tmp/wifiphisher
    sudo apt update -y && sudo apt install -y git python3-pip libnl-3-dev libnl-genl-3-dev python3-dev
    git clone https://github.com/wifiphisher/wifiphisher.git /tmp/wifiphisher \
        || { echo -e "${RED}Failed to clone Wifiphisher.${NC}"; exit 1; }
    sed -i 's/from ConfigParser import SafeConfigParser/from configparser import ConfigParser/' \
        /tmp/wifiphisher/roguehostapd/config/hostapdconfig.py
    cd /tmp/wifiphisher
    sudo pip3 install -r requirements.txt
    sudo python3 setup.py install \
        && echo -e "${GREEN}Wifiphisher installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Wifiphisher.${NC}"; exit 1; }
    echo -e "${YELLOW}Cleaning up...${NC}"
    cd ~ && sudo rm -rf /tmp/wifiphisher
}

install_gitleaks() {
    command -v gitleaks &> /dev/null && { echo -e "${GREEN}Gitleaks is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Gitleaks...${NC}"
    local latest_url
    latest_url=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
        | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d '"' -f 4)
    [ -z "$latest_url" ] && { echo -e "${RED}Failed to fetch Gitleaks URL.${NC}"; return 1; }
    wget -O /tmp/gitleaks.tar.gz "$latest_url"
    tar -xzf /tmp/gitleaks.tar.gz -C /tmp
    sudo mv /tmp/gitleaks /usr/local/bin/gitleaks && sudo chmod +x /usr/local/bin/gitleaks
    rm /tmp/gitleaks.tar.gz
    echo -e "${GREEN}Gitleaks installed successfully!${NC}"
}

install_dredd() {
    command -v dredd &> /dev/null && { echo -e "${GREEN}Dredd is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Dredd...${NC}"
    command -v npm &> /dev/null || { echo -e "${YELLOW}Installing npm first...${NC}"; sudo apt update && sudo apt install -y npm; }
    sudo npm install -g dredd
    command -v dredd &> /dev/null \
        && echo -e "${GREEN}Dredd installed successfully!${NC}" \
        || { echo -e "${RED}Failed to install Dredd.${NC}"; exit 1; }
}

install_scoutsuite() {
    command -v scoutsuite &> /dev/null && { echo "ScoutSuite is already installed."; return; }
    echo "Installing ScoutSuite..."
    pip3 install scoutsuite && echo "ScoutSuite installed successfully."
}

install_mobsf() {
    [ -d "/opt/Mobile-Security-Framework-MobSF" ] && { echo -e "${GREEN}MobSF is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing MobSF...${NC}"
    sudo apt update && sudo apt install -y git python3-venv python3-pip
    git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF.git /opt/Mobile-Security-Framework-MobSF
    cd /opt/Mobile-Security-Framework-MobSF && ./setup.sh
    echo -e "${GREEN}MobSF installed successfully!${NC}"
}

install_android_sdk() {
    [ -d "/opt/android-sdk" ] && { echo -e "${GREEN}Android SDK is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing Android SDK...${NC}"
    sudo apt update && sudo apt install -y wget unzip
    mkdir -p /opt/android-sdk && cd /opt/android-sdk
    wget https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
    unzip commandlinetools-linux-6858069_latest.zip && rm commandlinetools-linux-6858069_latest.zip
    yes | tools/bin/sdkmanager --licenses
    tools/bin/sdkmanager "platform-tools" "platforms;android-29" "system-images;android-29;google_apis;x86_64"
    echo 'export ANDROID_HOME=/opt/android-sdk' >> ~/.bashrc
    echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
    source ~/.bashrc
    echo -e "${GREEN}Android SDK installed successfully!${NC}"
}

create_avd() {
    echo -e "${CYAN}Creating Android Virtual Device...${NC}"
    echo "no" | /opt/android-sdk/tools/bin/avdmanager create avd \
        -n test_avd -k "system-images;android-29;google_apis;x86_64"
    echo -e "${GREEN}Android Virtual Device created successfully!${NC}"
}

install_mitmproxy() {
    command -v mitmproxy &> /dev/null && { echo -e "${GREEN}mitmproxy is already installed.${NC}"; return; }
    echo -e "${CYAN}Installing mitmproxy...${NC}"
    sudo apt update && sudo apt install -y python3-pip
    pip3 install mitmproxy
    echo -e "${GREEN}mitmproxy installed successfully!${NC}"
}

install_ollama() {
    command -v ollama &> /dev/null && { echo "ollama is already installed at: $(command -v ollama)"; return; }
    command -v curl &> /dev/null || { sudo apt update && sudo apt install -y curl; }
    curl -fsSL https://ollama.com/install.sh | sudo sh
}

# Install all tools at once
install_all_tools() {
    command -v npm  &> /dev/null || install_npm
    command -v go   &> /dev/null || install_go
    install_ollama
    install_osv_scanner
    install_snyk_cli
    install_brakeman
    install_bandit
    install_nmap
    install_nikto
    install_legion
    install_owasp_zap
    install_john
    install_sqlmap
    install_metasploit
    install_sonarqube
    install_wapiti
    install_tshark
    install_binwalk
    install_hashcat
    install_miranda
    install_umap
    install_bettercap
    install_scapy
    install_subfinder
    install_httpx
    install_wifiphisher
    install_reaver
    install_ncrack
    install_aircrack
    install_gitleaks
    install_dredd
    install_trivy
    install_gobuster
    install_scoutsuite
    install_mobsf
    install_android_sdk
    install_mitmproxy
    install_generate_ai_insights_dependencies
}

# =============================================================================
# SECTION 3 — UPDATE TOOLS
# =============================================================================

_apt_update_tool() {
    # Helper: install-or-update a single apt-managed tool
    local cmd="$1" pkg="${2:-$1}"
    if ! command -v "$cmd" &> /dev/null; then
        sudo apt install -y "$pkg" > /dev/null 2>&1 && log_message "$pkg installed"
    else
        local cur lat
        cur=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null)
        lat=$(apt-cache policy "$pkg" | awk '/Candidate:/{print $2}')
        if [ "$cur" != "$lat" ]; then
            sudo apt install -y "$pkg" > /dev/null 2>&1 && log_message "$pkg updated to $lat"
        else
            log_message "$pkg is up-to-date ($cur)"
        fi
    fi
}

update_brakeman() {
    sudo gem update brakeman > /dev/null 2>&1 \
        && log_message "Brakeman up-to-date" \
        || log_message "Failed to update Brakeman"
}

update_snyk() {
    command -v snyk &> /dev/null && sudo npm update -g snyk > /dev/null 2>&1 \
        && log_message "Snyk updated" || log_message "Snyk not installed; skipping"
}

update_owasp_zap() { _apt_update_tool zaproxy; }
update_nikto()     { _apt_update_tool nikto; }
update_nmap()      { _apt_update_tool nmap; }
update_aircrack()  { _apt_update_tool aircrack-ng; }
update_reaver()    { _apt_update_tool reaver; }
update_ncrack()    { _apt_update_tool ncrack; }
update_wapiti()    { _apt_update_tool wapiti; }
update_tshark()    { _apt_update_tool tshark; }
update_binwalk()   { _apt_update_tool binwalk; }
update_hashcat()   { _apt_update_tool hashcat; }
update_miranda()   { _apt_update_tool miranda; }
update_umap()      { _apt_update_tool umap; }

update_john() {
    if ! command -v john &> /dev/null; then
        echo -e "${MAGENTA}Installing John the Ripper...${NC}"
        sudo apt install -y john > /dev/null 2>&1 && log_message "John the Ripper installed"
    else
        _apt_update_tool john
    fi
}

update_bandit() {
    if ! command -v bandit &> /dev/null; then
        sudo apt install -y bandit > /dev/null 2>&1 && log_message "Bandit installed"
    else
        echo -e "${MAGENTA}Updating Bandit...${NC}"
        _apt_update_tool bandit
    fi
}

update_sqlmap() {
    if ! command -v sqlmap &> /dev/null; then
        sudo apt update && sudo apt install -y sqlmap && log_message "sqlmap installed"
    else
        local output; output=$(sqlmap 2>&1)
        if echo "$output" | grep -qE "haven't updated|version is outdated"; then
            echo -e "${MAGENTA}Updating sqlmap...${NC}"
            sudo sqlmap --update && log_message "sqlmap updated"
        else
            log_message "sqlmap is up-to-date"
        fi
    fi
}

update_metasploit() {
    if ! command -v msfconsole &> /dev/null; then
        sudo apt update && sudo apt install -y metasploit-framework > /dev/null 2>&1 \
            && log_message "Metasploit installed" || { log_message "Failed to install Metasploit"; exit 1; }
    else
        _apt_update_tool msfconsole metasploit-framework
    fi
}

update_bettercap() {
    if ! command -v bettercap &> /dev/null; then
        echo -e "${MAGENTA}Installing Bettercap...${NC}"
        sudo apt update > /dev/null 2>&1 && sudo apt install -y bettercap > /dev/null 2>&1 \
            && log_message "Bettercap installed"
    else
        local cur lat
        cur=$(bettercap --version | awk '{print $2}')
        lat=$(curl -s https://github.com/bettercap/bettercap/releases/latest | grep -oP 'v\K[0-9.]+')
        if [ "$cur" != "$lat" ]; then
            echo -e "${MAGENTA}Updating Bettercap...${NC}"
            sudo apt remove -y bettercap > /dev/null 2>&1
            curl -L "https://github.com/bettercap/bettercap/releases/download/v${lat}/bettercap_linux_amd64" \
                -o /tmp/bettercap > /dev/null 2>&1
            sudo mv /tmp/bettercap /usr/local/bin/bettercap && sudo chmod +x /usr/local/bin/bettercap
            log_message "Bettercap updated to $lat"
        else
            log_message "Bettercap is up-to-date ($cur)"
        fi
    fi
}

update_scapy() {
    if ! command -v scapy &> /dev/null; then
        echo -e "${MAGENTA}Installing Scapy...${NC}"
        sudo apt update > /dev/null 2>&1 && sudo apt install -y python3-scapy > /dev/null 2>&1 \
            && log_message "Scapy installed"
    else
        echo -e "${MAGENTA}Updating Scapy...${NC}"
        sudo pip install --upgrade scapy > /dev/null 2>&1 && log_message "Scapy updated"
    fi
}

update_wifiphisher() {
    if ! command -v wifiphisher &> /dev/null; then
        echo -e "${MAGENTA}Installing Wifiphisher...${NC}"
        sudo apt update > /dev/null 2>&1 && sudo apt install -y wifiphisher > /dev/null 2>&1 \
            && log_message "Wifiphisher installed"
    else
        local cur lat
        cur=$(wifiphisher --version 2>&1 | awk '{print $NF}')
        lat=$(curl -s https://github.com/wifiphisher/wifiphisher/releases/latest | grep -oP 'v\K[0-9.]+' | head -n 1)
        if [ "$cur" != "$lat" ]; then
            echo -e "${MAGENTA}Updating Wifiphisher...${NC}"
            sudo apt remove -y wifiphisher > /dev/null 2>&1
            git clone https://github.com/wifiphisher/wifiphisher.git /tmp/wifiphisher > /dev/null 2>&1
            cd /tmp/wifiphisher && sudo python3 setup.py install > /dev/null 2>&1
            cd ~ && sudo rm -rf /tmp/wifiphisher
            log_message "Wifiphisher updated to $lat"
        else
            log_message "Wifiphisher is up-to-date ($cur)"
        fi
    fi
}

# Update all tools (prompts user first)
check_updates() {
    while true; do
        read -p "Do you want to check for updates? (y/n): " answer
        case "$answer" in
            [Yy])
                log_message "Checking for updates..."
                if [ "$(sudo find /var/lib/apt/lists -type f -mtime +1 | wc -l)" -gt 0 ]; then
                    sudo apt update -qq
                fi
                update_brakeman; update_snyk;    update_owasp_zap; update_nikto
                update_nmap;     update_aircrack; update_reaver;   update_ncrack
                update_john;     update_sqlmap;   update_metasploit; update_wapiti
                update_miranda;  update_umap;     update_bandit;   update_bettercap
                update_scapy;    update_wifiphisher; update_tshark; update_binwalk
                update_hashcat
                echo -e "${GREEN}Updates checked successfully.${NC}"
                break ;;
            [Nn])
                echo -e "${YELLOW}Skipping updates.${NC}"
                break ;;
            *) echo "Please answer 'y' or 'n'." ;;
        esac
    done
}

# =============================================================================
# SECTION 4 — CLI ENTRY POINT
# (Only runs when the script is executed directly, not when sourced)
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    ACTION="${1:-}"
    TOOL="${2:-}"

    case "$ACTION" in
        install)
            if [ -n "$TOOL" ]; then
                # Install a single named tool
                case "$TOOL" in
                    gobuster)    install_gobuster ;;
                    trivy)       install_trivy ;;
                    go)          install_go ;;
                    sonarqube)   install_sonarqube ;;
                    bandit)      install_bandit ;;
                    npm)         install_npm ;;
                    snykcli)     install_snyk_cli ;;
                    brakeman)    install_brakeman ;;
                    osvscanner)  install_osv_scanner ;;
                    nmap)        install_nmap ;;
                    aircrack)    install_aircrack ;;
                    reaver)      install_reaver ;;
                    ncrack)      install_ncrack ;;
                    nikto)       install_nikto ;;
                    legion)      install_legion ;;
                    owaspzap)    install_owasp_zap ;;
                    john)        install_john ;;
                    sqlmap)      install_sqlmap ;;
                    metasploit)  install_metasploit ;;
                    wapiti)      install_wapiti ;;
                    tshark)      install_tshark ;;
                    binwalk)     install_binwalk ;;
                    hashcat)     install_hashcat ;;
                    miranda)     install_miranda ;;
                    umap)        install_umap ;;
                    bettercap)   install_bettercap ;;
                    scapy)       install_scapy ;;
                    wifiphisher) install_wifiphisher ;;
                    dredd)       install_dredd ;;
                    subfinder)   install_subfinder ;;
                    httpx)       install_httpx ;;
                    ollama)      install_ollama ;;
                    mobsf)       install_mobsf ;;
                    mitmproxy)   install_mitmproxy ;;
                    scoutsuite)  install_scoutsuite ;;
                    *) echo -e "${RED}Unknown tool: $TOOL${NC}"; exit 1 ;;
                esac
            else
                # No tool specified: deploy the toolkit itself
                deploy_toolkit
            fi
            ;;
        install-tools)
            install_all_tools
            ;;
        update)
            if [ -n "$TOOL" ]; then
                case "$TOOL" in
                    brakeman)    update_brakeman ;;
                    snyk)        update_snyk ;;
                    owaspzap)    update_owasp_zap ;;
                    nikto)       update_nikto ;;
                    nmap)        update_nmap ;;
                    aircrack)    update_aircrack ;;
                    reaver)      update_reaver ;;
                    ncrack)      update_ncrack ;;
                    john)        update_john ;;
                    sqlmap)      update_sqlmap ;;
                    metasploit)  update_metasploit ;;
                    wapiti)      update_wapiti ;;
                    miranda)     update_miranda ;;
                    umap)        update_umap ;;
                    bandit)      update_bandit ;;
                    bettercap)   update_bettercap ;;
                    scapy)       update_scapy ;;
                    wifiphisher) update_wifiphisher ;;
                    tshark)      update_tshark ;;
                    binwalk)     update_binwalk ;;
                    hashcat)     update_hashcat ;;
                    *) echo -e "${RED}Unknown tool: $TOOL${NC}"; exit 1 ;;
                esac
            else
                check_updates
            fi
            ;;
        *)
            echo "Usage: $0 {install|install-tools|update} [tool]"
            echo ""
            echo "  install              Deploy toolkit to /opt and run first-time setup"
            echo "  install-tools        Install all security tools"
            echo "  install <tool>       Install a single tool (e.g. nmap, trivy, snyk)"
            echo "  update               Check and apply updates for all tools"
            echo "  update  <tool>       Update a single tool (e.g. nmap, brakeman)"
            exit 1
            ;;
    esac
fi
