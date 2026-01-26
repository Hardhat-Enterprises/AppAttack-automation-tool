#!/bin/bash

# Colours
source "colours.sh"

load_workflow() {
    echo -e "${YELLOW}Loading a workflow...${NC}"

    local workflows_dir="$SCRIPT_DIR/workflows"
    local workflows=($(ls "$workflows_dir"))

    if [[ ${#workflows[@]} -eq 0 ]]; then
        echo -e "${RED}No saved workflows found.${NC}"
        return
    fi

    echo -e "\n${BYellow}Select a workflow to load:${NC}"
    for i in "${!workflows[@]}"; do
        echo -e "${BCyan}$((i+1)))${NC} ${White}${workflows[$i]}${NC}"
    done
    echo -e "${BCyan}0)${NC} ${White}Cancel${NC}"

    read -p "Choose an option: " choice

    if [[ "$choice" -eq 0 ]]; then
        return
    fi

    if [[ "$choice" -gt 0 && "$choice" -le "${#workflows[@]}" ]]; then
        local selected_workflow=${workflows[$((choice-1))]}
        local workflow_path="$workflows_dir/$selected_workflow"

        echo -e "${GREEN}Loading workflow: $selected_workflow${NC}"

        local workflow=()
        while IFS= read -r line; do
            workflow+=("$line")
        done < "$workflow_path"

        execute_workflow "${workflow[@]}"
    else
        echo -e "${RED}Invalid choice, please try again.${NC}"
    fi
}

save_workflow() {
    echo -e "${YELLOW}Saving a workflow...${NC}"

    read -p "Enter a filename for the workflow (e.g., my_workflow): " filename

    if [[ -z "$filename" ]]; then
        echo -e "${RED}Filename cannot be empty. Workflow not saved.${NC}"
        return
    fi

    local workflow_path="$SCRIPT_DIR/workflows/$filename"
    local workflow=("$@")

    echo "" > "$workflow_path"
    for step in "${workflow[@]}"; do
        echo "$step" >> "$workflow_path"
    done

    echo -e "${GREEN}Workflow saved to $workflow_path${NC}"
}
