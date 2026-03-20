#!/bin/bash
#
# setup-snip.sh
# =============
# First-time setup for snip CLI token reduction filters (macOS / Linux)
# No hooks — filters are installed globally and the agent prefixes commands manually.
#
# Usage:
#   bash .github/skills/snip-maven/setup-snip.sh
#
# What this script does:
#   1. Verifies snip is installed
#   2. Copies Maven filter profiles to ~/.config/snip/filters (global snip config)
#   3. Validates installation
#

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()      { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()     { echo -e "${RED}[ERR]${NC}  $1"; exit 1; }

# Resolve skill directory
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "snip Maven setup (hook-free)"
info "Skill directory: ${SKILL_DIR}"

# 1. Check snip
command -v snip &>/dev/null || err "snip is not installed. Install: brew install snip  or  cargo install snip"
ok "snip found: $(command -v snip)"

# 2. Create global filters directory
FILTERS_DIR="$HOME/.config/snip/filters"
mkdir -p "${FILTERS_DIR}"
ok "Filters directory: ${FILTERS_DIR}"

# 3. Copy profiles
PROFILES_DIR="${SKILL_DIR}/profiles"
for p in mvn-compile.yaml mvn-test.yaml mvn-verify.yaml mvn-package.yaml mvn-install.yaml mvn.yaml; do
    if [ -f "${PROFILES_DIR}/${p}" ]; then
        cp "${PROFILES_DIR}/${p}" "${FILTERS_DIR}/${p}"
        ok "  ${p}"
    else
        warn "  Profile not found: ${PROFILES_DIR}/${p}"
    fi
done

# 4. Validate
info ""
info "=== Installation complete ==="
info "Filters installed to: ${FILTERS_DIR}"
info ""
info "Usage:  snip mvn clean test"
info "Stats:  snip gain --daily"
echo ""
ls -1 "${FILTERS_DIR}"/mvn*.yaml 2>/dev/null | while read -r f; do ok "  $(basename "$f")"; done
