#!/bin/bash
# =============================================================================
# recon.sh — All reconnaissance functions
#
# Replaces: automate_recon.sh, automate_reconnaissance.sh, automate.sh
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, display_banner, LOG_FILE, etc.) ===
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# =============================================================================
# SECTION 1 — VALIDATION HELPERS (shared by all sections below)
# =============================================================================

validate_ip() {
    local ip="$1"
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        local IFS='.'
        read -r o1 o2 o3 o4 <<< "$ip"
        for octet in "$o1" "$o2" "$o3" "$o4"; do
            ((octet >= 0 && octet <= 255)) || return 1
        done
        return 0
    fi
    return 1
}

validate_port() {
    local port="$1"
    [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535))
}

validate_url() {
    if [[ ! "$1" =~ ^https?://[a-zA-Z0-9.-]+(\:[0-9]+)?(/.*)?$ ]]; then
        echo "[!] Invalid URL format: $1"
        echo "    Example: http://example.com or https://site.com:8080/path"
        return 1
    fi
}

# =============================================================================
# SECTION 2 — INTERACTIVE RECON MENU
# Individual tools the user can run one at a time.
# =============================================================================

display_reconnaissance_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Reconnaissance Workflows         ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Basic Host Discovery (Nmap Ping Scan)${NC}"
    echo -e "${BCyan}2)${NC} ${White}Full Port & Service Scan (Nmap)${NC}"
    echo -e "${BCyan}3)${NC} ${White}Web Server Vulnerability Scan (Nikto)${NC}"
    echo -e "${BCyan}4)${NC} ${White}Passive Web Recon (Wapiti Spidering)${NC}"
    echo -e "${BCyan}5)${NC} ${White}Packet Capture (Tshark)${NC}"
    echo -e "${BCyan}6)${NC} ${White}GUI Recon Tool (Legion)${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back (to Main Menu)${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

run_basic_host_discovery() {
    read -p "Enter target subnet (e.g. 192.168.1.0/24): " target
    if [[ ! "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]; then
        echo "[-] Invalid subnet format!"
        return 1
    fi
    echo "[*] Running Nmap Ping Scan on $target..."
    nmap -sn "$target"
    echo "[+] Ping scan finished."
}

run_full_port_scan() {
    read -p "Enter target IP or domain: " target
    echo "[*] Running full port scan on $target..."
    nmap -p- -sV "$target"
    echo "[+] Full port scan complete."
}

run_web_server_scan() {
    read -p "Enter target IP or domain: " target
    read -p "Enter port (default 80): " port
    port=${port:-80}
    nikto -h "$target" -p "$port"
}

run_passive_web_recon() {
    read -p "Enter target URL (e.g. http://example.com): " url
    echo "[*] Running Wapiti scan on $url..."
    wapiti -u "$url" -f html -o "wapiti_report.html"
    echo "[+] Wapiti scan completed. Report saved to wapiti_report.html"
}

run_packet_capture() {
    read -p "Enter interface to sniff (e.g. eth0): " iface
    tshark -i "$iface" -a duration:10 -w "capture.pcap"
    echo "[+] Packet capture saved to capture.pcap"
}

run_legion_recon() {
    echo "[*] Starting Legion GUI..."
    legion &
}

run_reconnaissance_menu() {
    while true; do
        display_reconnaissance_menu
        read -p "Choose a Reconnaissance option: " choice
        case $choice in
            1) run_basic_host_discovery ;;
            2) run_full_port_scan ;;
            3) run_web_server_scan ;;
            4) run_passive_web_recon ;;
            5) run_packet_capture ;;
            6) run_legion_recon ;;
            0) return ;;
            *) echo "Invalid option. Please choose again." ;;
        esac
        echo; read -p "Press Enter to continue..."
    done
}

# =============================================================================
# SECTION 3 — AUTOMATED SEQUENTIAL SCAN
# Runs nmap → nikto → zap → wapiti against a prompted target.
# =============================================================================

: > "$LOG_FILE"

_recon_log() { printf '%s [%s] %s\n' "$(date -Is)" "$1" "$2" | tee -a "$LOG_FILE"; }
_need()       { command -v "$1" >/dev/null 2>&1 || { _recon_log "ERROR" "Missing required tool: $1"; exit 127; }; }

_recon_log "INFO" "Checking required tools..."
_need nmap
command -v nikto   >/dev/null 2>&1 || _recon_log "WARN" "Nikto not found; its step will be skipped."
[ -x /opt/zaproxy/zap.sh ]         || _recon_log "WARN" "ZAP not found; its step will be skipped."
command -v wapiti  >/dev/null 2>&1 || _recon_log "WARN" "Wapiti not found; its step will be skipped."

_auto_nmap() {
    _recon_log "INFO" "Running Nmap..."
    local out="$HOME/nmap_scan_output.txt"
    nmap -Pn -sV -- "$ip" | tee -a "$LOG_FILE" > "$out"
    _recon_log "INFO" "Nmap complete. Output: $out"
}

_auto_nikto() {
    command -v nikto >/dev/null 2>&1 || { _recon_log "WARN" "Nikto not installed; skipping."; return 0; }
    _recon_log "INFO" "Running Nikto..."
    local out="$HOME/nikto_scan_output.txt"
    nikto -h "$ip" -port "$port" | tee -a "$LOG_FILE" > "$out"
    _recon_log "INFO" "Nikto complete. Output: $out"
}

_auto_zap() {
    [ -x /opt/zaproxy/zap.sh ] || { _recon_log "WARN" "ZAP not available; skipping."; return 0; }
    _recon_log "INFO" "Running OWASP ZAP..."
    local ts; ts="$(date +"%Y%m%d_%H%M%S")"
    local zap_dir="$HOME/zap_reports"
    mkdir -p "$zap_dir"
    timeout 15m /opt/zaproxy/zap.sh \
        -cmd -quickurl "http://$ip:$port" \
        -quickout "$zap_dir/zap_report_${ts}.html" \
        -addonupdate -quickprogress \
        -jsonreport "$zap_dir/zap_report_${ts}.json" \
        > "$zap_dir/zap_output_${ts}.txt" 2>&1 \
        || _recon_log "WARN" "ZAP exited non-zero."
    _recon_log "INFO" "ZAP complete. Reports in $zap_dir"
}

_auto_wapiti() {
    command -v wapiti >/dev/null 2>&1 || { _recon_log "WARN" "Wapiti not installed; skipping."; return 0; }
    _recon_log "INFO" "Running Wapiti..."
    local out="$HOME/wapiti_scan_output.txt"
    wapiti -u "http://$ip:$port" | tee -a "$LOG_FILE" > "$out"
    _recon_log "INFO" "Wapiti complete. Output: $out"
}

run_automated_scan() {
    local ip port

    while true; do
        read -p "Enter the target IP address: " ip
        validate_ip "$ip" && break
        echo "Invalid IP address. Please enter a valid IPv4 address."
    done

    while true; do
        read -p "Enter the target port: " port
        validate_port "$port" && break
        echo "Invalid port number. Please enter a number between 1 and 65535."
    done

    _recon_log "INFO" "Starting automated scans — IP: $ip  Port: $port"

    _auto_nmap
    _auto_nikto
    _auto_zap
    _auto_wapiti

    _recon_log "INFO" "All reconnaissance scans complete."
}
