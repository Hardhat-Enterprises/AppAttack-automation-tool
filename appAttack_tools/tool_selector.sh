#!/bin/bash

# Colours
source "colours.sh"

create_new_workflow() {
    echo -e "${YELLOW}Creating a new workflow...${NC}"

    # Get the list of available tools from the plugins directory
    local tools_dir="$SCRIPT_DIR/plugins"
    local tools=($(ls "$tools_dir" | grep '.sh
 | sed 's/.sh$//'))

    # The workflow definition
    local workflow=()
    local workflow_outputs=()

    while true; do
        echo -e "\n${BYellow}Select a tool to add to the workflow:${NC}"
        for i in "${!tools[@]}"; do
            echo -e "${BCyan}"$((i+1)))${NC} ${White}${tools[$i]}${NC}"
        done
        echo -e "${BCyan}0)${NC} ${White}Done${NC}"

        read -p "Choose an option: " choice

        if [[ "$choice" -eq 0 ]]; then
            break
        fi

        if [[ "$choice" -gt 0 && "$choice" -le "${#tools[@]}" ]]; then
            local selected_tool=${tools[$((choice-1))]}
            echo -e "${GREEN}Selected tool: $selected_tool${NC}"

            # Prompt for tool inputs
            read -p "Enter the arguments for $selected_tool (use {{tool_name.output.field}} for placeholders): " args

            # Add the tool and its arguments to the workflow
            workflow+=("$selected_tool $args")
            workflow_outputs+=("")
        else
            echo -e "${RED}Invalid choice, please try again.${NC}"
        fi
    done

    if [[ ${#workflow[@]} -gt 0 ]]; then
        echo -e "\n${BYellow}Workflow created:${NC}"
        for step in "${workflow[@]}"; do
            echo -e "${CYAN}- $step${NC}"
        done

        read -p "Execute this workflow? (y/n): " execute_choice
        if [[ "$execute_choice" == "y" ]]; then
            execute_workflow "${workflow[@]}"
        fi

        read -p "Save this workflow? (y/n): " save_choice
        if [[ "$save_choice" == "y" ]]; then
            save_workflow "${workflow[@]}"
        fi
    else
        echo -e "${YELLOW}No tools selected. Workflow creation cancelled.${NC}"
    fi
}
