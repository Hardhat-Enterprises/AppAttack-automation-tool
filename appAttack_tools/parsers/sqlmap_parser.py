import sys
import re
import json

# Parses SQLMap output to extract findings
def parse_sqlmap_output(text):
    findings = []
    target = ""
    lines = text.splitlines()

    for line in lines:
        # Extract target URL if present
        if "testing URL" in line.lower() or "URL" in line:
            match = re.search(r"(URL|url):\s*(\S+)", line, re.IGNORECASE)
            if match:
                target = match.group(2)
        # Look for injection results or alerts
        if "[INFO]" in line or "[WARNING]" in line or "[CRITICAL]" in line or "[PAYLOAD]" in line:
            cleaned = re.sub(r"\[\w+\]\s*", "", line).strip()
            if cleaned:
                findings.append(cleaned)

    # Structure parsed data
    parsed = {
        "target": target,
        "findings": list(set(findings))  # Remove duplicates
    }
    return parsed

# Generate human-friendly prompt
def generate_prompt(data):
    target = data.get("target", "unknown")
    prompt = f"This is the result of a database vulnerability scan for the web application at {target}.\n\n"
    
    if not data["findings"]:
        prompt += (
            "No clear signs of SQL injection or database vulnerabilities were found. "
            "That's a good sign, but it's important to stay cautious and regularly test your web apps for weaknesses.\n"
        )
    else:
        prompt += "The scan uncovered the following important observations or potential issues:\n\n"
        for finding in data["findings"]:
            prompt += f"- {finding}\n"
        prompt += (
            "\nPlease explain these observations in clear, beginner-friendly language. "
            "Describe what each point might mean, why it could be risky, and share simple advice for improving the security of a web application."
        )
    
    return prompt

# Main execution
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python sqlmap_parser.py <sqlmap_output_file>")
        sys.exit(1)

    with open(sys.argv[1], "r") as f:
        content = f.read()

    parsed_data = parse_sqlmap_output(content)
    prompt = generate_prompt(parsed_data)

    print(json.dumps({
        "prompt": prompt,
        "parsed_data": parsed_data
    }, indent=2))
