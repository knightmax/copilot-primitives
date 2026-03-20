#
# setup-snip.ps1 — snip-core
# ===========================
# Checks snip installation and creates the global filters directory.
# Does NOT install any tool-specific filters — each snip-* skill does that.
#
# Usage:
#   & '.\.github\skills\snip-core\setup-snip.ps1'
#

$ErrorActionPreference = "Stop"

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok   { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Err  { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red; exit 1 }

Write-Info "snip core setup"

# 1. Check snip
$Snip = Get-Command snip -ErrorAction SilentlyContinue
if (-not $Snip) {
    Write-Err "snip is not installed. Install with: scoop install snip"
}
Write-Ok "snip found: $($Snip.Source)"

# 2. Ensure global filters directory
$FiltersDir = "$env:APPDATA\snip\filters"
if (-not (Test-Path $FiltersDir)) {
    New-Item -ItemType Directory -Path $FiltersDir -Force | Out-Null
    Write-Ok "Created $FiltersDir"
} else {
    Write-Info "Filters directory exists: $FiltersDir"
}

Write-Ok "snip core ready"
