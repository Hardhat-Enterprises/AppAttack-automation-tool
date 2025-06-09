#!/bin/bash
# Load .env from fixed path
ENV_PATH="/opt/appAttack_toolkit/.env"
if [ -f "$ENV_PATH" ]; then
    set -a
    source "$ENV_PATH"
    set +a
else
    echo "Error: .env file not found at $ENV_PATH"
    exit 1
fi

# Check if GEMINI_API_KEY is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "Error: GEMINI_API_KEY is not set. Please check your .env file."
    exit 1
fi

# Define the log file path where the script logs messages
LOG_FILE="$HOME/security_tools.log"

# Function to generate structured Gemini JSON prompt
generate_gemini_prompt() {
    local tool_name="$1"
    local description="$2"
    local scan_output="$3"

    cat <<EOF
{
    "contents": [
        {
            "parts": [
                {
                    "text": "Tool Used: $tool_name\nDescription: $description\nScan Results:\n$scan_output"
                }
            ]
        }
    ]
}
EOF
}


install_generate_ai_insights_dependencies() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo -e "${MAGENTA}Installing generate AI insights dependencies...${NC}"
        
        # Update package list and install jq
        sudo apt-get update
        sudo apt-get install -y jq
    else
        echo -e "${GREEN}Generate AI insights dependencies are already installed.${NC}"
    fi
}

# Function to save vulnerabilities found by various tools to a file
save_vulnerabilities() {
    # Set the tool name to the first argument
    local tool=$1
    # Set the output file name based on the tool name
    local output_file="$tool-vulnerabilities.txt"
    # Determine the command to run based on the tool name
    case $tool in
        "osv-scanner")
            # Scan the directory using osv-scanner and save output to the file
            osv-scanner scan "./$directory" > "$output_file"
        ;;
        "snyk")
            # Run snyk code scan and save output to the file
            snyk code scan > "$output_file"
        ;;
        "brakeman")
            # Run brakeman scan and save output to the file
            sudo brakeman --force > "$output_file"
        ;;
        "nmap")
            # Run nmap scan and save output to the file
            nmap -v -A "$url" > "$output_file"
        ;;
        "nikto")
            # Run nikto scan and save output to the file
            nikto -h "$url" > "$output_file"
        ;;
        "legion")
            # Run legion scan and save output to the file
            legion "$url" > "$output_file"
        ;;
        "john")
            # Run John the Ripper and save output to the file
            run_john "$OUTPUT_DIR"
        ;;
        "sqlmap")
            # Run SQLmap scan and save output to the file
            sqlmap -u "$url" --batch --output-dir="$output_dir" > "$output_file"
        ;;
        "metasploit")
            # Run Metasploit scan and save output to the file
            msfconsole -x "use auxiliary/scanner/portscan/tcp; set RHOSTS $url; run; exit" > "$output_file"
        ;;
	"wapiti")
            # Run Wapiti scan and save output to the file
            wapiti -u "$url" -o "$output_file"
        ;;
        *)
            echo -e "${RED}Unsupported tool: $tool${NC}"
            return 1
        ;;
    esac

    # Display the found vulnerabilities
    echo -e "${GREEN}Vulnerabilities found:${NC}"
    cat "$output_file"
    # Prompt user to save the vulnerabilities to a file
    read -p "Do you want to save the vulnerabilities to a file? (y/n) " save_to_file
    if [[ "$save_to_file" == "y" ]]; then
        # Display message indicating the file has been saved
        echo -e "${GREEN}Vulnerabilities saved to $output_file${NC}"
    else
        # Display message indicating the file was not saved
        echo -e "${GREEN}Vulnerabilities not saved to a file.${NC}"
    fi
}

# Function to get and print AI-generated insights based on tool outputs
generate_ai_insights() {
    local output="$1"  # Tool output
    local output_to_file="$2"  # Output to file (either y or n)
    local output_file="$3"  # Output file directory
    local tool="$4"  # Name of the tool used

    read -p "Do you want to get AI-generated insights on the scan? (y/n): " ai_insights

    if [[ "$ai_insights" == "y" ]]; then
        API_KEY="$GEMINI_API_KEY"
        tool_parser="parsers/${tool}_parser.py"
        if [[ -f "$tool_parser" ]]; then
            PYTHON_RESPONSE=$(python3 "$tool_parser" "$output_file")
            PROMPT=$(echo "$PYTHON_RESPONSE" | jq -r '.prompt')
        else
        # Fallback to raw output if parser not found
            escaped_output=$(echo "$output" | sed 's/"/\\"/g')
            PROMPT="Analyze this output and provide insights: $escaped_output"
        fi


        # Escape scan output
        escaped_output=$(echo "$output" | sed 's/"/\\"/g' | sed "s/'/\\'/g")

        # Normalize tool name to lowercase
        tool=$(echo "$tool" | tr '[:upper:]' '[:lower:]')

        # Define structured prompts based on the tool used
        case $tool in
            #Pen testing prompts
            "nmap")
                PROMPT="Analyze the Nmap scan results below. Identify open ports, services, and potential security vulnerabilities. Provide mitigation strategies for each risk.\n$escaped_output"
                ;;
            "nikto")
                PROMPT="Analyze the Nikto scan output and summarize the identified security vulnerabilities. Suggest remediation steps based on best security practices for web servers.\n$escaped_output"
                ;;
            "zap")
                PROMPT="Review the OWASP ZAP scan results. Highlight major security vulnerabilities (such as XSS, SQL Injection, CSRF) and provide actionable steps to mitigate them.\n$escaped_output"
                ;;
            "john")
                PROMPT="Analyze the password hashes and cracking results from John the Ripper. Identify weak passwords and suggest best practices for improving password security.\n$escaped_output"
                ;;
            "sqlmap")
                PROMPT="Analyze the SQLMap scan results. Identify SQL injection risks and suggest parameterized queries or WAF configurations to prevent exploitation.\n$escaped_output"
                ;;
            "metasploit")
                PROMPT="Review the Metasploit session logs. Identify exploited vulnerabilities and suggest hardening measures to prevent similar attacks.\n$escaped_output"
                ;;
            "wapiti")
                PROMPT="Analyze the Wapiti scan output. Identify critical vulnerabilities and recommend security best practices to mitigate risks in web applications.\n$escaped_output"
                ;;
            #IoT prompts
            "aircrack-ng")
                PROMPT="This is the output from Aircrack-ng, a tool used to analyze and crack wireless network encryption (WEP/WPA/WPA2). Identify any discovered weak keys, cracked passwords, or insecure wireless configurations. Recommend how to secure the affected wireless network:\n$escaped_output"
                ;;
            "binwalk")
                PROMPT="This is the output from Binwalk, used for firmware analysis and reverse engineering. Review the extracted segments and embedded files. Point out any indicators of outdated libraries, hardcoded credentials, or known vulnerabilities in firmware components:\n$escaped_output"
                ;;
            "wireshark")
                PROMPT="Below is packet capture output from Wireshark, often used to analyze IoT device traffic. Identify any sensitive data transmitted in cleartext, insecure protocols (like Telnet/HTTP), or device fingerprinting attempts. Recommend security improvements for IoT communication:\n$escaped_output"
                ;;
            "hashcat")
                PROMPT="This is output from Hashcat, a high-performance password cracker. Analyze cracked hashes and provide insights into weak password patterns, reuse, or policy violations. Suggest stronger password practices:\n$escaped_output"
                ;;
            "miranda")
                PROMPT="This is output from Miranda, a tool for fuzzing USB and HID devices. Review the log for signs of firmware misbehavior, unhandled input, or potential attack vectors via USB fuzzing:\n$escaped_output"
                ;;
            "ncrack")
                PROMPT="This scan result is from Ncrack, used for brute-forcing network authentication. Identify services with weak or exposed credentials and provide recommendations to harden authentication mechanisms:\n$escaped_output"
                ;;
            "umap")
                PROMPT="This is output from Umap, a network visualization tool. Analyze the topology and device relationships to identify exposed services, insecure device placement, or unusual traffic paths:\n$escaped_output"
                ;;
            "wifiphisher")
                PROMPT="This scan is from Wifiphisher, a tool used to simulate Wi-Fi phishing attacks. Review the captured interactions and identify potential user deception strategies or social engineering weaknesses:\n$escaped_output"
                ;;
             #Secure Code Review Tools   
            "osv-scanner")
                PROMPT="Act as a cybersecurity expert and Analyze the results from OSV-Scanner. List all identified open-source software vulnerabilities along with CVEs in the order of criticality with score. Suggest remediation steps or dependency upgrades for each identified vulnerabilities:\n$escaped_output"
                ;;

            "snyk")
                PROMPT="This is output from the Snyk CLI. Summarize the security issues found in the code or dependencies. Highlight the severity, affected packages, and offer remediation strategies such as patches, upgrades, or coding changes:\n$escaped_output"
                ;;

            "brakeman")
                PROMPT="Act as a cybersecurity expert and analyze this scan report from Brakeman, a security tool for Ruby on Rails applications. Identify major vulnerabilities such as SQL injection, command injection, or mass assignment issues. Suggest how to mitigate them following secure Rails practices under each identified issue:\n$escaped_output"
                #Act as a cybersecurity expert and analyze this scan report from Brakeman, a security tool for Ruby on Rails applications. Identify major vulnerabilities such as SQL injection, command injection, or mass assignment issues. Suggest how to mitigate them following secure Rails practices under each identified issue
                ;;

            "bandit")
                PROMPT="Act as a cybersecurity expert analyze the  Python security linter output from Bandit. Describe the detected code issues and their severity and  recommend secure coding alternatives for dangerous function calls or insecure patterns under each identified issue:\n$escaped_output"
                #Act as a cybersecurity expert analyze the  Python security linter output from Bandit. Describe the detected code issues and their severity and  recommend secure coding alternatives for dangerous function calls or insecure patterns under each identified issue
                ;;

            "sonarqube")
                PROMPT="This is a code quality and security scan output from SonarQube. Identify major security hotspots or code smells. Explain the impact of critical issues and suggest secure coding improvements:\n$escaped_output"
                ;;    
                      
            *)
                PROMPT="Analyze the security scan results and provide insights.\n$escaped_output"
                ;;
        esac


        RESPONSE=$(curl -s -X POST  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "contents": [
              {
                "parts": [
                  {
                    "text": "'"$PROMPT"'"
                  }
                ]
              }
            ]
        }')
        
        INSIGHTS=$(echo $RESPONSE | jq -r '.candidates[0].content.parts[0].text')
        
        if [[ "$output_to_file" == "y" ]]; then
            echo -e "\nAI-Generated Insights:\n$INSIGHTS" | sudo tee -a "$output_file" > /dev/null
        else
            echo -e "\n+-----------------------------+"
            echo -e "|          Insights           |"
            echo -e "+-----------------------------+"
            echo -e "$INSIGHTS"
            echo -e "+-----------------------------+"
        fi
    fi
}
