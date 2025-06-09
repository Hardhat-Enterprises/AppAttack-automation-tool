import sys
import re
import json

# Parses Wapiti output to extract vulnerabilities
def parse_wapiti_output(text):
    target = ""
    findings = []
    current_module = None
    lines = text.splitlines()
    for line in lines:
        line = line.strip()

        # Get the target URL (optional, depends on output format)
        if line.lower().startswith("target:"):
            target = line.split(":", 1)[-1].strip()

        # Detect start of a new module (e.g., "XSS vulnerabilities:")
        elif re.match(r"^[A-Z].*vulnerabilit(ies|y):", line):
            current_module = line.rstrip(":")
        
        # Vulnerability lines usually start with a dash
        elif current_module and line.startswith("- "):
            findings.append(f"{current_module}: {line[2:].strip()}")

    parsed = {
        "target": target,
        "findings": findings
    }
    return parsed

def generate_prompt(data):
    target = data.get("target", "unknown")
    prompt = f"This is the result of a web application scan for the target at {target}.\n\n"
    if not data["findings"]:
        prompt += "No security issues or vulnerabilities were detected in this scan. It's still good practice to continue monitoring and applying updates.\n"
    else:
        prompt += "The scan discovered the following potential vulnerabilities:\n\n"
        for finding in data["findings"]:
            prompt += f"- {finding}\n"
        prompt += (
            "\nPlease explain these vulnerabilities in simple terms. "
            "Describe why they might be dangerous, give real-world examples of what could happen, and suggest basic steps to protect the web application."
        )
    return prompt

# Main execution block
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python wapiti_parser.py <wapiti_output_file>")
        sys.exit(1)
    with open(sys.argv[1], "r") as f:
        content = f.read()
    parsed_data = parse_wapiti_output(content)
    prompt = generate_prompt(parsed_data)
    print(json.dumps({
        "prompt": prompt,
        "parsed_data": parsed_data
    }, indent=2))
