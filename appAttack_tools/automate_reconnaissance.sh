#!/bin/bash

#source the run_tools.sh script to use its functions
source run_tools.sh
source utilities.sh


#Define the log file location
# LOG_FILE="$HOME/automated_scan.log"


# > $LOG_FILE

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

#validate url
validate_target_url() {
    local url="$1"
    #url must be either http or https and optionally has a www at the beginning 
    local regex="^https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}([-a-zA-Z0-9()@:%_+.~#?&/=]*)$"

    if [[ $url =~ $regex ]]; then       
        return 0
    else
        return 1
    fi
}


#extracts the hostname from a url
extract_host() {
    echo "$1" | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|:.*$||'
}

# Run automated scans
run_automated_scan() {

    if [[ "$output_to_file" == "n" ]]; then
        echo -e "you cannot access this functionality without outputting results to a folder or file"
        return 1
    fi

    #directory that will hold automated scan outputs
    timestamp=$(date +%F_%H-%M-%S)
    AUTOMATED_SCAN_OUTPUT_DIR="$OUTPUT_DIR/automated_scans/$timestamp"
    mkdir -p $AUTOMATED_SCAN_OUTPUT_DIR

    echo -e "Target selection"
    while true; do 
        read -p "Enter target URL or IP: " target
        if [[ "$target" =~ ^[0-9.]+$ ]]; then  #if target contains only numbers and full stops, assume it is an ip and validate it accordingly

            if validate_ip "$target"; then
                ip=$target
                url="http://$ip"
                break
            else 
                echo "Invalid IP address. Please enter a valid IPv4 address."
            fi
            
        else #else assume its url
            if validate_target_url "$target"; then
                url=$target
                ip=$(extract_host "$url")
                break
            else
                echo "Invalid url address. Please follow the format shown in example: http(s)://www.example.com"
            fi
        fi
    done


    echo -e "Automated scan outputs can be found at $AUTOMATED_SCAN_OUTPUT_DIR"


    #getting ai insights for each automated scan can be quite tedious and slows the automated pipeline
    echo -e "\n${GREEN}Starting owasp zap scan${NC}"
    run_owasp_zap_automated "$url" "$AUTOMATED_SCAN_OUTPUT_DIR" 
    # generate_ai_insights "$zap_ai_output" "$output_to_file" "$output_file" "$output_to_file" "$output_file"

    echo -e "\n${GREEN}Starting nikto scan, press space to see progress and estimated completion time${NC}"
    run_nikto_automated "$url" "$AUTOMATED_SCAN_OUTPUT_DIR" 
    # generate_ai_insights  "$nikto_ai_output" "$output_to_file" "$output_file"
    
    echo -e "\n${GREEN}Starting wapiti scan${NC}"
    run_wapiti_automated "$url" "$AUTOMATED_SCAN_OUTPUT_DIR" 
    # generate_ai_insights "$wapiti_ai_output"


    echo -e "\n${GREEN}Starting nmap scan${NC}"
    run_nmap_automated "$ip" "$AUTOMATED_SCAN_OUTPUT_DIR" 
    # generate_ai_insights "$nmap_ai_output" "$output_to_file" "$output_file" "nmap"

    echo -e "${GREEN}Reconnaissance automation completed ${NC}"

}

