#!/bin/bash
# Secure Code Review Plugin for AppAttack toolkit
# 
# WHAT THIS DOES:
# Checks your code for security problems using three different tools.
# Think of it as hiring three safety inspectors to look at your code.
# They each write a report, and this plugin combines them into one.

# This is just the name of this tool
TOOL_NAME="SecureCodeReview"

# This is the main action that runs when you pick this plugin
run_plugin() {
    echo "[Secure Code Review Plugin] Enter path to codebase for review:"
    
    # Ask the user where their code is stored
    # Example: /home/user/myapp  or  ./my_project_folder
    read codebase_path
    
    # Create a report file in the user's home folder
    output_file="$HOME/code_review_report.txt"
    
    # ----------------------------------------------------------------
    # INSPECTOR #1: Bandit (checks Python code)
    # ----------------------------------------------------------------
    echo "Running Bandit (Python)..."
    # -r means "look in all subfolders too"
    # 2>/dev/null means "hide error messages" (keeps the report clean)
    bandit_output=$(bandit -r "$codebase_path" 2>/dev/null)
    
    # Write Bandit's findings to the report file
    # The > symbol creates a brand new file (starts fresh)
    echo "--- Bandit Results ---" > "$output_file"
    echo "$bandit_output" >> "$output_file"  # >> adds to the file
    
    # ----------------------------------------------------------------
    # INSPECTOR #2: Brakeman (checks Ruby on Rails code)
    # ----------------------------------------------------------------
    echo "Running Brakeman (Ruby on Rails)..."
    brakeman_output=$(brakeman "$codebase_path" 2>/dev/null)
    
    # Add Brakeman's findings to the same report
    echo "--- Brakeman Results ---" >> "$output_file"
    echo "$brakeman_output" >> "$output_file"
    
    # ----------------------------------------------------------------
    # INSPECTOR #3: Snyk (checks for bad libraries/dependencies)
    # ----------------------------------------------------------------
    echo "Running Snyk (general)..."
    snyk_output=$(snyk test "$codebase_path" 2>/dev/null)
    
    # Add Snyk's findings to the same report
    echo "--- Snyk Results ---" >> "$output_file"
    echo "$snyk_output" >> "$output_file"
    
    # Tell the user where to find their report
    echo "Secure code review completed. Report saved to $output_file"
}

# This shows a short description when someone asks for help
plugin_help() {
    echo "Runs Bandit, Brakeman, and Snyk on a codebase, aggregates results, and saves a consolidated report."
}
