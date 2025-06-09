import sys
import json
import re

def load_output(file_path):
    try:
        with open(file_path, "r") as f:
            return f.readlines()
    except Exception:
        return []

def clean_output(lines):
    filtered = []
    for line in lines:
        line = line.strip()

        # Skip empty lines or irrelevant file-type references
        if not line or re.search(r"\.(sh|md|txt|zip|LICENSE|log|json)", line, re.IGNORECASE):
            continue

        # Skip summary lines 
        if "password hash cracked" in line.lower():
            continue
        if "0 left" in line.lower():
            continue

        filtered.append(line)
    return "\n".join(filtered)

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"prompt": "No input file provided."}))
        return

    lines = load_output(sys.argv[1])
    cleaned_output = clean_output(lines)

    prompt = (
        f"Analyze this output from John the Ripper and give the file name and password from it:\n\n{cleaned_output}\n\n"
        "Then explain in simple, beginner-friendly language why this password might be weak and how to create stronger passwords in the future."
    )

    print(json.dumps({"prompt": prompt}))

if __name__ == "__main__":
    main()
