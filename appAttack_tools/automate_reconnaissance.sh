#!/bin/bash

#source the run_tools.sh script to use its functions
source run_tools.sh
source utilities.sh
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

    run_nmap "$ip" >> $LOG_FILE
    echo "y" | generate_ai_insights "$nmap_ai_output"
    run_nikto "$ip" "$port" >> $LOG_FILE
    echo "y" | generate_ai_insights "$nikto_ai_output"
    run_owasp_zap "$ip" "$port" >> $LOG_FILE
    echo "y" | generate_ai_insights "$zap_ai_output"
    run_wapiti "$ip" "$port" >> $LOG_FILE
    echo "y" | generate_ai_insights "$wapiti_ai_output"
    echo "Reconnaissance automation completed." >> $LOG_FILE

    ## Uncomment to get ai insights on each scan. ##


    ## Uncomment to run ai insights on zap and wapiti scans. Currently they don't work ##
    ## The argument size for curl is too large. Need to find a solution ##

}

run_automated_scan
