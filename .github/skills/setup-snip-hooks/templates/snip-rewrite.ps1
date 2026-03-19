#
# snip-rewrite.ps1
# ================
# Automated setup script for snip CLI hooks in Maven projects (Windows PowerShell)
#
# Usage:
#   .\snip-rewrite.ps1 <project-root>
#
# Example:
#   .\snip-rewrite.ps1 rescue-mission-good-architecture
#
# What this script does:
#   1. Verifies snip is installed
#   2. Copies Maven filter profiles to %APPDATA%\snip\filters (global snip config)
#   3. Creates .snip\ directory in project for reference
#   4. Sets up .vscode\settings.json for VS Code integration
#   5. Outputs test commands for validation
#

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectPath
)

# Set error handling
$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir

# Get workspace root (navigate from .github/skills/setup-snip-hooks/templates/ → ../../../../)
$WorkspaceRoot = Resolve-Path (Join-Path $SkillDir "../../..")

Write-Info "Snip Setup Script (Windows PowerShell)"
Write-Info "Script location: $ScriptDir"
Write-Info "Skill directory: $SkillDir"
Write-Info "Workspace root: $WorkspaceRoot"

# Resolve project root (absolute path)
try {
    $ProjectRoot = Resolve-Path $ProjectPath -ErrorAction Stop
} catch {
    Write-Error "Project directory does not exist: $ProjectPath"
}

Write-Info "Target project: $ProjectRoot"

# Verify prerequisites
Write-Info "Checking prerequisites..."

# Check if snip is installed
$SnipPath = Get-Command snip -ErrorAction SilentlyContinue
if (-not $SnipPath) {
    Write-Error "snip is not installed or not in PATH"
    Write-Error "Download from: https://github.com/edouard-claude/snip/releases"
    Write-Error "Or install with: scoop install snip  (if you have Scoop)"
}
Write-Success "snip found: $($SnipPath.Source)"

# Create global snip filters directory if needed
$SnipFiltersDir = "$env:APPDATA\snip\filters"
if (-not (Test-Path $SnipFiltersDir)) {
    New-Item -ItemType Directory -Path $SnipFiltersDir -Force | Out-Null
    Write-Success "Created $SnipFiltersDir"
}

# Copy Maven profiles to global snip config
Write-Info "Installing Maven snip profiles to $SnipFiltersDir..."

$profiles = @(
    "mvn-compile.yaml",
    "mvn-test.yaml",
    "mvn-verify.yaml",
    "mvn-package.yaml",
    "mvn-install.yaml",
    "mvn.yaml"
)

foreach ($profile in $profiles) {
    $profilePath = Join-Path $SkillDir "profiles" $profile
    if (Test-Path $profilePath) {
        Copy-Item $profilePath $SnipFiltersDir -Force
        Write-Success "Installed $profile"
    } else {
        Write-Warn "Profile not found: $profilePath"
    }
}

# Create .github\hooks\ directory for Copilot preToolUse hooks (at workspace root, not project root)
$HooksDir = Join-Path $WorkspaceRoot ".github" "hooks"
New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
Write-Success "Created hooks directory: $HooksDir"

# Copy the snip hook to .github\hooks\
$HookTemplate = Join-Path $SkillDir "templates" ".github-hooks-snip-rewrite.sh"
$HookDest = Join-Path $HooksDir "snip-rewrite.sh"

if (Test-Path $HookTemplate) {
    Copy-Item $HookTemplate $HookDest -Force
    Write-Success "Installed hook: $HookDest"
} else {
    Write-Warn "Hook template not found: $HookTemplate"
}

# Also copy PowerShell hook for Windows
$HookPsTemplate = Join-Path $SkillDir "templates" ".github-hooks-snip-rewrite.ps1"
$HookPsDest = Join-Path $HooksDir "snip-rewrite.ps1"

if (Test-Path $HookPsTemplate) {
    Copy-Item $HookPsTemplate $HookPsDest -Force
    Write-Success "Installed PowerShell hook: $HookPsDest"
} else {
    Write-Warn "PowerShell hook template not found: $HookPsTemplate"
}

# Copy/merge hooks.json for Copilot plugin
$HooksJsonTemplate = Join-Path $SkillDir "templates" "hooks.json"
$HooksJsonDest = Join-Path $HooksDir "hooks.json"

if (Test-Path $HooksJsonTemplate) {
    if (-not (Test-Path $HooksJsonDest)) {
        Copy-Item $HooksJsonTemplate $HooksJsonDest -Force
        Write-Success "Installed hooks configuration: $HooksJsonDest"
    } else {
        Write-Info "hooks.json already exists, skipping (merge manually if needed)"
    }
} else {
    Write-Warn "hooks.json template not found: $HooksJsonTemplate"
}

# Create .snip\ directory in project for reference (documentation)
$SnipRefDir = Join-Path $ProjectRoot ".snip"
New-Item -ItemType Directory -Path $SnipRefDir -Force | Out-Null
Write-Success "Created reference directory: $SnipRefDir"

# Create README for reference
$SnipReadme = @"
# snip Maven Filters

This directory is for reference only. The actual snip filters are installed globally in:

On Windows:
`````
%APPDATA%\snip\filters\
`````

On macOS/Linux:
`````
~/.config/snip/filters/
`````

## Available Filters

- **mvn-compile.yaml** — `mvn compile` — filters build verbose output
- **mvn-test.yaml** — `mvn test` — filters Surefire test output
- **mvn-verify.yaml** — `mvn verify` — filters Failsafe integration test output
- **mvn-package.yaml** — `mvn package` — filters JAR/WAR building output
- **mvn-install.yaml** — `mvn install` — filters build, test, and installation output
- **mvn.yaml** — General Maven filter for all commands

## Usage Examples

`````powershell
# Compile with noise reduction (93% token savings avg)
snip mvn clean compile

# Run tests with concise output
snip mvn test

# Verify builds (integration tests)
snip mvn verify

# See token savings
snip gain --daily
`````

## Customizing Filters

Edit filters directly:

On Windows (PowerShell):
`````powershell
notepad $env:APPDATA\snip\filters\mvn-test.yaml
`````

On Windows (CMD):
`````cmd
notepad %APPDATA%\snip\filters\mvn-test.yaml
`````

For syntax reference, see [SNIP_YAML_REFERENCE.md](../../snip/docs/SNIP_YAML_REFERENCE.md)

## Token Savings

snip automatically reduces token usage by:
- Removing verbose download/scanning messages
- Filtering DEBUG output
- Keeping only errors, warnings, and build status
- Compacting redundant lines

**Typical savings**: 85-95% token reduction per Maven command
"@

$SnipReadmePath = Join-Path $SnipRefDir "README.md"
Set-Content -Path $SnipReadmePath -Value $SnipReadme -Encoding UTF8
Write-Success "Created .snip\README.md"

# Create .vscode\settings.json if needed (optional, for VS Code integration)
$VsCodeDir = Join-Path $ProjectRoot ".vscode"
$SettingsFile = Join-Path $VsCodeDir "settings.json"

if (-not (Test-Path $VsCodeDir)) {
    New-Item -ItemType Directory -Path $VsCodeDir -Force | Out-Null
    Write-Success "Created $VsCodeDir"
}

if (-not (Test-Path $SettingsFile)) {
    $VsCodeSettings = @"
{
  "editor.formatOnSave": false,
  "maven.terminal.customAfterRunningCommand": "",
  "maven.executable.path": "",
  "[java]": {
    "editor.defaultFormatter": "redhat.java"
  }
}
"@
    Set-Content -Path $SettingsFile -Value $VsCodeSettings -Encoding UTF8
    Write-Success "Created $SettingsFile"
} else {
    Write-Info "Skipping $SettingsFile (already exists)"
}

# Summary and test commands
Write-Success "Setup complete!"
Write-Host ""
Write-Host "=== Quick Test Commands ===" -ForegroundColor Cyan
Write-Host ""
Write-Info "Try these commands to see snip in action:"
Write-Host ""
Write-Host "  # Test mvn-compile filter (93% reduction)"
Write-Host "  cd $ProjectRoot"
Write-Host "  snip mvn clean compile"
Write-Host ""
Write-Host "  # Test mvn-test filter"
Write-Host "  snip mvn test"
Write-Host ""
Write-Host "  # See token savings"
Write-Host "  snip gain --daily"
Write-Host ""
Write-Info "Installed profiles in $SnipFiltersDir`:"
Get-ChildItem $SnipFiltersDir -Filter "mvn-*.yaml" | ForEach-Object {
    Write-Host "  $($_.FullName)"
}
Write-Host ""
Write-Info "For more information:"
Write-Host "  - snip documentation: https://github.com/edouard-claude/snip"
Write-Host "  - Filter reference: $SkillDir\snip.yaml Reference (see snip/docs/)"
Write-Host "  - More examples: $SkillDir\MAVEN_FILTERS_EXAMPLES.md (see snip/docs/)"
Write-Host ""
