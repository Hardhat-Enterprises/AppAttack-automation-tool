# Function to install Snyk CLI (a vulnerability scanner) if not already installed
install_snyk_cli() {
    if ! command -v npm &> /dev/null; then
        install_npm
    fi
    if ! command -v snyk &> /dev/null; then
        echo -e "${CYAN}Installing snyk cli...${NC}"
        sudo npm install -g snyk
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Snyk cli installed successfully!${NC}"
            echo -e "${YELLOW}NOTE: To use Snyk, you need to authenticate manually later with:${NC}"
            echo -e "${YELLOW}      snyk auth${NC}"
            echo -e "${YELLOW}Skipping automatic authentication to avoid browser popup.${NC}"
            # Don't run snyk auth automatically - this was the blocker
        else
            echo -e "${RED}Failed to install snyk cli.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}snyk cli is already installed.${NC}"
    fi
}
