#!/bin/bash

#Define the log file location
LOG_FILE="$HOME/automated_scan.log"

> $LOG_FILE

# Function to validate IP address
validate_ip() {
    local ip="$1"
    # Check if the input matches the pattern for an IPv4 address
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # Check if each octet is between 0 and 255
        for octet in $(echo "$ip" | tr '.' ' '); do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Function to validate port
validate_port() {
    local port="$1"
    # Check if the port is a number between 1 and 65535
    if [[ $port =~ ^[0-9]+$ ]] && ((port >= 1 && port <= 65535)); then
        return 0
    else
        return 1
    fi
}

# Function to run Nmap
auto_nmap() {
    echo "Running Nmap..." >> $LOG_FILE
    nmap_output_file="$HOME/nmap_scan_output.txt"
    nmap_ai_output=$(nmap "$ip")
    echo "$nmap_ai_output" > "$nmap_output_file"
    echo "$nmap_ai_output" >> $LOG_FILE
    echo "Nmap scan completed." >> $LOG_FILE
}

# Function to run Nikto
auto_nikto() {
    echo "Running Nikto..." >>$LOG_FILE
    nikto_output_file="$HOME/nikto_scan_output.txt"
    nikto_ai_output=$(nikto -h "$ip:$port")
    echo "$nikto_ai_output" > "$nikto_output_file"
    echo "Nikto output saved to $nikto_output_file" >> $LOG_FILE
    echo "Nikto scan completed." >> $LOG_FILE
}

# Function to run OWASP ZAP automatically in headless mode
auto_zap() {
    echo "[*] Running OWASP ZAP..." | tee -a "$LOG_FILE"

    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")

    local zap_report_dir="$HOME/zap_reports"
    mkdir -p "$zap_report_dir"

    local zap_output_file="$zap_report_dir/zap_output_$timestamp.txt"
    local zap_html_report="$zap_report_dir/zap_report_$timestamp.html"
    local zap_json_report="$zap_report_dir/zap_report_$timestamp.json"

    # Run ZAP headless scan and export results
    /opt/zaproxy/zap.sh \
        -cmd \
        -quickurl "http://$ip:$port" \
        -quickout "$zap_html_report" \
        -addonupdate \
        -quickprogress \
        -jsonreport "$zap_json_report" \
        > "$zap_output_file" 2>&1

    echo "[+] OWASP ZAP scan completed." | tee -a "$LOG_FILE"
    echo "[+] Console output saved to $zap_output_file" | tee -a "$LOG_FILE"
    echo "[+] HTML report saved to $zap_html_report" | tee -a "$LOG_FILE"
    echo "[+] JSON report saved to $zap_json_report" | tee -a "$LOG_FILE"

    # Optional: Feed results to summarizer/AI pipeline
    # summarize_zap_output "$zap_output_file"
}



# Function to run Wapiti
auto_wapiti() {
    echo "Running Wapiti..." >> $LOG_FILE
    wapiti_output_file="$HOME/wapiti_scan_output.txt"
    wapiti_ai_output=$(wapiti -u "http://$ip:$port")
    echo "$wapiti_ai_output" > "$wapiti_output_file"
    echo "Wapiti output saved to $wapiti_output_file" >> $LOG_FILE
    echo "Wapiti scan completed." >> $LOG_FILE
}

# Run automated scans
run_automated_scan() {
    while true; do
        read -p "Enter the target IP address: " ip
        if validate_ip "$ip"; then
            break
        else
            echo "Invalid IP address. Please enter a valid IPv4 address."
        fi
    done

    while true; do
        read -p "Enter the target port: " port
        if validate_port "$port"; then
            break
        else
            echo "Invalid port number. Please enter a number between 1 and 65535."
        fi
    done

    echo "Starting automated scans for IP: $ip and Port: $port" >> $LOG_FILE

    auto_nmap
    auto_nikto
    auto_zap
    auto_wapiti

    ## Uncomment to get ai insights on each scan. ##
    #echo "y" | generate_ai_insights "$nmap_ai_output"
    #echo "y" | generate_ai_insights "$nikto_ai_output"

    ## Uncomment to run ai insights on zap and wapiti scans. Currently they don't work ##
    ## The argument size for curl is too large. Need to find a solution ##
    # echo "y" | generate_ai_insights "$zap_ai_output"
    # echo "y" | generate_ai_insights "$wapiti_ai_output"
}

#run_automated_scan
