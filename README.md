# AppAttack Toolkit
A comprehensive suite of security and network testing tools in a user-friendly interface.



## Table of Contents
1. [Installation (Users)](#installation-users)
2. [Development (Devs)](#development-devs)
3. [Usage](#usage)
4. [Available Tools](#available-tools)



## Installation (Users)
Follow these steps to install and launch the toolkit:

1. Clone the repository:
   ```bash
   git clone -b Tool-Development https://github.com/Hardhat-Enterprises/AppAttack.git
   ```
2. Enter the tools directory:
   ```bash
   cd AppAttack/appAttack_tools
   ```
3. Make the installer executable:
   ```bash
   chmod +x install.sh
   ```
4. Run the installer:
   ```bash
   sudo ./install.sh
   ```
5. Launch the toolkit:
   ```bash
   appAttack_toolkit
   ```



## Development (Devs)
Streamline testing and installation when adding or updating features:

- Ensure the main script is executable:
  ```bash
  chmod +x main.sh
  ```
- Quick test without reinstall:
  ```bash
  ./main.sh
  ```
- Full reinstall to validate the installer:
  1. Remove previous install:
     ```bash
     sudo rm -rf /opt/appAttack_toolkit
     sudo rm /usr/local/bin/appAttack_toolkit
     ```
  2. Re-run the installer:
     ```bash
     sudo ./install.sh
     ```


## Usage
1. Start the toolkit:
   ```bash
   appAttack_toolkit
   ```
2. The script checks for and downloads dependencies.
3. When prompted, choose to update (y) or skip (n).
4. Select the desired tool from the menu.
5. Provide the path to the target directory or network.
6. View the results in the output file (e.g., `~/appAttack_results.txt`).


## Available Tools
- **osv-scanner**: Scan dependencies against the Open Source Vulnerability DB.
- **Snyk**: Find and fix vulnerabilities in code, dependencies, containers, and IaC.
- **Brakeman**: Static analysis for Ruby on Rails security issues.
- **Nmap**: Host discovery, port scanning, and network auditing.
- **Nikto**: Web server scanner for vulnerabilities and misconfigurations.
- **OWASP ZAP**: Automated web app security testing.
- **Aircrack-ng**: WEP/WPA PSK cracking and packet replay attacks.
- **Bettercap**: Wi-Fi, BLE, HID, and Ethernet reconnaissance.
- **Binwalk**: Firmware analysis and extraction.
- **Hashcat**: High-performance password recovery.
- **Miranda**: UPnP device attack framework.
- **Ncrack**: Network authentication cracking.
- **Reaver**: Brute-force WPS PIN attacks.
- **Scapy**: Packet crafting, decoding, and forging.
- **Umap**: WAN-based UPnP exploitation.
- **Wifiphisher**: Rogue AP framework for MiTM attacks.
- **Wireshark**: Network packet capture and analysis.



*For further assistance or to contribute, please open an issue or pull request.*
