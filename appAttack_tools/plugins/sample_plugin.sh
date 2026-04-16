#!/bin/bash
# Plugin interface for AppAttack toolkit
# 
# WHAT THIS IS:
# This is a BLANK TEMPLATE for creating new plugins.
# Think of it like a form you fill out to add a new tool to AppAttack.
# 
# REQUIRED RULES:
# Every plugin MUST have:
# 1. A TOOL_NAME (what your tool is called)
# 2. A run_plugin function (what happens when someone picks your tool)
# 
# OPTIONAL:
# You can also add a plugin_help function (shows a description)

# ----------------------------------------------------------------------
# STEP 1: Give your plugin a name
# Change "SamplePlugin" to whatever your tool is called
# Example: TOOL_NAME="MyCoolScanner"
# ----------------------------------------------------------------------
TOOL_NAME="SamplePlugin"

# ----------------------------------------------------------------------
# STEP 2: Write what your plugin actually DOES
# This function runs when someone selects your plugin from the menu
# Put your tool's commands between the { and the }
# ----------------------------------------------------------------------
run_plugin() {
    echo "Running $TOOL_NAME plugin..."
    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    # TODO: Delete the line above and put YOUR tool's code here instead
    #
    # Examples of what you might put here:
    # - Run a security scanner:  nmap -sV 192.168.1.1
    # - Check a website:         curl https://example.com
    # - Run a Python script:     python3 my_scanner.py
    # - Analyze a file:          cat results.txt
    #
    # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}

# ----------------------------------------------------------------------
# STEP 3 (Optional): Write a short description of your plugin
# This shows up when someone asks for help
# ----------------------------------------------------------------------
plugin_help() {
    echo "This is a sample plugin for AppAttack toolkit."
    # TODO: Change this to describe what YOUR tool actually does
    # Example: echo "Scans a website for common security problems"
}
