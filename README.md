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


## Mobile Security
- **MobSF (Mobile Security Framework)**: An automated, all-in-one mobile application (Android/iOS/Windows) pen-testing, malware analysis and security assessment framework capable of performing static and dynamic analysis.

### Dynamic Analysis with Android Emulator and mitmproxy
This feature allows you to perform dynamic analysis of Android applications by running them in an Android Emulator and intercepting their traffic with mitmproxy.

1.  **Android Emulator**: An Android Virtual Device (AVD) is created to provide a virtual environment for running Android applications.
2.  **mitmproxy**: A free and open-source interactive HTTPS proxy that allows you to intercept, inspect, modify, and replay the network traffic of the application.

The toolkit automates the process of starting the emulator, configuring it to use mitmproxy, and installing the mitmproxy certificate.

## Time-Based Analysis and Delta Reporting
This feature allows you to track changes in your security posture over time.

### Timestamped Snapshots
Each scan is saved with a timestamp, creating a historical record of your scan results.

### Delta Reports
The delta report feature allows you to compare two scan reports and see the differences between them. This is useful for identifying new and fixed vulnerabilities.

### Trend Analysis
The trend analysis feature allows you to see how your security posture has changed over time. This is useful for identifying trends and patterns in your vulnerabilities.

## Automated Mobile Scan Workflow
This workflow automates the process of mobile application security testing by chaining together several tools:

1.  **Android Emulator**: Starts the Android Emulator.
2.  **APK Installation**: Installs the specified APK file on the emulator.
3.  **mitmproxy**: Starts mitmproxy to intercept and analyze network traffic.
4.  **MobSF**: Runs a static analysis scan on the APK file.
This workflow automates the process of web application footprinting by chaining together three powerful tools: subfinder, httpx, and nmap.

1.  **subfinder**: Discovers subdomains for the target domain.
2.  **httpx**: Probes the discovered subdomains to identify live hosts.
3.  **nmap**: Scans the live hosts to identify open ports and services.

The output of the workflow is saved in the `footprinting_logs` directory, with separate files for the subdomains, live hosts, and nmap scan results.
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
- **Gobuster**: Directory and DNS brute-forcing tool.



*For further assistance or to contribute, please open an issue or pull request.*
