#!/bin/bash
# Nmap Scan Plugin for AppAttack toolkit
# Implements the plugin interface

TOOL_NAME="Nmap"

run_plugin() {
    if [ -z "$1" ]; then
        echo "[Nmap Plugin] Usage: ./nmap_plugin.sh <ip> [port]"
        return 1
    fi

    ip=$1
    port=$2

    if [[ -z "$port" ]]; then
        nmap_output=$(nmap "$ip")
    else
        nmap_output=$(nmap -p "$port" "$ip")
    fi

    # Call the parser and print the JSON output
    python3 "$SCRIPT_DIR/../parsers/nmap_parser.py" "<(echo "$nmap_output")"
}

plugin_help() {
    echo "Runs an Nmap scan on a target IP and port, and outputs the results in JSON format."
}

# If the script is called directly, run the plugin
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_plugin "$@"
fi
