import sys
import re
import json

# Parses Nikto output to extract findings
def parse_nikto_output(text):
    findings = []
    host = ""
    lines = text.splitlines()
    for line in lines:
        # Extract target host from the header line
        if "Target IP:" in line or "Target Host:" in line:
            host_match = re.search(r"(Target IP|Target Host):\s*(\S+)", line)
            if host_match:
                host = host_match.group(2)
        # Extract relevant findings (typically lines with '+' at the beginning)
        elif line.strip().startswith("+"):
            finding = line.strip("+ ").strip()
            findings.append(finding)
    # Structure parsed data
    parsed = {
        "host": host,
        "findings": findings
    }
    return parsed

def generate_prompt(data):
    host = data.get("host", "unknown")
    prompt = f"This is the result of a website vulnerability scan for the server at {host}.\n\n"
    if not data["findings"]:
        prompt += "No obvious problems or vulnerabilities were found on this web server. That's a good sign, but it's always smart to keep systems updated and monitored.\n"
    else:
        prompt += "The scan found the following issues or observations:\n\n"
        for finding in data["findings"]:
            prompt += f"- {finding}\n"
        prompt += (
            "\nPlease explain these issues in plain, beginner-friendly language. "
            "Describe what each finding might mean, why it could matter, and simple steps a non-expert could take to improve security."
        )
    return prompt

# Main execution block
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python nikto_parser.py <nikto_output_file>")
        sys.exit(1)
    with open(sys.argv[1], "r") as f:
        content = f.read()
    parsed_data = parse_nikto_output(content)
    prompt = generate_prompt(parsed_data)
    print(json.dumps({
        "prompt": prompt,
        "parsed_data": parsed_data
    }, indent=2))
