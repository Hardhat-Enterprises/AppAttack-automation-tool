#!/bin/bash
# =============================================================================
# reporting.sh — All report generation functions
#
# Replaces: automate_reporting.sh, create_delta_report.sh,
#           create_trend_analysis_report.sh
# =============================================================================

# === Script Directory Detection ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# === Shared config (colours, display_banner, LOG_FILE, etc.) ===
source "$SCRIPT_DIR/config.sh"

# =============================================================================
# SECTION 1 — CONSOLIDATED TOOL REPORT
# Appends structured output from a single tool run into a master report file.
# Usage (when sourced): automate_reporting -t nmap -i input.txt -o report.md
# =============================================================================

automate_reporting() {
    set -euo pipefail

    local TOOL_NAME="" INPUT_FILE="" OUTPUT_FILE=""
    local PHASE="Scanning" FORMAT="md"

    _usage() {
        cat <<EOF
Usage: automate_reporting -t TOOL_NAME -i INPUT_FILE -o OUTPUT_FILE [-p PHASE] [-f FORMAT]
  -t  Tool name        (e.g. nmap, nikto, hydra)
  -i  Raw input file   (tool output to parse)
  -o  Output file      (consolidated report to append to)
  -p  Phase            Scanning | Exploitation | Post-Exploitation  (default: Scanning)
  -f  Format           md | json | csv  (default: md)
EOF
        return 1
    }

    while getopts "t:i:o:p:f:" opt; do
        case "$opt" in
            t) TOOL_NAME="$OPTARG" ;;
            i) INPUT_FILE="$OPTARG" ;;
            o) OUTPUT_FILE="$OPTARG" ;;
            p) PHASE="$OPTARG" ;;
            f) FORMAT="$OPTARG" ;;
            *) _usage ;;
        esac
    done

    [[ -z "${TOOL_NAME:-}" || -z "${INPUT_FILE:-}" || -z "${OUTPUT_FILE:-}" ]] && { _usage; return 1; }

    if [[ ! -f "$INPUT_FILE" ]]; then
        echo "[WARNING] Input file not found: $INPUT_FILE" >&2
        return 0
    fi

    mkdir -p "$(dirname "$OUTPUT_FILE")"

    _parse_results() {
        case "$TOOL_NAME" in
            nmap)  grep -E "^[0-9]+/tcp.*open" "$INPUT_FILE" || echo "No open ports found" ;;
            hydra) grep -E ":.*login:" "$INPUT_FILE" || echo "No valid credentials found" ;;
            nikto) grep "OSVDB" "$INPUT_FILE" || echo "No vulnerabilities found" ;;
            *)     cat "$INPUT_FILE" ;;
        esac
    }

    _output_md() {
        if [[ ! -s "$OUTPUT_FILE" ]]; then
            { echo "# Automated Consolidated Report"
              echo "_Generated on $(date)_"
              echo ""; } >> "$OUTPUT_FILE"
        fi
        echo "## $PHASE - $TOOL_NAME" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        _parse_results | while read -r line; do
            [[ -n "$line" ]] && echo "- **$line**" >> "$OUTPUT_FILE"
        done
        echo "" >> "$OUTPUT_FILE"
    }

    _output_json() {
        local data
        data=$(_parse_results | jq -R . | jq -s .)
        jq -nc --arg phase "$PHASE" --arg tool "$TOOL_NAME" --argjson results "$data" \
            '{phase: $phase, tool: $tool, results: $results}' >> "$OUTPUT_FILE"
    }

    _output_csv() {
        [[ ! -f "$OUTPUT_FILE" ]] && echo "phase,tool,result" > "$OUTPUT_FILE"
        _parse_results | while read -r line; do
            [[ -n "$line" ]] && printf '%s,%s,"%s"\n' \
                "$PHASE" "$TOOL_NAME" "${line//\"/\"\"}" >> "$OUTPUT_FILE"
        done
    }

    case "$FORMAT" in
        md)   _output_md ;;
        json) _output_json ;;
        csv)  _output_csv ;;
        *)    echo "Unknown format: $FORMAT" >&2; return 1 ;;
    esac
}

# =============================================================================
# SECTION 2 — DELTA REPORT
# Diffs two scan reports and highlights new and fixed vulnerabilities.
# =============================================================================

create_delta_report() {
    display_banner "Delta Report Generation"

    read -p "Enter the path to the first scan report: " report1
    read -p "Enter the path to the second scan report: " report2

    if [[ ! -f "$report1" || ! -f "$report2" ]]; then
        echo -e "${BRed}Error: One or both report files not found.${NC}"
        return 1
    fi

    echo -e "${BGreen}[*] Generating delta report...${NC}"

    local delta_report="delta_report_$(date +%F_%H-%M-%S).txt"

    echo -e "${BYellow}### New Vulnerabilities ###${NC}" > "$delta_report"
    diff -u "$report1" "$report2" | grep -E '^\+' | sed 's/^\+//' >> "$delta_report"

    echo -e "\n${BYellow}### Fixed Vulnerabilities ###${NC}" >> "$delta_report"
    diff -u "$report1" "$report2" | grep -E '^\-' | sed 's/^\-//' >> "$delta_report"

    echo -e "${BGreen}[+] Delta report generated: $delta_report${NC}"
}

# =============================================================================
# SECTION 3 — TREND ANALYSIS REPORT
# Aggregates all reports in a directory into a single trend report.
# =============================================================================

create_trend_analysis_report() {
    display_banner "Trend Analysis Report Generation"

    read -p "Enter the directory containing the scan reports: " reports_dir

    if [[ ! -d "$reports_dir" ]]; then
        echo -e "${BRed}Error: Directory not found.${NC}"
        return 1
    fi

    echo -e "${BGreen}[*] Generating trend analysis report...${NC}"

    local trend_report="trend_analysis_report_$(date +%F_%H-%M-%S).txt"

    echo -e "${BYellow}### Trend Analysis Report ###${NC}" > "$trend_report"

    for report in "$reports_dir"/*; do
        if [[ -f "$report" ]]; then
            echo -e "\n${BCyan}--- Report: $report ---${NC}" >> "$trend_report"
            cat "$report" >> "$trend_report"
        fi
    done

    echo -e "${BGreen}[+] Trend analysis report generated: $trend_report${NC}"
}
