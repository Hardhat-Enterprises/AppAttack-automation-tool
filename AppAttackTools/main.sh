#!/bin/bash

# Resolve SCRIPT_DIR whether run directly or via a symlink
if [[ -L "$0" ]]; then
    SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# === Centralised config FIRST (colours, banner, LOG_FILE, etc.) ===
source "$SCRIPT_DIR/config.sh"

# === Module sources ===
source "$SCRIPT_DIR/setup.sh"
source "$SCRIPT_DIR/run_tools.sh"
source "$SCRIPT_DIR/utilities.sh"
source "$SCRIPT_DIR/menus.sh"
source "$SCRIPT_DIR/step_by_step.sh"

# Discover and load plugins
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

# Main entry point
main() {
    # Initialise / clear the session log
    echo "" > "$LOG_FILE"

    check_updates

    # Output directory prompt
    while true; do
        read -p "Do you want to output results to a file? (y/n): " output_to_file
        case "$output_to_file" in
            [Yy])
                read -p "Enter the output file path: " OUTPUT_DIR
                [[ ! -d "$OUTPUT_DIR" ]] && mkdir -p "$OUTPUT_DIR"
                break ;;
            [Nn]) break ;;
            *)    echo "Please answer 'y' or 'n'." ;;
        esac
    done

    # User role prompt
    while true; do
        read -r -p "Input your user level (user/admin): " user_role
        user_role="${user_role,,}"
        case "$user_role" in
            user)  USER_ROLE="guest"; break ;;
            admin) USER_ROLE="admin"; break ;;
            *)     echo "Please answer 'user' or 'admin'." ;;
        esac
    done

    # Main menu loop
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
            6) handle_container_security_tools "$OUTPUT_DIR" ;;
            7) handle_cloud_security_tools "$OUTPUT_DIR" ;;
            8) handle_mobile_security_tools "$OUTPUT_DIR" ;;
            0)
                echo -e "${YELLOW}Exiting...${NC}"
                log_message "Script ended"
                exit 0 ;;
            *)
                echo -e "${RED}Invalid choice, please try again.${NC}"
                log_message "Invalid user input" ;;
        esac
    done
}

main
