#!/bin/bash
# =============================================================================
# config.sh — Centralised configuration for the AppAttack toolkit
#
# Source this file at the top of any script that needs colours, paths, or
# shared constants.  It is safe to source multiple times (guard variable
# AA_CONFIG_LOADED prevents duplicate work).
# =============================================================================

[[ "${AA_CONFIG_LOADED:-}" == "true" ]] && return 0
AA_CONFIG_LOADED="true"

# ---------------------------------------------------------------------------
# 1. SCRIPT / INSTALL DIRECTORY
#    SCRIPT_DIR is set to wherever *this* file lives so that every sourcing
#    script automatically inherits the correct base path, regardless of how
#    it was invoked (direct run, symlink, or sourced).
# ---------------------------------------------------------------------------
AA_INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# 2. COLOUR PALETTE  (single source of truth — replaces the inline blocks
#    that were copy-pasted into every standalone script, and unifies the two
#    naming conventions that existed in colours.sh)
# ---------------------------------------------------------------------------

# Reset
NC='\033[0m'
Color_Off='\033[0m'   # alias used in menus.sh / colours.sh

# Regular colours
Red='\033[0;31m'  ;  RED="$Red"
Green='\033[0;32m';  GREEN="$Green"
Yellow='\033[0;33m'; YELLOW='\033[1;33m'   # bold yellow kept for YELLOW alias
Blue='\033[0;34m'
Purple='\033[0;35m'; MAGENTA="$Purple"
Cyan='\033[0;36m' ;  CYAN="$Cyan"
White='\033[0;37m'

# Bold colours
BRed='\033[1;31m'
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BBlue='\033[1;34m'
BPurple='\033[1;35m'
BCyan='\033[1;36m'
BWhite='\033[1;37m'

# Extra alias kept for back-compat with older callers
BLUE='\033[1;94m'

# ---------------------------------------------------------------------------
# 3. PATHS & FILES
# ---------------------------------------------------------------------------
LOG_FILE="${LOG_FILE:-$HOME/security_tools.log}"
AUDIT_LOG="$HOME/appattack_audit.log"

# ---------------------------------------------------------------------------
# 4. SHARED BANNER
#    Call  display_banner "<subtitle>"  from any script.
#    Passing no argument omits the subtitle line.
# ---------------------------------------------------------------------------
display_banner() {
    local subtitle="${1:-}"
    clear
    echo -e "${BRed}"
    echo -e " █████╗ ██████╗ ██████╗     █████╗ ████████╗████████╗ █████╗  ██████╗██╗  ██╗"
    echo -e "██╔══██╗██╔══██╗██╔══██╗   ██╔══██╗╚══██╔══╝╚══██╔══╝██╔══██╗██╔════╝██║ ██╔╝"
    echo -e "███████║██████╔╝██████╔╝   ███████║   ██║      ██║   ███████║██║     █████╔╝ "
    echo -e "██╔══██║██╔═══╝ ██╔═══╝    ██╔══██║   ██║      ██║   ██╔══██║██║     ██╔═██╗ "
    echo -e "██║  ██║██║     ██║        ██║  ██║   ██║      ██║   ██║  ██║╚██████╗██║  ██╗"
    echo -e "╚═╝  ╚═╝╚═╝     ╚═╝        ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    [[ -n "$subtitle" ]] && echo -e "${BYellow}              ${subtitle}${NC}"
    echo -e "${BPurple}           A Professional Pen-Testing / Secure Code Review Toolkit${NC}"
    echo ""
}

# ---------------------------------------------------------------------------
# 5. COMMON UTILITY — timestamped log helper
#    Usage:  log_message "something happened"
# ---------------------------------------------------------------------------
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${USER:-unknown} - $1" >> "$AUDIT_LOG"
}

# ---------------------------------------------------------------------------
# 6. API KEY VALIDATION (prints a one-time warning, never repeats)
# ---------------------------------------------------------------------------
if [[ -z "${GEMINI_API_KEY:-}" && "${_AA_KEY_WARNED:-}" != "true" ]]; then
    echo "GEMINI_API_KEY is not set — cloud LLM features will be unavailable." >&2
    _AA_KEY_WARNED="true"
fi
