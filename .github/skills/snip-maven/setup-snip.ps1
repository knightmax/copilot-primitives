#
# setup-snip.ps1
# ==============
# First-time setup for snip CLI token reduction filters (Windows PowerShell)
# No hooks — filters are installed globally and the agent prefixes commands manually.
#
# Usage:
#   .\.github\skills\snip-maven\setup-snip.ps1
#
# What this script does:
#   1. Verifies snip is installed
#   2. Copies Maven filter profiles to %APPDATA%\snip\filters (global snip config)
#   3. Validates installation
#

$ErrorActionPreference = "Stop"

function Write-Info    { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok      { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Warn    { param([string]$M) Write-Host "[WARN] $M" -ForegroundColor Yellow }
function Write-Err     { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red; exit 1 }

# Resolve skill directory (setup-snip.ps1 lives at skill root)
$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Info "snip Maven setup (hook-free)"
Write-Info "Skill directory: $SkillDir"

# 1. Check snip is installed
$Snip = Get-Command snip -ErrorAction SilentlyContinue
if (-not $Snip) {
    Write-Err "snip is not installed or not in PATH. Install with: scoop install snip"
}
Write-Ok "snip found: $($Snip.Source)"

# 2. Create global filters directory
$FiltersDir = "$env:APPDATA\snip\filters"
if (-not (Test-Path $FiltersDir)) {
    New-Item -ItemType Directory -Path $FiltersDir -Force | Out-Null
    Write-Ok "Created $FiltersDir"
} else {
    Write-Info "Filters directory already exists: $FiltersDir"
}

# 3. Copy profiles
$ProfilesDir = Join-Path $SkillDir "profiles"
$profiles = @(
    "mvn-compile.yaml",
    "mvn-test.yaml",
    "mvn-verify.yaml",
    "mvn-package.yaml",
    "mvn-install.yaml",
    "mvn.yaml"
)

Write-Info "Installing Maven snip profiles..."
foreach ($p in $profiles) {
    $src = Join-Path $ProfilesDir $p
    if (Test-Path $src) {
        Copy-Item $src $FiltersDir -Force
        Write-Ok "  $p"
    } else {
        Write-Warn "  Profile not found: $src"
    }
}

# 4. Validate
Write-Info ""
Write-Info "=== Installation complete ==="
Write-Info "Filters installed to: $FiltersDir"
Write-Info ""
Write-Info "Usage:  snip mvn clean test"
Write-Info "Stats:  snip gain --daily"
Write-Info ""
Get-ChildItem "$FiltersDir\mvn*.yaml" | ForEach-Object { Write-Ok "  $($_.Name)" }
