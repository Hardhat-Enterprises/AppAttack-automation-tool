#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 -t TOOL_NAME -i INPUT_FILE -o OUTPUT_FILE [-p PHASE] [-f FORMAT]
  -t TOOL_NAME   : Name of the tool (e.g. nmap, hydra, etc.)
  -i INPUT_FILE  : Raw output from the tool
  -o OUTPUT_FILE : Path to consolidated report
  -p PHASE       : Testing phase (Scanning, Exploitation, Post-Exploitation). Default: Scanning
  -f FORMAT      : md | json | csv. Default: md
EOF
  exit 1
}

# defaults
PHASE="Scanning"
FORMAT="md"

# parse args
while getopts "t:i:o:p:f:" opt; do
  case "$opt" in
    t) TOOL_NAME="$OPTARG" ;; 
    i) INPUT_FILE="$OPTARG" ;; 
    o) OUTPUT_FILE="$OPTARG" ;; 
    p) PHASE="$OPTARG" ;; 
    f) FORMAT="$OPTARG" ;; 
    *) usage ;; 
  esac
done

# validate required
if [[ -z "${TOOL_NAME:-}" || -z "${INPUT_FILE:-}" || -z "${OUTPUT_FILE:-}" ]]; then
  usage
fi

# ensure input exists
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "[WARNING] Input file not found: $INPUT_FILE" >&2
  exit 0
fi

# prepare output directory
mkdir -p "$(dirname "$OUTPUT_FILE")"

# parse results based on tool
parse_results() {
  case "$TOOL_NAME" in
    nmap)
      grep -E "^[0-9]+/tcp.*open" "$INPUT_FILE" || echo "No open ports found";
      ;;
    hydra)
      grep -E ":.*login:" "$INPUT_FILE" || echo "No valid credentials found";
      ;;
    nikto)
      grep "OSVDB" "$INPUT_FILE" || echo "No vulnerabilities found";
      ;;
    *)
      cat "$INPUT_FILE";
      ;;
  esac
}

# output functions
output_md() {
  # add report header if this is first write
  if [[ ! -s "$OUTPUT_FILE" ]]; then
    echo "# Automated Consolidated Report" >> "$OUTPUT_FILE"
    echo "_Generated on $(date)_" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
  echo "## $PHASE - $TOOL_NAME" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  parse_results | while read -r line; do
    if [[ -n "$line" ]]; then
      echo "- **$line**" >> "$OUTPUT_FILE"
    fi
  done
  echo "" >> "$OUTPUT_FILE"
}

output_json() {
  local data
  data=$(parse_results | jq -R . | jq -s .)
  jq -nc 
    --arg phase "$PHASE" 
    --arg tool "$TOOL_NAME" 
    --argjson results "$data" 
    '{phase: $phase, tool: $tool, results: $results}' >> "$OUTPUT_FILE"
}

output_csv() {
  if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "phase,tool,result" > "$OUTPUT_FILE"
  fi
  parse_results | while read -r line; do
    [[ -n "$line" ]] && echo "${PHASE},${TOOL_NAME},\"${line//"/""}\"" >> "$OUTPUT_FILE"
  done
}

# dispatch
case "$FORMAT" in
  md) output_md ;; 
  json) output_json ;; 
  csv) output_csv ;; 
  *) echo "Unknown format: $FORMAT" >&2; exit 1 ;;
 esac