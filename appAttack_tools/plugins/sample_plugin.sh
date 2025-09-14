#!/bin/bash
# Plugin interface for AppAttack toolkit
# Each plugin must implement the run_plugin function and set TOOL_NAME

TOOL_NAME="SamplePlugin"

run_plugin() {
    echo "Running $TOOL_NAME plugin..."
    # Add tool-specific logic here
}

# Optionally, add metadata or help function
plugin_help() {
    echo "This is a sample plugin for AppAttack toolkit."
}
