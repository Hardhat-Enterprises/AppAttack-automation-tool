#!/bin/bash

# Colours
source "colours.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/tool_selector.sh"
source "$SCRIPT_DIR/workflow_engine.sh"
source "$SCRIPT_DIR/workflow_storage.sh"

display_workflow_builder_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════╗${NC}"
    echo -e "${BYellow}║      Workflow Builder        ║${NC}"
    echo -e "${BYellow}╚════════════════════════════════╝${NC}"
    echo -e "${BCyan}1)${NC} ${White}Create a new workflow${NC}"
    echo -e "${BCyan}2)${NC} ${White}Load a workflow${NC}"
    echo -e "${BCyan}0)${NC} ${White}Go Back${NC}"
    echo -e "${BYellow}╚════════════════════════════════╝${NC}"
}

handle_workflow_builder() {
    local choice
    while true; do
        display_workflow_builder_menu
        read -p "Choose an option: " choice
        case $choice in
            1) create_new_workflow ;; # To be implemented in tool_selector.sh
            2) load_workflow ;; # To be implemented in workflow_storage.sh
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;; 
        esac
    done
}

handle_workflow_builder
