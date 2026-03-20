#
# setup-filters.ps1 — snip-dotnet
# =================================
# Installs .NET snip filter profiles to global snip config.
#
# Usage:
#   & '.\.github\skills\snip-dotnet\setup-filters.ps1'
#

$ErrorActionPreference = "Stop"

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok   { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Err  { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red; exit 1 }

# Check snip
$Snip = Get-Command snip -ErrorAction SilentlyContinue
if (-not $Snip) {
    Write-Err "snip not found. Run snip-core setup first: & '.\.github\skills\snip-core\setup-snip.ps1'"
}

$FiltersDir = "$env:APPDATA\snip\filters"
if (-not (Test-Path $FiltersDir)) {
    New-Item -ItemType Directory -Path $FiltersDir -Force | Out-Null
}

$SkillDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcDir = Join-Path $SkillDir "filters"

Write-Info "Installing .NET snip filters..."
foreach ($f in (Get-ChildItem "$SrcDir\*.yaml")) {
    Copy-Item $f.FullName $FiltersDir -Force
    Write-Ok "  $($f.Name)"
}

Write-Ok ".NET filters installed to $FiltersDir"
