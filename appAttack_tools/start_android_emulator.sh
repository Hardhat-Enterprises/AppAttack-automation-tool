#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    echo -e "${BYellow}              Android Emulator with mitmproxy${NC}"
    echo -e "${BBlue}           A Professional Penetration Testing Toolkit${NC}"
    echo -e ""
}

# === Start Android Emulator ===
start_android_emulator() {
    display_banner

    echo -e "${BGreen}[*] Starting Android Emulator...${NC}"
    /opt/android-sdk/emulator/emulator -avd test_avd -writable-system &>/dev/null &
    
    echo -e "${BGreen}[*] Waiting for emulator to boot...${NC}"
    adb wait-for-device
    
    echo -e "${BGreen}[*] Starting mitmproxy...${NC}"
    mitmweb --web-host 0.0.0.0 &
    
    echo -e "${BGreen}[*] Configuring emulator to use mitmproxy...${NC}"
    adb shell settings put global http_proxy 127.0.0.1:8080
    
    echo -e "${BGreen}[*] Installing mitmproxy certificate...${NC}"
    adb shell "su 0 mount -o rw,remount /"
    adb push ~/.mitmproxy/mitmproxy-ca-cert.cer /system/etc/security/cacerts/mitmproxy.crt
    adb shell "su 0 chmod 644 /system/etc/security/cacerts/mitmproxy.crt"
    adb shell "su 0 mount -o ro,remount /"
    
    echo -e "${BGreen}[+] Android Emulator is ready for dynamic analysis.${NC}"
}

# === Main Execution ===
# start_android_emulator
