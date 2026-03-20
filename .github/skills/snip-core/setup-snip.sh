#!/bin/bash
#
# setup-snip.sh — snip-core
# ==========================
# Checks snip installation and creates the global filters directory.
# Does NOT install any tool-specific filters — each snip-* skill does that.
#
# Usage:
#   bash .github/skills/snip-core/setup-snip.sh
#

set -euo pipefail

info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
ok()   { echo -e "\033[0;32m[OK]\033[0m   $1"; }
err()  { echo -e "\033[0;31m[ERR]\033[0m  $1"; exit 1; }

info "snip core setup"

command -v snip &>/dev/null || err "snip is not installed. Install: brew install snip"
ok "snip found: $(command -v snip)"

FILTERS_DIR="$HOME/.config/snip/filters"
mkdir -p "${FILTERS_DIR}"
ok "Filters directory: ${FILTERS_DIR}"

ok "snip core ready"
