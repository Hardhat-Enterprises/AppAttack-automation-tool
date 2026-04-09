#!/bin/bash
# =============================================================================
# mobile.sh — Android emulator setup and automated mobile scan workflow
#
# Replaces: start_android_emulator.sh, automate_mobile_scan.sh
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, display_banner, LOG_FILE, etc.) ===
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# =============================================================================
# SECTION 1 — ANDROID EMULATOR SETUP
# Starts the emulator and configures mitmproxy for traffic interception.
# =============================================================================

start_android_emulator() {
    display_banner "Android Emulator with mitmproxy"

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

# =============================================================================
# SECTION 2 — AUTOMATED MOBILE SCAN WORKFLOW
# Starts the emulator, installs an APK, and runs a MobSF scan in one step.
# =============================================================================

run_automated_mobile_scan() {
    display_banner "Automated Mobile Scan Workflow"
    local apk_path="$1"

    if [[ -z "$apk_path" ]]; then
        read -p "Enter the path to the APK file: " apk_path
    fi

    if [[ ! -f "$apk_path" ]]; then
        echo -e "${BRed}Error: APK file not found at '$apk_path'.${NC}"
        return 1
    fi

    echo -e "${BGreen}[*] Starting Android Emulator...${NC}"
    /opt/android-sdk/emulator/emulator -avd test_avd -writable-system &>/dev/null &
    adb wait-for-device

    echo -e "${BGreen}[*] Installing APK...${NC}"
    adb install "$apk_path"

    echo -e "${BGreen}[*] Starting mitmproxy...${NC}"
    mitmweb --web-host 0.0.0.0 &

    echo -e "${BGreen}[*] Configuring emulator to use mitmproxy...${NC}"
    adb shell settings put global http_proxy 127.0.0.1:8080

    echo -e "${BGreen}[*] Running MobSF scan...${NC}"
    cd /opt/Mobile-Security-Framework-MobSF && ./run.sh

    echo -e "${BGreen}[+] Automated mobile scan completed.${NC}"
}
