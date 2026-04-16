import sys
import json
import re

# --------------------------------------------------------------
# HELPER FUNCTION #1: Read the raw output file
# --------------------------------------------------------------
def load_output(file_path):
    """Open a file and read all its lines"""
    try:
        with open(file_path, "r") as f:
            return f.readlines()  # Return each line as a list item
    except Exception:
        return []  # If file doesn't exist or can't be read, return empty list

# --------------------------------------------------------------
# HELPER FUNCTION #2: Clean up the messy output
# --------------------------------------------------------------
def clean_output(lines):
    """Remove useless lines from John the Ripper's output"""
    filtered = []
    
    for line in lines:
        line = line.strip()  # Remove extra spaces from start and end
        
        # Skip empty lines (nothing there)
        if not line:
            continue
        
        # Skip lines that mention file names (we don't need these)
        # Examples: .sh, .md, .txt, .zip, .log, .json
        if re.search(r"\.(sh|md|txt|zip|LICENSE|log|json)", line, re.IGNORECASE):
            continue
        
        # Skip summary lines that John the Ripper adds at the end
        # Example: "password hash cracked"
        if "password hash cracked" in line.lower():
            continue
        
        # Skip lines that say how many passwords are left
        # Example: "0 left"
        if "0 left" in line.lower():
            continue
        
        # If we made it here, this line is important - keep it
        filtered.append(line)
    
    # Join all the kept lines together with line breaks in between
    return "\n".join(filtered)

# --------------------------------------------------------------
# MAIN FUNCTION: Put it all together
# --------------------------------------------------------------
def main():
    # Check if user gave us a file to read
    # sys.argv is a list of everything typed on the command line
    # Example: python john_parser.py results.txt
    # sys.argv[0] = "john_parser.py" (the script name)
    # sys.argv[1] = "results.txt" (the first argument)
    if len(sys.argv) < 2:
        # No file provided - print an error message in JSON format
        print(json.dumps({"prompt": "No input file provided."}))
        return
    
    # Read the raw output file
    lines = load_output(sys.argv[1])
    
    # Clean up the output (remove useless lines)
    cleaned_output = clean_output(lines)
    
    # Build a question to send to an AI
    # The AI will get the cleaned output and be asked to analyze it
    prompt = (
        f"Analyze this output from John the Ripper and give the file name and password from it:\n\n{cleaned_output}\n\n"
        "Then explain in simple, beginner-friendly language why this password might be weak and how to create stronger passwords in the future."
    )
    
    # Package the question as JSON and print it
    # JSON is just a way to organize data that computers understand
    print(json.dumps({"prompt": prompt}))

# --------------------------------------------------------------
# Run the main function only if this file is run directly
# (not if it's being imported by another file)
# --------------------------------------------------------------
if __name__ == "__main__":
    main()
