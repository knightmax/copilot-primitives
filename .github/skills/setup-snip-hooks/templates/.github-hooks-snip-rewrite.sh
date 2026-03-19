#!/bin/bash
#
# .github/hooks/snip-rewrite.sh
# =============================
# Copilot preToolUse hook that intercepts and rewrites commands through snip
#
# This hook is called by Copilot before executing terminal commands.
# It intercepts supported commands and rewrites them to use snip for token reduction.
#
# Supported commands: mvn, npm, yarn, pnpm, docker, kubectl, git, make, etc.
#

set -euo pipefail

# Get the command and arguments
COMMAND="${1:-}"
shift 2>/dev/null || true
ARGS=("$@")

# List of commands to rewrite through snip
SNIP_ENABLED_COMMANDS=(
    "mvn"
    "npm"
    "yarn"
    "pnpm"
    "docker"
    "kubectl"
    "git"
    "make"
    "pip"
    "pytest"
    "gradle"
    "cargo"
    "dotnet"
    "go"
    "rustc"
)

# Check if command should be rewritten
should_rewrite() {
    local cmd="$1"
    for enabled in "${SNIP_ENABLED_COMMANDS[@]}"; do
        if [ "$cmd" = "$enabled" ]; then
            return 0  # true - should rewrite
        fi
    done
    return 1  # false - don't rewrite
}

# If command should use snip, prepend it
if should_rewrite "$COMMAND"; then
    # Check if snip is available
    if command -v snip &> /dev/null; then
        # Rebuild the full command with snip
        set -- "snip" "$COMMAND" "${ARGS[@]}"
    fi
fi

# Execute the command
"$@"
