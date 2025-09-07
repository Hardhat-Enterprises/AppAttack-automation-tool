#!/usr/bin/env bash

# ---- safety baseline (minimal change) ----
set -euo pipefail
IFS=$'\n\t'

#Define the log file location
LOG_DIR="$HOME/appattack_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/automated_scan_$(date +%F_%H-%M-%S).log"
: > "$LOG_FILE"

log() { printf '%s [%s] %s\n' "$(date -Is)" "$1" "$2" | tee -a "$LOG_FILE" ; }
need() { command -v "$1" >/dev/null 2>&1 || { log "ERROR" "Missing required tool: $1"; exit 127; }; }

# Ensure core tools exist (soft-fail for optional ones)
need nmap
command -v nikto >/dev/null 2>&1 || log "WARN" "Nikto not found; its step will be skipped."
[ -x /opt/zaproxy/zap.sh ] || log "WARN" "ZAP not found at /opt/zaproxy/zap.sh; its step will be skipped."
command -v wapiti >/dev/null 2>&1 || log "WARN" "Wapiti not found; its step will be skipped."

# Function to validate IP address
validate_ip() {
    local ip="$1"
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        local o1 o2 o3 o4
        IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
        for octet in "$o1" "$o2" "$o3" "$o4"; do
            ((octet >= 0 && octet <= 255)) || return 1
        done
        return 0
    fi
    return 1
}

# Function to validate port
validate_port() {
    local port="$1"
    if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
        return 0
    fi
    return 1
}

# Function to run Nmap
auto_nmap() {
    log "INFO" "Running Nmap..."
    local nmap_output_file="$HOME/nmap_scan_output.txt"
    # Use array + -- to avoid option injection / word splitting
    local args=(-Pn -sV --)
    nmap "${args[@]}" "$ip" | tee -a "$LOG_FILE" > "$nmap_output_file"
    log "INFO" "Nmap scan completed. Output: $nmap_output_file"
}

# Function to run Nikto
auto_nikto() {
    if ! command -v nikto >/dev/null 2>&1; then
        log "WARN" "Nikto not installed; skipping."
        return 0
    fi
    log "INFO" "Running Nikto..."
    local nikto_output_file="$HOME/nikto_scan_output.txt"
    # Correct/safe param style: host and port separated
    nikto -h "$ip" -port "$port" | tee -a "$LOG_FILE" > "$nikto_output_file"
    log "INFO" "Nikto output saved to $nikto_output_file"
    log "INFO" "Nikto scan completed."
}

# Function to run OWASP ZAP automatically in headless mode
auto_zap() {
    if [ ! -x /opt/zaproxy/zap.sh ]; then
        log "WARN" "ZAP not available; skipping."
        return 0
    fi

    log "INFO" "Running OWASP ZAP..."
    local timestamp
    timestamp="$(date +"%Y%m%d_%H%M%S")"

    local zap_report_dir="$HOME/zap_reports"
    mkdir -p "$zap_report_dir"

    local zap_output_file="$zap_report_dir/zap_output_${timestamp}.txt"
    local zap_html_report="$zap_report_dir/zap_report_${timestamp}.html"
    local zap_json_report="$zap_report_dir/zap_report_${timestamp}.json"

    # Add a timeout so scans cannot hang forever
    timeout 15m /opt/zaproxy/zap.sh \
        -cmd \
        -quickurl "http://$ip:$port" \
        -quickout "$zap_html_report" \
        -addonupdate \
        -quickprogress \
        -jsonreport "$zap_json_report" \
        > "$zap_output_file" 2>&1 || log "WARN" "ZAP exited non-zero (check $zap_output_file)"

    log "INFO" "OWASP ZAP scan completed."
    log "INFO" "Console: $zap_output_file"
    log "INFO" "HTML:    $zap_html_report"
    log "INFO" "JSON:    $zap_json_report"

    # Optional: Feed results to summarizer/AI pipeline
    # summarize_zap_output "$zap_output_file"
}

# Function to run Wapiti
auto_wapiti() {
    if ! command -v wapiti >/dev/null 2>&1; then
        log "WARN" "Wapiti not installed; skipping."
        return 0
    fi
    log "INFO" "Running Wapiti..."
    local wapiti_output_file="$HOME/wapiti_scan_output.txt"
    wapiti -u "http://$ip:$port" | tee -a "$LOG_FILE" > "$wapiti_output_file"
    log "INFO" "Wapiti output saved to $wapiti_output_file"
    log "INFO" "Wapiti scan completed."
}

# Run automated scans
run_automated_scan() {
    while true; do
        read -r -p "Enter the target IP address: " ip
        if validate_ip "$ip"; then
            break
        else
            echo "Invalid IP address. Please enter a valid IPv4 address."
        fi
    done

    while true; do
        read -r -p "Enter the target port: " port
        if validate_port "$port"; then
            break
        else
            echo "Invalid port number. Please enter a number between 1 and 65535."
        fi
    done

    log "INFO" "Starting automated scans for IP: $ip and Port: $port"

    auto_nmap
    auto_nikto
    auto_zap
    auto_wapiti

    # (AI insight calls left as-is, still commented)
    # echo "y" | generate_ai_insights "$nmap_ai_output"
    # echo "y" | generate_ai_insights "$nikto_ai_output"
    # echo "y" | generate_ai_insights "$zap_ai_output"
    # echo "y" | generate_ai_insights "$wapiti_ai_output"
}

# Keep behaviour consistent with your current file:
# run_automated_scan

