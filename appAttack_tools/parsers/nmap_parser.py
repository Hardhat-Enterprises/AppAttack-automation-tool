import sys
import re
import json

# WHAT THIS FILE DOES:
# Takes Nmap's messy scan output, finds the computer name and all open ports, then creates a question for an AI to explain what those open doors mean and how to stay safe.


# FUNCTION #1: Pull out the important information from Nmap's output
def parse_nmap_output(text):
    """Scan through Nmap's output and grab the host name and all open ports"""
    
    ports = []      # This will hold all the open doors (ports) we find
    host = ""       # This will hold the computer's address that was scanned
    
    # Split the text into individual lines
    lines = text.splitlines()
    
    # Look at each line one by one
    for line in lines:
        
        # --- Find the computer address (host) ---
        # Nmap puts a line like "Nmap scan report for 192.168.1.1"
        if "Nmap scan report for" in line:
            # Grab everything after "for", that's the address
            # Example: "Nmap scan report for google.com" -> "google.com"
            host = line.split("for")[-1].strip()
        
        # --- Find the open ports (doors) ---
        # Nmap shows open ports in lines like "22/tcp open ssh"
        # This means: door #22 is open, and behind it runs a service called "ssh"
        match = re.match(r"^(\d+/tcp)\s+open\s+(\S+)", line)
        if match:
            port, service = match.groups()  # Get the port number and service name
            
            # Store this open door in our list
            ports.append({
                "port": port,      # Example: "22/tcp"
                "service": service # Example: "ssh"
            })
    
    # Package everything into a simple structure
    parsed = {
        "host": host,              # The computer that was scanned
        "open_ports": ports        # List of all open doors found
    }
    
    return parsed


# FUNCTION #2: Turn the findings into a question for an AI
def generate_prompt(data):
    """Create a prompt that asks an AI to explain the scan results"""
    
    host = data.get("host", "unknown")  # Get the computer address, or "unknown" if missing
    
    # Start building the prompt
    prompt = f"This is the result of a network scan for the device at {host}.\n\n"
    
    # Check if any open ports (doors) were found
    if not data["open_ports"]:
        # No open doors, good news.
        prompt += "No open doors (called ports) were found on this device. That's generally a good thing, it means there are fewer ways someone could try to connect without permission.\n"
    else:
        # Open doors were found, list them out
        prompt += "The scan found that the following doors (called ports) are open, which means someone could connect to them if they know how:\n\n"
        
        for p in data["open_ports"]:
            prompt += f"- Port {p['port']} is open and running a service called '{p['service']}'.\n"
        
        # Ask the AI to explain what this means and how to stay safe
        prompt += (
            "\nPlease explain what these open ports might mean in simple, non-technical language. "
            "Give examples of what could happen if they are not secured, and suggest beginner-friendly steps someone could take to make their system safer."
        )
    
    return prompt


# MAIN FUNCTION: Put it all together
if __name__ == "__main__":
    # Check if the user provided a file to read
    if len(sys.argv) < 2:
        print("Usage: python nmap_parser.py <nmap_output_file>")
        sys.exit(1)
    
    # Open and read the Nmap output file
    with open(sys.argv[1], "r") as f:
        content = f.read()
    
    # Step 1: Parse the messy output into organized data
    parsed_data = parse_nmap_output(content)
    
    # Step 2: Create a prompt asking the AI to explain the results
    prompt = generate_prompt(parsed_data)
    
    # Step 3: Print everything as JSON (organized data format)
    print(json.dumps({
        "prompt": prompt,           # The question to ask the AI
        "parsed_data": parsed_data  # The raw parsed data (for reference)
    }, indent=2))
