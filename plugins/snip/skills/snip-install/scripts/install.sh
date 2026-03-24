#!/bin/bash
#
# install.sh — snip-install (plugin version)
# ============================================
# Installs snip CLI (if missing) and deploys ALL technology filters.
#
# Usage:
#   bash "${CLAUDE_PLUGIN_ROOT}/skills/snip-install/scripts/install.sh"
#
# What it does:
#   1. Checks snip is installed (or tells you how)
#   2. Creates ~/.config/snip/filters/ directory
#   3. Copies all filter YAML files from filters/<tech>/ subdirectories
#   4. Generates mvnd aliases from mvn filters (exact command matching)
#

set -euo pipefail

ok()   { echo -e "\033[0;32m[OK]\033[0m   $1"; }
err()  { echo -e "\033[0;31m[ERR]\033[0m  $1"; exit 1; }
info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }

# ── 1. Check snip installation ──────────────────────────────────────
command -v snip &>/dev/null || err "snip not found. Install with: brew install snip (macOS) or see https://github.com/edouard-claude/snip/releases"
ok "snip found: $(command -v snip)"

# ── 2. Resolve paths ────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FILTERS_SRC="$SKILL_DIR/filters"
FILTERS_DEST="$HOME/.config/snip/filters"

mkdir -p "$FILTERS_DEST"
ok "Filters directory: $FILTERS_DEST"

# ── 3. Install all technology filters ────────────────────────────────
TOTAL=0

for tech_dir in "$FILTERS_SRC"/*/; do
  [ -d "$tech_dir" ] || continue
  tech_name="$(basename "$tech_dir")"
  info "Installing $tech_name filters..."

  for f in "$tech_dir"*.yaml; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    cp "$f" "$FILTERS_DEST/$base"
    ok "  $base"
    TOTAL=$((TOTAL + 1))
  done
done

# ── 4. Generate mvnd aliases from mvn filters ───────────────────────
info "Generating mvnd aliases from mvn filters..."
for f in "$FILTERS_SRC/mvn/"*.yaml; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"

  # Compute alias filename: mvn.yaml -> mvnd.yaml, mvn-test.yaml -> mvnd-test.yaml
  if [ "$base" = "mvn.yaml" ]; then
    alias_base="mvnd.yaml"
  else
    alias_base="${base/mvn-/mvnd-}"
  fi

  sed 's/command: "mvn"/command: "mvnd"/' "$f" > "$FILTERS_DEST/$alias_base"
  ok "  $alias_base (alias)"
  TOTAL=$((TOTAL + 1))
done

# ── 5. Summary ──────────────────────────────────────────────────────
echo ""
ok "Done! $TOTAL filters installed to $FILTERS_DEST"
info "Verify with: ls $FILTERS_DEST"
info "Check savings: snip gain --daily"
