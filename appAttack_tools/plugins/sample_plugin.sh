#!/bin/bash
# Plugin interface for AppAttack toolkit.

# WHAT THIS IS:
# This is a BLANK TEMPLATE for creating new plugins, if you want to create a new plugin use this file as a template.

# REQUIRED RULES:
# Every plugin MUST have:
# 1. A TOOL_NAME (what your tool is called).
# 2. A run_plugin function (what happens when someone picks your tool).

# OPTIONAL:
# You can also add a plugin_help function (shows a description of what the file does).

# ----------------------------------------------------------------------
# STEP 1: Give your plugin a name.
# Change "SamplePlugin" to whatever your tool is called.
# Example: TOOL_NAME="MyCoolScanner".
# ----------------------------------------------------------------------
TOOL_NAME="SamplePlugin"

# ----------------------------------------------------------------------
# STEP 2: Write the code of what your plugin actually DOES.
# This function runs when someone selects your plugin from the menu.
# Put your tool's commands between the { and the }.
# ----------------------------------------------------------------------
run_plugin() {
    echo "Running $TOOL_NAME plugin..."
    # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    # Delete this lines above and below and put YOUR tool's code here instead.
    # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
}

# ----------------------------------------------------------------------
# STEP 3 (Optional): Write a short description of your plugin
# This shows up when someone asks for help
# ----------------------------------------------------------------------
plugin_help() {
    echo "This is a sample plugin for AppAttack toolkit."
    # Change this to describe what YOUR tool actually does.
    # Example: echo "Scans a website for common security problems".
}
