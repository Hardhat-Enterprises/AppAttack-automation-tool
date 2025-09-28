#!/bin/bash

# Colours
source "colours.sh"

# Banner
echo -e "${CYAN}Starting API Reconnaissance Workflow...${NC}"

# Target details
read -p "Enter the target API endpoint (e.g., http://localhost:3000): " target
read -p "Enter the path to the API description document (e.g., /path/to/api.yaml): " api_description

# Log file
log_file="api_recon_$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "$log_file") 2>&1

echo -e "${GREEN}Logging output to $log_file${NC}"

# Dredd
echo -e "${YELLOW}Running Dredd...${NC}"
dredd "$api_description" "$target"
if [ $? -ne 0 ]; then
    echo -e "${RED}Dredd failed. Aborting.${NC}"
    exit 1
fi

# Nmap
echo -e "${YELLOW}Running Nmap...${NC}"
nmap -p- -sV "$target"
if [ $? -ne 0 ]; then
    echo -e "${RED}Nmap failed. Aborting.${NC}"
    exit 1
fi

# Nikto
echo -e "${YELLOW}Running Nikto...${NC}"
nikto -h "$target"
if [ $? -ne 0 ]; then
    echo -e "${RED}Nikto failed. Aborting.${NC}"
    exit 1
fi

echo -e "${GREEN}API Reconnaissance Workflow completed successfully.${NC}"
