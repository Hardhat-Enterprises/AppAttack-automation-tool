#!/bin/bash
# =============================================================================
# workflow.sh — Workflow builder, execution engine, storage, and tool selector
#
# Replaces: workflow_builder.sh, workflow_engine.sh,
#           workflow_storage.sh, tool_selector.sh
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, etc.) ===
source "$SCRIPT_DIR/config.sh"

# =============================================================================
# SECTION 1 — TOOL SELECTOR
# Lets the user pick tools from the plugins directory to build a workflow step.
# =============================================================================

create_new_workflow() {
    echo -e "${YELLOW}Creating a new workflow...${NC}"

    local tools_dir="$SCRIPT_DIR/plugins"
    local tools=( $(ls "$tools_dir" | grep '\.sh$' | sed 's/\.sh$//') )
    local workflow=()
    local workflow_outputs=()

    while true; do
        echo -e "\n${BYellow}Select a tool to add to the workflow:${NC}"
        for i in "${!tools[@]}"; do
            echo -e "${BCyan}$((i+1)))${NC} ${White}${tools[$i]}${NC}"
        done
        echo -e "${BCyan}0)${NC} ${White}Done${NC}"

        read -p "Choose an option: " choice

        if [[ "$choice" -eq 0 ]]; then
            break
        elif [[ "$choice" -gt 0 && "$choice" -le "${#tools[@]}" ]]; then
            local selected_tool="${tools[$((choice-1))]}"
            echo -e "${GREEN}Selected tool: $selected_tool${NC}"

            read -p "Enter the arguments for $selected_tool (use {{tool_name.output.field}} for placeholders): " args

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
        [[ "$execute_choice" == "y" ]] && execute_workflow "${workflow[@]}"

        read -p "Save this workflow? (y/n): " save_choice
        [[ "$save_choice" == "y" ]] && save_workflow "${workflow[@]}"
    else
        echo -e "${YELLOW}No tools selected. Workflow creation cancelled.${NC}"
    fi
}

# =============================================================================
# SECTION 2 — WORKFLOW ENGINE
# Executes a workflow array, resolving {{placeholder}} references between steps.
# =============================================================================

execute_workflow() {
    echo -e "${YELLOW}Executing workflow...${NC}"

    local workflow=("$@")
    local workflow_outputs=()

    for i in "${!workflow[@]}"; do
        local step="${workflow[$i]}"
        echo -e "\n${BYellow}Executing step: $step${NC}"

        # Resolve {{tool_name.output.field}} placeholders
        local resolved_step="$step"
        while [[ $resolved_step == *"{{"* ]]; do
            local placeholder
            placeholder=$(echo "$resolved_step" | grep -oE '\{\{[a-zA-Z0-9_.-]+\}\}' | head -n 1)
            [[ -z "$placeholder" ]] && break

            local query tool_name field_name
            query=$(echo "$placeholder" | sed 's/[{}]//g')
            tool_name=$(echo "$query" | cut -d'.' -f1)
            field_name=$(echo "$query" | cut -d'.' -f3-)

            # Find the prior output for this tool
            local tool_output=""
            for j in "${!workflow[@]}"; do
                local prev_tool_name
                prev_tool_name=$(echo "${workflow[$j]}" | cut -d' ' -f1)
                if [[ "$prev_tool_name" == "$tool_name" ]]; then
                    tool_output="${workflow_outputs[$j]}"
                    break
                fi
            done

            if [[ -z "$tool_output" ]]; then
                echo -e "${RED}Error: No output found for tool '$tool_name'. Aborting.${NC}"
                return 1
            fi

            local value
            value=$("$SCRIPT_DIR/json_parser.sh" "$tool_output" ".$field_name")

            if [[ -z "$value" ]]; then
                echo -e "${RED}Error: Could not extract field '$field_name' from '$tool_name' output. Aborting.${NC}"
                return 1
            fi

            resolved_step=$(echo "$resolved_step" | sed "s|$placeholder|$value|")
        done

        # Run the step
        local output
        output=$(eval "$SCRIPT_DIR/plugins/$resolved_step")
        if [[ $? -ne 0 ]]; then
            echo -e "${RED}Step failed. Aborting workflow.${NC}"
            return 1
        fi

        workflow_outputs+=("$output")
    done

    echo -e "\n${GREEN}Workflow executed successfully.${NC}"
}

# =============================================================================
# SECTION 3 — WORKFLOW STORAGE
# Save and load named workflows to/from the workflows/ directory.
# =============================================================================

save_workflow() {
    echo -e "${YELLOW}Saving workflow...${NC}"

    read -p "Enter a filename for the workflow (e.g., my_workflow): " filename
    if [[ -z "$filename" ]]; then
        echo -e "${RED}Filename cannot be empty. Workflow not saved.${NC}"
        return
    fi

    local workflows_dir="$SCRIPT_DIR/workflows"
    mkdir -p "$workflows_dir"

    local workflow_path="$workflows_dir/$filename"
    : > "$workflow_path"
    for step in "$@"; do
        echo "$step" >> "$workflow_path"
    done

    echo -e "${GREEN}Workflow saved to $workflow_path${NC}"
}

load_workflow() {
    echo -e "${YELLOW}Loading a workflow...${NC}"

    local workflows_dir="$SCRIPT_DIR/workflows"

    if [[ ! -d "$workflows_dir" ]] || [[ -z "$(ls -A "$workflows_dir")" ]]; then
        echo -e "${RED}No saved workflows found.${NC}"
        return
    fi

    local workflows=( $(ls "$workflows_dir") )

    echo -e "\n${BYellow}Select a workflow to load:${NC}"
    for i in "${!workflows[@]}"; do
        echo -e "${BCyan}$((i+1)))${NC} ${White}${workflows[$i]}${NC}"
    done
    echo -e "${BCyan}0)${NC} ${White}Cancel${NC}"

    read -p "Choose an option: " choice

    if [[ "$choice" -eq 0 ]]; then
        return
    elif [[ "$choice" -gt 0 && "$choice" -le "${#workflows[@]}" ]]; then
        local selected_workflow="${workflows[$((choice-1))]}"
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

# =============================================================================
# SECTION 4 — WORKFLOW BUILDER MENU
# Top-level menu wiring everything together.
# =============================================================================

display_workflow_builder_menu() {
    echo -e "\n${BYellow}╔════════════════════════════════╗${NC}"
    echo -e "${BYellow}║       Workflow Builder         ║${NC}"
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
            1) create_new_workflow ;;
            2) load_workflow ;;
            0) break ;;
            *) echo -e "${RED}Invalid choice, please try again.${NC}" ;;
        esac
    done
}
