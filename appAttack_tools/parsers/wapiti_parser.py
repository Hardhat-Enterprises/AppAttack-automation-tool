import sys
import re
import json

# WHAT THIS FILE DOES:
# Takes Wapiti's messy output (from scanning websites by trying to hack them), finds the target website and all vulnerabilities found,
# then creates a question for an AI to explain what the risks are and how to fix them.


# FUNCTION #1: Pull out the important information from Wapiti's output
def parse_wapiti_output(text):
    """Scan through Wapiti's output and grab the target website and all vulnerabilities found"""
    
    target = ""           # This will hold the website address that was scanned
    findings = []         # This will hold all the problems found
    current_module = None # Tracks which category of vulnerability we are currently reading
    lines = text.splitlines()  # Split the output into individual lines
    
    # Look at each line one by one
    for line in lines:
        line = line.strip()  # Remove extra spaces from the start and end

        # --- Find the website address (target URL) ---
        # Wapiti puts a line like "Target: https://example.com" at the start of the report
        if line.lower().startswith("target:"):
            # Grab everything after "Target:" - that's the website address
            target = line.split(":", 1)[-1].strip()

        # --- Find the start of a new vulnerability category ---
        # Wapiti groups vulnerabilities by type with headings like:
        # "XSS vulnerabilities:" or "SQL Injection vulnerabilities:"
        # This pattern looks for a capital letter followed by text ending with "vulnerability" or "vulnerabilities"
        elif re.match(r"^[A-Z].*vulnerabilit(ies|y):", line):
            # Store the category name and remove the colon at the end
            # Example: "XSS vulnerabilities:" becomes "XSS vulnerabilities"
            current_module = line.rstrip(":")
        
        # --- Find the actual vulnerabilities within a category ---
        # Each vulnerability is listed with a dash at the beginning of the line
        # Example: "- http://example.com/page.php?name=<script>"
        elif current_module and line.startswith("- "):
            # Add the vulnerability to our list, including which category it belongs to
            # line[2:] removes the "- " from the beginning of the line
            findings.append(f"{current_module}: {line[2:].strip()}")

    # Package everything into a simple structure (like a form with labels)
    parsed = {
        "target": target,      # The website that was scanned
        "findings": findings   # List of all vulnerabilities found
    }
    return parsed


# FUNCTION #2: Turn the findings into a question for an AI
def generate_prompt(data):
    """Create a prompt that asks an AI to explain the scan results in plain English"""
    
    # Get the website address, or use "unknown" if none was found
    target = data.get("target", "unknown")
    
    # Start building the prompt (the question we will send to the AI)
    prompt = f"This is the result of a web application scan for the target at {target}.\n\n"
    
    # Check if any vulnerabilities were found
    if not data["findings"]:
        # No problems found - good news, but remind the user to stay cautious
        prompt += "No security issues or vulnerabilities were detected in this scan. It's still good practice to continue monitoring and applying updates.\n"
    else:
        # Problems were found - list them out as bullet points
        prompt += "The scan discovered the following potential vulnerabilities:\n\n"
        
        for finding in data["findings"]:
            prompt += f"- {finding}\n"
        
        # Ask the AI to explain what these vulnerabilities mean and how to fix them
        prompt += (
            "\nPlease explain these vulnerabilities in simple terms. "
            "Describe why they might be dangerous, give real-world examples of what could happen, and suggest basic steps to protect the web application."
        )
    
    return prompt


# MAIN FUNCTION: Put it all together
if __name__ == "__main__":
    # Check if the user provided a file to read
    # sys.argv is a list of everything typed on the command line
    if len(sys.argv) < 2:
        print("Usage: python wapiti_parser.py <wapiti_output_file>")
        sys.exit(1)
    
    # Open and read the Wapiti output file
    with open(sys.argv[1], "r") as f:
        content = f.read()
    
    # Step 1: Parse the messy output into organized data
    parsed_data = parse_wapiti_output(content)
    
    # Step 2: Create a prompt asking the AI to explain the results
    prompt = generate_prompt(parsed_data)
    
    # Step 3: Print everything as JSON (organized data format that computers can read easily)
    print(json.dumps({
        "prompt": prompt,           # The question to ask the AI
        "parsed_data": parsed_data  # The raw parsed data (for reference)
    }, indent=2))
