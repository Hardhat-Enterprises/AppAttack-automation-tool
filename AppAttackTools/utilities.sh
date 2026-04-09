#!/bin/bash
# utilities.sh — shared utility functions for the AppAttack toolkit.
# Colours, LOG_FILE, and API key validation are provided by config.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ---------------------------------------------------------------------------
# Gemini JSON prompt builder
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Install jq if missing (required by generate_ai_insights)
# ---------------------------------------------------------------------------
install_generate_ai_insights_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo -e "${MAGENTA}Installing generate AI insights dependencies...${NC}"
        sudo apt-get update
        sudo apt-get install -y jq
    else
        echo -e "${GREEN}Generate AI insights dependencies are already installed.${NC}"
    fi
}

# ---------------------------------------------------------------------------
# Save tool output to a per-tool vulnerability file
# ---------------------------------------------------------------------------
save_vulnerabilities() {
    local tool=$1
    local output_file="$tool-vulnerabilities.txt"

    case $tool in
        "osv-scanner") osv-scanner scan "./$directory" > "$output_file" ;;
        "snyk")        snyk code scan > "$output_file" ;;
        "brakeman")    sudo brakeman --force > "$output_file" ;;
        "nmap")        nmap -v -A "$url" > "$output_file" ;;
        "nikto")       nikto -h "$url" > "$output_file" ;;
        "legion")      legion "$url" > "$output_file" ;;
        "john")        run_john "$OUTPUT_DIR" ;;
        "sqlmap")      sqlmap -u "$url" --batch --output-dir="$output_dir" > "$output_file" ;;
        "metasploit")  msfconsole -x "use auxiliary/scanner/portscan/tcp; set RHOSTS $url; run; exit" > "$output_file" ;;
        "wapiti")      wapiti -u "$url" -o "$output_file" ;;
        *)
            echo -e "${RED}Unsupported tool: $tool${NC}"
            return 1
            ;;
    esac

    echo -e "${GREEN}Vulnerabilities found:${NC}"
    redact_sensitive() { sed -E 's/(password|api[_-]?key|secret)[^\n]*/[REDACTED]/gi' "$1"; }
    redact_sensitive "$output_file"

    read -p "Do you want to save the vulnerabilities to a file? (y/n) " save_to_file
    if [[ "$save_to_file" == "y" ]]; then
        echo -e "${GREEN}Vulnerabilities saved to $output_file${NC}"
    else
        echo -e "${GREEN}Vulnerabilities not saved to a file.${NC}"
    fi
}

# ---------------------------------------------------------------------------
# AI-generated insights (Gemini cloud or local Ollama)
# ---------------------------------------------------------------------------
generate_ai_insights() {
    local output="$1"
    local output_to_file="$2"
    local output_file="$3"
    local tool="${4:-}"

    while true; do
        read -r -p "Do you want to get AI-generated insights on the scan? (y/n): " ai_insights
        case "$ai_insights" in
            [Yy]) break ;;
            [Nn]) echo "Skipping AI-generated insights."; return 0 ;;
            *)    echo "Please answer 'y' or 'n'." ;;
        esac
    done

    local API_KEY="$GEMINI_API_KEY"
    local escaped_output
    escaped_output=$(echo "$output" | sed 's/"/\\"/g' | sed "s/'/\\'/g")
    tool=$(echo "$tool" | tr '[:upper:]' '[:lower:]')

    local PROMPT
    case $tool in
        "nmap")        PROMPT="Analyze the Nmap scan results below. Identify open ports, services, and potential security vulnerabilities. Provide mitigation strategies for each risk.\n$escaped_output" ;;
        "nikto")       PROMPT="Analyze the Nikto scan output and summarize the identified security vulnerabilities. Suggest remediation steps based on best security practices for web servers.\n$escaped_output" ;;
        "zap")         PROMPT="Review the OWASP ZAP scan results. Highlight major security vulnerabilities (such as XSS, SQL Injection, CSRF) and provide actionable steps to mitigate them.\n$escaped_output" ;;
        "john")        PROMPT="Analyze the password hashes and cracking results from John the Ripper. Identify weak passwords and suggest best practices for improving password security.\n$escaped_output" ;;
        "sqlmap")      PROMPT="Analyze the SQLMap scan results. Identify SQL injection risks and suggest parameterized queries or WAF configurations to prevent exploitation.\n$escaped_output" ;;
        "metasploit")  PROMPT="Review the Metasploit session logs. Identify exploited vulnerabilities and suggest hardening measures to prevent similar attacks.\n$escaped_output" ;;
        "wapiti")      PROMPT="Analyze the Wapiti scan output. Identify critical vulnerabilities and recommend security best practices to mitigate risks in web applications.\n$escaped_output" ;;
        "aircrack-ng") PROMPT="This is the output from Aircrack-ng. Identify any discovered weak keys, cracked passwords, or insecure wireless configurations. Recommend how to secure the affected wireless network:\n$escaped_output" ;;
        "binwalk")     PROMPT="This is the output from Binwalk. Review the extracted segments and embedded files. Point out any indicators of outdated libraries, hardcoded credentials, or known vulnerabilities in firmware components:\n$escaped_output" ;;
        "wireshark")   PROMPT="Below is packet capture output from Wireshark. Identify any sensitive data transmitted in cleartext, insecure protocols (like Telnet/HTTP), or device fingerprinting attempts. Recommend security improvements for IoT communication:\n$escaped_output" ;;
        "hashcat")     PROMPT="This is output from Hashcat. Analyze cracked hashes and provide insights into weak password patterns, reuse, or policy violations. Suggest stronger password practices:\n$escaped_output" ;;
        "miranda")     PROMPT="This is output from Miranda. Review the log for signs of firmware misbehavior, unhandled input, or potential attack vectors via USB fuzzing:\n$escaped_output" ;;
        "ncrack")      PROMPT="This scan result is from Ncrack. Identify services with weak or exposed credentials and provide recommendations to harden authentication mechanisms:\n$escaped_output" ;;
        "umap")        PROMPT="This is output from Umap. Analyze the topology and device relationships to identify exposed services, insecure device placement, or unusual traffic paths:\n$escaped_output" ;;
        "wifiphisher") PROMPT="This scan is from Wifiphisher. Review the captured interactions and identify potential user deception strategies or social engineering weaknesses:\n$escaped_output" ;;
        "osv-scanner") PROMPT="Act as a cybersecurity expert and Analyze the results from OSV-Scanner. List all identified open-source software vulnerabilities along with CVEs in the order of criticality with score. Suggest remediation steps or dependency upgrades for each identified vulnerabilities:\n$escaped_output" ;;
        "snyk")        PROMPT="This is output from the Snyk CLI. Summarize the security issues found in the code or dependencies. Highlight the severity, affected packages, and offer remediation strategies such as patches, upgrades, or coding changes:\n$escaped_output" ;;
        "brakeman")    PROMPT="Act as a cybersecurity expert and analyze this scan report from Brakeman. Identify major vulnerabilities such as SQL injection, command injection, or mass assignment issues. Suggest how to mitigate them following secure Rails practices under each identified issue:\n$escaped_output" ;;
        "bandit")      PROMPT="Act as a cybersecurity expert and analyze the Python security linter output from Bandit. Describe the detected code issues and their severity and recommend secure coding alternatives for dangerous function calls or insecure patterns under each identified issue:\n$escaped_output" ;;
        "sonarqube")   PROMPT="This is a code quality and security scan output from SonarQube. Identify major security hotspots or code smells. Explain the impact of critical issues and suggest secure coding improvements:\n$escaped_output" ;;
        *)             PROMPT="Analyze the security scan results and provide insights.\n$escaped_output" ;;
    esac

    if [ -n "${GEMINI_API_KEY:-}" ]; then
        while true; do
            echo "Choose LLM mode:"
            echo "  1) Local LLM (Ollama)"
            echo "  2) Cloud LLM (Gemini)"
            read -r -p "Enter 1 or 2: " choice
            case "$choice" in
                1)
                    python3 -u "$AA_INSTALL_DIR/ollama_integration.py" --prompt "$PROMPT"
                    break
                    ;;
                2)
                    local INSIGHTS
                    INSIGHTS="$(curl -s -X POST \
                        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY" \
                        -H "Content-Type: application/json" \
                        -d '{
                          "contents": [{"parts": [{"text": "'"$PROMPT"'"}]}]
                        }')"
                    echo -e "\n+-----------------------------+"
                    echo -e "|          Insights           |"
                    echo -e "+-----------------------------+"
                    echo -e "$INSIGHTS"
                    echo -e "+-----------------------------+"
                    if [[ "$output_to_file" == "y" ]]; then
                        echo -e "\nAI-Generated Insights:\n$INSIGHTS" | sudo tee -a "$output_file" > /dev/null
                    fi
                    break
                    ;;
                *) echo "Invalid choice — please enter 1 or 2." ;;
            esac
        done
    else
        python3 -u "$AA_INSTALL_DIR/ollama_integration.py" --prompt "$PROMPT"
    fi
}
