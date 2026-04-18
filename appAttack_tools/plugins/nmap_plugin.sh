#!/bin/bash
# Nmap Scan Plugin for AppAttack toolkit

TOOL_NAME="Nmap"

# AppAttack expects two things from this file:
# 1) A variable called TOOL_NAME with the name of this tool.
# 2) A function called run_plugin that contains the main code.
TOOL_NAME="Nmap"

# This is the main function that runs when you select this plugin from the menu.
run_plugin() {

    # Check if the user forgot to type an IP address.
    # $1 means "the first thing they typed after the command".
    # -z means "is this empty?".
    if [ -z "$1" ]; then
        # Tell the user how to use this plugin correctly.
        echo "[Nmap Plugin] Usage: ./nmap_plugin.sh <ip> [port]"
        return 1  # Stop here and signal that something went wrong.
    fi

    # Save what the user typed into easy-to-remember names.
    ip=$1      # The first thing they typed (the target computer address).
    port=$2    # The second thing they typed (the specific door/port).

    # Run Nmap differently depending on whether they gave a port number which is like looking for open doors to a computer.
    if [[ -z "$port" ]]; then
        # No port given, scan the whole computer (all doors)
        nmap_output=$(nmap "$ip")
    else
        # Port given, only check that specific door
        nmap_output=$(nmap -p "$port" "$ip")
    fi


# Tells the user what this plugin does when they need help
plugin_help() {
    echo "Runs an Nmap scan on a target IP and port, and outputs the results in JSON format."
}

# If the script is called directly, run the plugin
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_plugin "$@"
fi
