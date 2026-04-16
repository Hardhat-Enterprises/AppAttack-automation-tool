import sys
import re
import json

# --------------------------------------------------------------
# FUNCTION #1: Pull out the important information from Nikto's output
# --------------------------------------------------------------
def parse_nikto_output(text):
    """Scan through Nikto's output and grab the host name and all findings"""
    
    findings = []      # This will hold all the problems/observations
    host = ""          # This will hold the website address or IP
    
    # Split the text into individual lines
    lines = text.splitlines()
    
    # Look at each line one by one
    for line in lines:
        
        # --- Find the website address (host) ---
        # Nikto puts a line like "Target IP: 192.168.1.1" or "Target Host: example.com"
        if "Target IP:" in line or "Target Host:" in line:
            # Search for the actual address after the colon
            # Example: "Target IP: 192.168.1.1" -> grabs "192.168.1.1"
            host_match = re.search(r"(Target IP|Target Host):\s*(\S+)", line)
            if host_match:
                host = host_match.group(2)  # Store the address
        
        # --- Find the problems/findings ---
        # Nikto marks each finding with a "+" at the beginning of the line
        # Example: "+ The website has an outdated version of WordPress"
        elif line.strip().startswith("+"):
            # Remove the "+" and extra spaces, keep just the message
            finding = line.strip("+ ").strip()
            findings.append(finding)  # Add this finding to our list
    
    # Package everything into a simple structure
    parsed = {
        "host": host,          # The website that was scanned
        "findings": findings   # List of all problems found
    }
    return parsed

# --------------------------------------------------------------
# FUNCTION #2: Turn the findings into a question for an AI
# --------------------------------------------------------------
def generate_prompt(data):
    """Create a prompt that asks an AI to explain the scan results"""
    
    host = data.get("host", "unknown")  # Get the website address, or "unknown" if missing
    
    # Start building the prompt
    prompt = f"This is the result of a website vulnerability scan for the server at {host}.\n\n"
    
    # Check if any problems were found
    if not data["findings"]:
        # No problems found - say something positive but cautious
        prompt += "No obvious problems or vulnerabilities were found on this web server. That's a good sign, but it's always smart to keep systems updated and monitored.\n"
    else:
        # Problems were found - list them out
        prompt += "The scan found the following issues or observations:\n\n"
        
        for finding in data["findings"]:
            prompt += f"- {finding}\n"  # Add each finding as a bullet point
        
        # Ask the AI to explain everything in simple terms
        prompt += (
            "\nPlease explain these issues in plain, beginner-friendly language. "
            "Describe what each finding might mean, why it could matter, and simple steps a non-expert could take to improve security."
        )
    
    return prompt

# --------------------------------------------------------------
# MAIN FUNCTION: Put it all together
# --------------------------------------------------------------
if __name__ == "__main__":
    # Check if the user provided a file to read
    if len(sys.argv) < 2:
        print("Usage: python nikto_parser.py <nikto_output_file>")
        sys.exit(1)
    
    # Open and read the Nikto output file
    with open(sys.argv[1], "r") as f:
        content = f.read()
    
    # Step 1: Parse the messy output into organized data
    parsed_data = parse_nikto_output(content)
    
    # Step 2: Create a prompt asking the AI to explain the results
    prompt = generate_prompt(parsed_data)
    
    # Step 3: Print everything as JSON (organized data format)
    print(json.dumps({
        "prompt": prompt,           # The question to ask the AI
        "parsed_data": parsed_data  # The raw parsed data (for reference)
    }, indent=2))
