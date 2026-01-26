#!/bin/bash

# Dynamically determine the directory of the script
if [[ -L "$0" ]]; then
    # If executed via a symlink, resolve to the installation directory
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
else
    # If running directly, use the source directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Source other scripts using absolute paths
source "$SCRIPT_DIR/colours.sh"
source "$SCRIPT_DIR/install_tools.sh"
source "$SCRIPT_DIR/update_tools.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"
source "$SCRIPT_DIR/menus.sh"
source "$SCRIPT_DIR/step_by_step.sh"

# Discover and load plugins from plugins directory
PLUGIN_DIR="$SCRIPT_DIR/plugins"
if [[ -d "$PLUGIN_DIR" ]]; then
    for plugin in "$PLUGIN_DIR"/*.sh; do
        source "$plugin"
        if declare -f run_plugin > /dev/null; then
            echo "Loaded plugin: $TOOL_NAME"
            PLUGIN_LIST+=("$TOOL_NAME")
        fi
    done
else
    echo "Plugin directory not found: $PLUGIN_DIR"
fi


# Main function to check and install tools
main() {
    
    # Initialize log file by clearing its contents
    echo "" > "$LOG_FILE"
   
    # Check for updates for the installed tools
    check_updates
    
    # Ask if the user wants to output results to a file (with input validation)
    while true; do
        read -p "Do you want to output results to a file? (y/n): " output_to_file
        case "$output_to_file" in
            [Yy])         
                read -p "Enter the output file path: " OUTPUT_DIR
                if [[ ! -d "$OUTPUT_DIR" ]]; then
                    mkdir -p "$OUTPUT_DIR"
                fi
                break ;;
            
            [Nn]) 
                break  ;;
            *)
                echo "Please answer 'y' or 'n'."
                ;;
        esac
    done

    #this was hard coded, i just made it dynamic for testing purposes
    #all it does is switch the user role based on their input (with input validation)
    while true; do
        read -r -p "input your user level (user/admin): " user_role
        user_role="${user_role,,}"   #lowercase input
        case "$user_role" in
            user) 
                USER_ROLE="guest"
                break
                ;;
            admin) 
                USER_ROLE="admin"
                break
                ;;
            *)
                echo "Please answer 'user' or 'admin'."
                ;;
        esac
    done
    
    while true; do
        display_banner
        display_main_menu
        read -p "Choose an option: " main_choice
        case $main_choice in
            1)
                if [[ "$USER_ROLE" != "admin" ]]; then
                    echo "Access denied."
                    log_message "Unauthorized access attempt"
                    continue
                fi
                handle_penetration_testing_tools "$OUTPUT_DIR" ;;
            2) handle_secure_code_review_tools "$OUTPUT_DIR" ;;
            3) handle_iot_security_tools "$OUTPUT_DIR" ;;
            4) handle_step_by_step_guide ;;
            5) handle_automated_processes_menu "$OUTPUT_DIR" ;;
            6) handle_container_security_tools "$OUTPUT_DIR"  ;;
            7) handle_cloud_security_tools "$OUTPUT_DIR"  ;;
            8) handle_mobile_security_tools "$OUTPUT_DIR" ;;
            0) echo -e "${YELLOW}Exiting...${NC}"
                log_message "Script ended"
            exit 0 ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}"
            log_message "Invalid user input" ;;
        esac
    done
}

export LOG_FILE="$HOME/appattack_toolkit.log"

# Execute main function to start the script
main
