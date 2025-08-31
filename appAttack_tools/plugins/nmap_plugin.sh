#!/bin/bash
# Nmap Scan Plugin for AppAttack toolkit
# Implements the plugin interface

TOOL_NAME="Nmap"

run_plugin() {
    echo "[Nmap Plugin] Enter target IP address:"
    read ip
    echo "[Nmap Plugin] Enter target port (or leave blank for all ports):"
    read port
    output_file="$HOME/nmap_plugin_scan.txt"
    if [[ -z "$port" ]]; then
        nmap_output=$(nmap "$ip")
    else
        nmap_output=$(nmap -p "$port" "$ip")
    fi
    echo "$nmap_output" > "$output_file"
    echo "Nmap scan completed. Output saved to $output_file"
    # Optionally call parser and AI insights here
    # python3 ../parsers/nmap_parser.py "$output_file"
}

plugin_help() {
    echo "Runs an Nmap scan on a target IP and port, saves results, and optionally parses output."
}
