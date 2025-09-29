#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Source Libraries ===
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# === Color Codes ===
BYellow="\033[1;33m"
BRed="\033[1;31m"
BGreen="\033[1;32m"
BBlue="\033[1;34m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"

# === Banner ===
display_banner() {
    clear
    echo -e "${BRed}"
    echo -e " █████╗ ██████╗ ██████╗     ███████╗██╗  ██╗██████╗ ██╗      ██████╗ ██╗████████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗"
    echo -e "██╔══██╗██╔══██╗██╔══██╗    ██╔════╝╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║"
    echo -e "███████║██████╔╝██████╔╝    █████╗   ╚███╔╝ ██████╔╝██║     ██║   ██║██║   ██║   ███████║   ██║   ██║██║   ██║██╔██╗ ██║"
    echo -e "██╔══██║██╔═══╝ ██╔═══╝     ██╔══╝   ██╔██╗ ██╔═══╝ ██║     ██║   ██║██║   ██║   ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║"
    echo -e "██║  ██║██║     ██║         ███████╗██╔╝ ██╗██║     ███████╗╚██████╔╝██║   ██║   ██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║"
    echo -e "╚═╝  ╚═╝╚═╝     ╚═╝         ╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo -e "${NC}"
    echo -e "${BYellow}              Automated Mobile Scan Workflow${NC}"
    echo -e "${BBlue}           A Professional Penetration Testing Toolkit${NC}"
    echo -e ""
}

# === Automated Mobile Scan Workflow ===
run_automated_mobile_scan() {
    local apk_path="$1"

    if [ -z "$apk_path" ]; then
        echo -e "${BRed}Error: APK file path not provided.${NC}"
        exit 1
    fi

    if [ ! -f "$apk_path" ]; then
        echo -e "${BRed}Error: APK file not found at '$apk_path'.${NC}"
        exit 1
    fi

    # Start Android Emulator
    echo -e "${BGreen}[*] Starting Android Emulator...${NC}"
    /opt/android-sdk/emulator/emulator -avd test_avd -writable-system &>/dev/null &
    adb wait-for-device

    # Install APK
    echo -e "${BGreen}[*] Installing APK...${NC}"
    adb install "$apk_path"

    # Start mitmproxy
    echo -e "${BGreen}[*] Starting mitmproxy...${NC}"
    mitmweb --web-host 0.0.0.0 &

    # Configure emulator to use mitmproxy
    echo -e "${BGreen}[*] Configuring emulator to use mitmproxy...${NC}"
    adb shell settings put global http_proxy 127.0.0.1:8080

    # Run MobSF
    echo -e "${BGreen}[*] Running MobSF scan...${NC}"
    cd /opt/Mobile-Security-Framework-MobSF
    ./run.sh

    echo -e "${BGreen}[+] Automated mobile scan completed.${NC}"
}

# === Main Execution ===
display_banner
run_automated_mobile_scan
