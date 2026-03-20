#
# install-filters.ps1 — snip-filters-setup
# ========================================
# Shared installer for snip filter profiles.
#
# Usage example:
#   & '.\.github\skills\snip-filters-setup\scripts\install-filters.ps1' `
#       -SourceDir '.\.github\skills\snip-npm\filters' `
#       -ToolLabel 'npm'
#

param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir,

    [Parameter(Mandatory = $true)]
    [string]$ToolLabel,

    [string]$AliasFrom,
    [string]$AliasTo,
    [string]$LegacyFileToRemove
)

$ErrorActionPreference = "Stop"

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok   { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Err  { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red; exit 1 }

$Snip = Get-Command snip -ErrorAction SilentlyContinue
if (-not $Snip) {
    Write-Err "snip not found. Run snip-core setup first: & '.\.github\skills\snip-core\scripts\setup-snip.ps1'"
}

$ResolvedSource = (Resolve-Path $SourceDir -ErrorAction SilentlyContinue)
if (-not $ResolvedSource) {
    Write-Err "SourceDir not found: $SourceDir"
}

$FiltersDir = "$env:APPDATA\snip\filters"
if (-not (Test-Path $FiltersDir)) {
    New-Item -ItemType Directory -Path $FiltersDir -Force | Out-Null
}

if ($LegacyFileToRemove) {
    Remove-Item (Join-Path $FiltersDir $LegacyFileToRemove) -Force -ErrorAction SilentlyContinue
}

Write-Info "Installing $ToolLabel snip filters..."
foreach ($f in (Get-ChildItem (Join-Path $ResolvedSource.Path "*.yaml"))) {
    Copy-Item $f.FullName $FiltersDir -Force
    Write-Ok "  $($f.Name)"

    if ($AliasFrom -and $AliasTo) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match ('command:\s*"' + [regex]::Escape($AliasFrom) + '"')) {
            $aliasName = if ($f.Name -eq "$AliasFrom.yaml") {
                "$AliasTo.yaml"
            } elseif ($f.Name.StartsWith("$AliasFrom-")) {
                $f.Name -replace ("^" + [regex]::Escape($AliasFrom) + "-"), "$AliasTo-"
            } else {
                "$AliasTo-$($f.Name)"
            }

            $aliasContent = $content -replace ('command:\s*"' + [regex]::Escape($AliasFrom) + '"'), ('command: "' + $AliasTo + '"')
            Set-Content -Path (Join-Path $FiltersDir $aliasName) -Value $aliasContent -Encoding utf8
            Write-Ok "  $aliasName"
        }
    }
}

Write-Ok "$ToolLabel filters installed to $FiltersDir"
