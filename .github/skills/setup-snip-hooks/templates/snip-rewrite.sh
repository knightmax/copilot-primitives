#!/bin/bash
#
# snip-rewrite.sh
# ===============
# Automated setup script for snip CLI hooks in Maven projects
#
# Usage:
#   bash snip-rewrite.sh <project-root>
#
# Example:
#   bash snip-rewrite.sh rescue-mission-good-architecture
#
# What this script does:
#   1. Verifies snip and jq are installed
#   2. Copies Maven filter profiles to ~/.config/snip/filters (global snip config)
#   3. Optionally creates .snip/ directory in project for reference
#   4. Sets up .vscode/settings.json for VS Code integration
#   5. Outputs test commands for validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}" && pwd)"

# Get workspace root (navigate from .github/skills/setup-snip-hooks/templates/ → ../../../../)
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

log_info "Snip Setup Script"
log_info "Script location: ${SCRIPT_DIR}"
log_info "Skill directory: ${SKILL_DIR}"
log_info "Workspace root: ${WORKSPACE_ROOT}"

# Validate arguments
if [ $# -ne 1 ]; then
    log_error "Usage: bash snip-rewrite.sh <project-root>"
    log_error "Example: bash snip-rewrite.sh rescue-mission-good-architecture"
    exit 1
fi

TARGET_PROJECT="$1"

# Resolve project root (absolute path)
if [ -d "${TARGET_PROJECT}" ]; then
    PROJECT_ROOT="$(cd "${TARGET_PROJECT}" && pwd)"
else
    log_error "Project directory does not exist: ${TARGET_PROJECT}"
    exit 1
fi

log_info "Target project: ${PROJECT_ROOT}"

# Verify prerequisites
log_info "Checking prerequisites..."

if ! command -v snip &> /dev/null; then
    log_error "snip is not installed or not in PATH"
    log_error "Install with: curl -L https://github.com/edouard-claude/snip/releases/download/v0.1.24/snip-macos -o /usr/local/bin/snip && chmod +x /usr/local/bin/snip"
    exit 1
fi
log_success "snip found: $(command -v snip)"

if ! command -v jq &> /dev/null; then
    log_error "jq is not installed or not in PATH"
    log_error "Install with: brew install jq"
    exit 1
fi
log_success "jq found: $(command -v jq)"

# Create global snip filters directory if needed
SNIP_FILTERS_DIR="$HOME/.config/snip/filters"
if [ ! -d "${SNIP_FILTERS_DIR}" ]; then
    mkdir -p "${SNIP_FILTERS_DIR}"
    log_success "Created ${SNIP_FILTERS_DIR}"
fi

# Copy Maven profiles to global snip config
log_info "Installing Maven snip profiles to ${SNIP_FILTERS_DIR}..."

for profile in mvn-compile.yaml mvn-test.yaml mvn-verify.yaml mvn-package.yaml mvn-install.yaml mvn.yaml; do
    if [ -f "${SKILL_DIR}/profiles/${profile}" ]; then
        cp "${SKILL_DIR}/profiles/${profile}" "${SNIP_FILTERS_DIR}/${profile}"
        log_success "Installed ${profile}"
    else
        log_warn "Profile not found: ${SKILL_DIR}/profiles/${profile}"
    fi
done

# Create .github/hooks/ directory for Copilot preToolUse hooks (at workspace root, not project root)
HOOKS_DIR="${WORKSPACE_ROOT}/.github/hooks"
mkdir -p "${HOOKS_DIR}"
log_success "Created hooks directory: ${HOOKS_DIR}"

# Copy the snip hook to .github/hooks/
HOOK_TEMPLATE="${SKILL_DIR}/templates/.github-hooks-snip-rewrite.sh"
HOOK_DEST="${HOOKS_DIR}/snip-rewrite.sh"

if [ -f "${HOOK_TEMPLATE}" ]; then
    cp "${HOOK_TEMPLATE}" "${HOOK_DEST}"
    chmod +x "${HOOK_DEST}"
    log_success "Installed hook: ${HOOK_DEST}"
else
    log_warn "Hook template not found: ${HOOK_TEMPLATE}"
fi

# Copy/merge hooks.json for Copilot plugin
HOOKS_JSON_TEMPLATE="${SKILL_DIR}/templates/hooks.json"
HOOKS_JSON_DEST="${HOOKS_DIR}/hooks.json"

if [ -f "${HOOKS_JSON_TEMPLATE}" ]; then
    if [ ! -f "${HOOKS_JSON_DEST}" ]; then
        cp "${HOOKS_JSON_TEMPLATE}" "${HOOKS_JSON_DEST}"
        log_success "Installed hooks configuration: ${HOOKS_JSON_DEST}"
    else
        log_info "hooks.json already exists, skipping (merge manually if needed)"
    fi
else
    log_warn "hooks.json template not found: ${HOOKS_JSON_TEMPLATE}"
fi

# Optionally create .snip/ directory in project for reference (documentation)
mkdir -p "${PROJECT_ROOT}/.snip"
log_success "Created reference directory: ${PROJECT_ROOT}/.snip"

# Copy a README for reference
cat > "${PROJECT_ROOT}/.snip/README.md" << 'EOF'
# snip Maven Filters

This directory is for reference only. The actual snip filters are installed globally in:

```
~/.config/snip/filters/
```

## Available Filters

- **mvn-compile.yaml** — `mvn compile` — filters build verbose output
- **mvn-test.yaml** — `mvn test` — filters Surefire test output
- **mvn-verify.yaml** — `mvn verify` — filters Failsafe integration test output
- **mvn-package.yaml** — `mvn package` — filters JAR/WAR building output
- **mvn.yaml** — General Maven filter for all commands

## Usage Examples

```bash
# Compile with noise reduction (93% token savings avg)
snip mvn clean compile

# Run tests with concise output
snip mvn test

# Verify builds (integration tests)
snip mvn verify

# See token savings
snip gain --daily
```

## Customizing Filters

Edit filters directly in `~/.config/snip/filters/`:

```bash
vi ~/.config/snip/filters/mvn-test.yaml
```

For syntax reference, see [SNIP_YAML_REFERENCE.md](../../SNIP_YAML_REFERENCE.md)

## Token Savings

snip automatically reduces token usage by:
- Removing verbose download/scanning messages
- Filtering DEBUG output
- Keeping only errors, warnings, and build status
- Compacting redundant lines

**Typical savings**: 85-95% token reduction per Maven command
EOF
log_success "Created .snip/README.md"

# Create .vscode/settings.json if needed (optional, for VS Code integration)
VSCODE_DIR="${PROJECT_ROOT}/.vscode"
SETTINGS_FILE="${VSCODE_DIR}/settings.json"

if [ ! -d "${VSCODE_DIR}" ]; then
    mkdir -p "${VSCODE_DIR}"
    log_success "Created ${VSCODE_DIR}"
fi

if [ ! -f "${SETTINGS_FILE}" ]; then
    cat > "${SETTINGS_FILE}" << 'EOF'
{
  "editor.formatOnSave": false,
  "maven.terminal.customAfterRunningCommand": "",
  "maven.executable.path": "",
  "[java]": {
    "editor.defaultFormatter": "redhat.java"
  }
}
EOF
    log_success "Created ${SETTINGS_FILE}"
else
    log_info "Skipping ${SETTINGS_FILE} (already exists)"
fi

# Summary and test commands
log_success "Setup complete!"
echo ""
echo "=== Quick Test Commands ==="
echo ""
log_info "Try these commands to see snip in action:"
echo ""
echo "  # Test mvn-compile filter (93% reduction)"
echo "  cd ${PROJECT_ROOT}"
echo "  snip mvn clean compile"
echo ""
echo "  # Test mvn-test filter"
echo "  snip mvn test"
echo ""
echo "  # See token savings"
echo "  snip gain --daily"
echo ""
log_info "Installed profiles in ~/.config/snip/filters/:"
ls -lh "${SNIP_FILTERS_DIR}"/mvn-*.yaml | awk '{print "  " $9}'
echo ""
log_info "For more information:"
echo "  - snip documentation: https://github.com/edouard-claude/snip"
echo "  - Filter reference: ${SKILL_DIR}/SNIP_YAML_REFERENCE.md"
echo "  - More examples: ${SKILL_DIR}/MAVEN_FILTERS_EXAMPLES.md"
echo ""

