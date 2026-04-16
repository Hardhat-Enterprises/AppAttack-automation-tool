import sys
import re
import json

# --------------------------------------------------------------
# FUNCTION #1: Pull out the important information from SQLMap's output
# --------------------------------------------------------------
def parse_sqlmap_output(text):
    """Scan through SQLMap's output and grab the target website and all important findings"""
    
    findings = []      # This will hold all the important messages
    target = ""        # This will hold the website address that was tested
    
    # Split the text into individual lines
    lines = text.splitlines()
    
    # Look at each line one by one
    for line in lines:
        
        # --- Find the website address (target URL) ---
        # SQLMap shows lines like "testing URL: https://example.com/page.php?id=1"
        if "testing URL" in line.lower() or "URL" in line:
            # Search for "URL:" or "url:" followed by the website address
            match = re.search(r"(URL|url):\s*(\S+)", line, re.IGNORECASE)
            if match:
                target = match.group(2)  # Store the website address
        
        # --- Find the important messages ---
        # SQLMap marks important lines with labels like:
        # [INFO]     - Just information, good to know
        # [WARNING]  - Something you should pay attention to
        # [CRITICAL] - Something dangerous or urgent
        # [PAYLOAD]  - The actual sneaky text SQLMap tried to inject
        if "[INFO]" in line or "[WARNING]" in line or "[CRITICAL]" in line or "[PAYLOAD]" in line:
            # Remove the label (like "[INFO]") and keep just the message
            # Example: "[INFO] testing connection" becomes "testing connection"
            cleaned = re.sub(r"\[\w+\]\s*", "", line).strip()
            
            # Only add it if it's not empty
            if cleaned:
                findings.append(cleaned)
    
    # Package everything into a simple structure
    # list(set(findings)) removes any duplicate messages
    parsed = {
        "target": target,                    # The website that was tested
        "findings": list(set(findings))      # All unique important messages
    }
    return parsed

# --------------------------------------------------------------
# FUNCTION #2: Turn the findings into a question for an AI
# --------------------------------------------------------------
def generate_prompt(data):
    """Create a prompt that asks an AI to explain the scan results"""
    
    target = data.get("target", "unknown")  # Get the website address, or "unknown" if missing
    
    # Start building the prompt
    prompt = f"This is the result of a database vulnerability scan for the web application at {target}.\n\n"
    
    # Check if any findings were found
    if not data["findings"]:
        # No problems found - good news but stay cautious
        prompt += (
            "No clear signs of SQL injection or database vulnerabilities were found. "
            "That's a good sign, but it's important to stay cautious and regularly test your web apps for weaknesses.\n"
        )
    else:
        # Problems were found - list them out
        prompt += "The scan uncovered the following important observations or potential issues:\n\n"
        
        for finding in data["findings"]:
            prompt += f"- {finding}\n"
        
        # Ask the AI to explain what this means and how to stay safe
        prompt += (
            "\nPlease explain these observations in clear, beginner-friendly language. "
            "Describe what each point might mean, why it could be risky, and share simple advice for improving the security of a web application."
        )
    
    return prompt

# --------------------------------------------------------------
# MAIN FUNCTION: Put it all together
# --------------------------------------------------------------
if __name__ == "__main__":
    # Check if the user provided a file to read
    if len(sys.argv) < 2:
        print("Usage: python sqlmap_parser.py <sqlmap_output_file>")
        sys.exit(1)
    
    # Open and read the SQLMap output file
    with open(sys.argv[1], "r") as f:
        content = f.read()
    
    # Step 1: Parse the messy output into organized data
    parsed_data = parse_sqlmap_output(content)
    
    # Step 2: Create a prompt asking the AI to explain the results
    prompt = generate_prompt(parsed_data)
    
    # Step 3: Print everything as JSON (organized data format)
    print(json.dumps({
        "prompt": prompt,           # The question to ask the AI
        "parsed_data": parsed_data  # The raw parsed data (for reference)
    }, indent=2))
