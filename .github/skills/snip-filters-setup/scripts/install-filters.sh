#!/bin/bash
#
# install-filters.sh — snip-filters-setup
# =======================================
# Shared installer for snip filter profiles.
#
# Usage example:
#   bash .github/skills/snip-filters-setup/scripts/install-filters.sh \
#     --source-dir .github/skills/snip-npm/filters \
#     --tool-label npm
#

set -euo pipefail

ok()   { echo -e "\033[0;32m[OK]\033[0m   $1"; }
err()  { echo -e "\033[0;31m[ERR]\033[0m  $1"; exit 1; }
info() { echo "[INFO] $1"; }

SOURCE_DIR=""
TOOL_LABEL=""
ALIAS_FROM=""
ALIAS_TO=""
LEGACY_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-dir)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --tool-label)
      TOOL_LABEL="$2"
      shift 2
      ;;
    --alias-from)
      ALIAS_FROM="$2"
      shift 2
      ;;
    --alias-to)
      ALIAS_TO="$2"
      shift 2
      ;;
    --legacy-file-to-remove)
      LEGACY_FILE="$2"
      shift 2
      ;;
    *)
      err "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$SOURCE_DIR" ]] || err "Missing required --source-dir"
[[ -n "$TOOL_LABEL" ]] || err "Missing required --tool-label"

command -v snip &>/dev/null || err "snip not found. Run snip-core setup first: bash .github/skills/snip-core/scripts/setup-snip.sh"
[[ -d "$SOURCE_DIR" ]] || err "Source directory not found: $SOURCE_DIR"

FILTERS_DIR="$HOME/.config/snip/filters"
mkdir -p "$FILTERS_DIR"

if [[ -n "$LEGACY_FILE" ]]; then
  rm -f "$FILTERS_DIR/$LEGACY_FILE"
fi

info "Installing $TOOL_LABEL snip filters..."
for f in "$SOURCE_DIR"/*.yaml; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f")"
  cp "$f" "$FILTERS_DIR/$base"
  ok "  $base"

  if [[ -n "$ALIAS_FROM" && -n "$ALIAS_TO" ]] && grep -q "command: \"$ALIAS_FROM\"" "$f"; then
    alias_base="$base"
    if [[ "$base" == "$ALIAS_FROM.yaml" ]]; then
      alias_base="$ALIAS_TO.yaml"
    elif [[ "$base" == "$ALIAS_FROM-"* ]]; then
      alias_base="${base/#$ALIAS_FROM-/$ALIAS_TO-}"
    else
      alias_base="$ALIAS_TO-$base"
    fi

    sed "s/command: \"$ALIAS_FROM\"/command: \"$ALIAS_TO\"/" "$f" > "$FILTERS_DIR/$alias_base"
    ok "  $alias_base"
  fi
done

ok "$TOOL_LABEL filters installed to $FILTERS_DIR"
