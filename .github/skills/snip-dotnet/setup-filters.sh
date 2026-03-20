#!/bin/bash
#
# setup-filters.sh — snip-dotnet
# ================================
# Installs .NET snip filter profiles to global snip config.
#
# Usage:
#   bash .github/skills/snip-dotnet/setup-filters.sh
#

set -euo pipefail

ok()   { echo -e "\033[0;32m[OK]\033[0m   $1"; }
err()  { echo -e "\033[0;31m[ERR]\033[0m  $1"; exit 1; }

command -v snip &>/dev/null || err "snip not found. Run snip-core setup first."

FILTERS_DIR="$HOME/.config/snip/filters"
mkdir -p "${FILTERS_DIR}"

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[INFO] Installing .NET snip filters..."
for f in "${SKILL_DIR}"/filters/*.yaml; do
    cp "$f" "${FILTERS_DIR}/"
    ok "  $(basename "$f")"
done

ok ".NET filters installed to ${FILTERS_DIR}"
