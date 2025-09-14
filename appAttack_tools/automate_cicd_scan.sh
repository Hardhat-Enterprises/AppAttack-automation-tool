
# If CI env var is set, run both scans non-interactively and exit
if [[ "${CI:-}" == "true" ]]; then
  echo "[CI] Non-interactive mode: running Trivy + Gitleaks"
  trivy fs -q --format json -o trivy_output.json \
    --severity CRITICAL,HIGH --exit-code 0 .
  gitleaks detect --source . --report-format json --report-path gitleaks_output.json || true
  exit 0
fi

set -euo pipefail

# colors 
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color 

echo -e "${GREEN}[+] CI/CD Security Scan Menu${NC}"
echo "1) Run Trivy only"
echo "2) Run Gitleaks only"
echo "3) Run Both (Trivy + Gitleaks)"
echo "4) Exit"

read -p "Select an option [1-4]: " choice

case $choice in
  1)


#echo -e "${GREEN} [+] Starting CI/CD Security...${NC}"

#run trivy ( scans Docker imagae, repo, or filesystem) 

	echo "[*] Running Trivy..."
	trivy fs --quiet --format json --output trivy_output.json .
	echo -e "${GREEN}[+] Trivy scan done. Output: trivy_output.json${NC}"
	;;
   2)	
# run Gitleaks ( detects secrets) 

	echo "[*] Running Gitleaks..."
	gitleaks detect --source . --report-format json --report-path gitleaks_output.json
	echo -e "${GREEN}[+] Gitleaks scan done. Output: gitleaks_output.json${NC}"
	;;
   3) 
   	echo "[*] Running Trivy..."
   	trivy fs --quiet --format json --output trivy_output.json .
   	echo "[*] Running Gitleaks..."
   	gitleaks detect --source . --report-format json --report-path gitleaks_output.json
   	echo -e "${GREEN}[+] Both scans completed. Outputs: trivy_output.json & gitleaks_output.json${NC}"
   	;;
   4)
	echo "Exiting..."
	exit 0
	;;
      *)
      	echo -e "${RED}[!] Invalid option. Please run again.${NC}"
      	exit 1 
      	;;
esac
