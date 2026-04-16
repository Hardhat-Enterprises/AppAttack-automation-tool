#!/bin/bash
# Automated Reporting Plugin for AppAttack toolkit
# 
# WHAT THIS DOES:
# After you run security scans, this takes all the result files
# and bundles them into ONE webpage you can open in your browser.

# This is just the name of this tool
TOOL_NAME="AutomatedReporting"

# This is the main action that runs when you pick this plugin
run_plugin() {
    echo "[Automated Reporting Plugin] Aggregating scan outputs..."
    
    # Make a folder to store all reports (if it doesn't exist yet)
    # $HOME just means "your home folder"
    report_dir="$HOME/appattack_reports"
    mkdir -p "$report_dir"
    
    # Create a file name that includes the current date and time
    # Example: scan_report_20260116_143022.html
    # This way every report has a unique name and you won't overwrite old ones
    report_file="$report_dir/scan_report_$(date +%Y%m%d_%H%M%S).html"
    
    # Start building the webpage
    # The > symbol means "write this into the file" (start fresh)
    echo "<html><head><title>AppAttack Scan Report</title></head><body>" > "$report_file"
    echo "<h1>AppAttack Scan Report</h1>" >> "$report_file"  # >> means "add this to the end"
    
    # Look for all scan result files in your home folder
    # The * symbol is like a blank that can match anything
    for scan_file in "$HOME"/*_plugin_scan.txt "$HOME"/code_review_report.txt; do
        # Check if the file actually exists (if no files match, skip)
        if [[ -f "$scan_file" ]]; then
            # Add a heading with the file name, then the file's contents
            echo "<h2>$(basename "$scan_file")</h2><pre>" >> "$report_file"
            cat "$scan_file" >> "$report_file"  # Copy everything from the scan file
            echo "</pre>" >> "$report_file"      # Close this section
        fi
    done
    
    # Finish the webpage
    echo "</body></html>" >> "$report_file"
    
    # Tell the user where to find their report
    echo "Report generated: $report_file"
}

# This just shows a short description when someone asks for help
plugin_help() {
    echo "Aggregates scan outputs from plugins and generates a consolidated HTML report."
}
