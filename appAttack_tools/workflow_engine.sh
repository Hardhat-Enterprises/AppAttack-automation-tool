#!/bin/bash

# Colours
source "colours.sh"

execute_workflow() {
    echo -e "${YELLOW}Executing workflow...${NC}"

    local workflow=($@)
    local workflow_outputs=()

    for i in "${!workflow[@]}"; do
        local step=${workflow[$i]}
        echo -e "
${BYellow}Executing step: $step${NC}"

        # Resolve placeholders
        local resolved_step=$step
        while [[ $resolved_step == *"{{"* ]]; do
            local placeholder=$(echo "$resolved_step" | grep -oE '{{[a-zA-Z0-9_.-]+}}' | head -n 1)
            if [ -z "$placeholder" ]; then
                break
            fi

            local query=$(echo "$placeholder" | sed 's/{//g' | sed 's/}//g')
            local tool_name=$(echo "$query" | cut -d'.' -f1)
            local field_name=$(echo "$query" | cut -d'.' -f3-)

            # Find the output of the specified tool
            local tool_output=""
            for j in "${!workflow[@]}"; do
                local prev_tool_name=$(echo "${workflow[$j]}" | cut -d' ' -f1)
                if [[ "$prev_tool_name" == "$tool_name" ]]; then
                    tool_output=${workflow_outputs[$j]}
                    break
                fi
            done

            if [ -z "$tool_output" ]; then
                echo -e "${RED}Error: Could not find output for tool '$tool_name'. Aborting workflow.${NC}"
                return 1
            fi

            # Extract the value from the JSON output
            local value=$("./json_parser.sh" "$tool_output" ".$field_name")

            if [ -z "$value" ]; then
                echo -e "${RED}Error: Could not extract field '$field_name' from the output of tool '$tool_name'. Aborting workflow.${NC}"
                return 1
            fi

            # Replace the placeholder with the extracted value
            resolved_step=$(echo "$resolved_step" | sed "s|$placeholder|$value|")
        done

        # Execute the command
        local output=$(eval "$SCRIPT_DIR/plugins/$resolved_step")
        if [ $? -ne 0 ]; then
            echo -e "${RED}Step failed. Aborting workflow.${NC}"
            return 1
        fi

        workflow_outputs+=("$output")
    done

    echo -e "
${GREEN}Workflow executed successfully.${NC}"
}
