#
# install.ps1 — snip-install
# ============================
# Installs snip CLI (if missing) and deploys ALL technology filters.
#
# Usage:
#   & '.\.github\skills\snip-install\scripts\install.ps1'
#
# What it does:
#   1. Checks snip is installed (or tells you how)
#   2. Creates %APPDATA%\snip\filters\ directory
#   3. Copies all filter YAML files from filters\<tech>\ subdirectories
#   4. Generates mvnd aliases from mvn filters (exact command matching)
#

$ErrorActionPreference = "Stop"

function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-Ok   { param([string]$M) Write-Host "[OK]   $M" -ForegroundColor Green }
function Write-Err  { param([string]$M) Write-Host "[ERR]  $M" -ForegroundColor Red; exit 1 }

# ── 1. Check snip installation ──────────────────────────────────────
$Snip = Get-Command snip -ErrorAction SilentlyContinue
if (-not $Snip) {
    Write-Err "snip not found. Install with: scoop install snip (Windows) or see https://github.com/edouard-claude/snip/releases"
}
Write-Ok "snip found: $($Snip.Source)"

# ── 2. Resolve paths ────────────────────────────────────────────────
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir
$FiltersSrc = Join-Path $SkillDir "filters"
$FiltersDest = "$env:APPDATA\.config\snip\filters"

if (-not (Test-Path $FiltersDest)) {
    New-Item -ItemType Directory -Path $FiltersDest -Force | Out-Null
}
Write-Ok "Filters directory: $FiltersDest"

# ── 3. Install all technology filters ────────────────────────────────
$Total = 0

foreach ($TechDir in (Get-ChildItem -Path $FiltersSrc -Directory)) {
    Write-Info "Installing $($TechDir.Name) filters..."

    foreach ($f in (Get-ChildItem -Path $TechDir.FullName -Filter "*.yaml")) {
        Copy-Item $f.FullName $FiltersDest -Force
        Write-Ok "  $($f.Name)"
        $Total++
    }
}

# ── 4. Generate mvnd aliases from mvn filters ───────────────────────
$MvnDir = Join-Path $FiltersSrc "mvn"
if (Test-Path $MvnDir) {
    Write-Info "Generating mvnd aliases from mvn filters..."

    foreach ($f in (Get-ChildItem -Path $MvnDir -Filter "*.yaml")) {
        $base = $f.Name
        if ($base -eq "mvn.yaml") {
            $aliasBase = "mvnd.yaml"
        } else {
            $aliasBase = $base -replace "^mvn-", "mvnd-"
        }

        $content = Get-Content $f.FullName -Raw
        $aliasContent = $content -replace 'command: "mvn"', 'command: "mvnd"'
        Set-Content -Path (Join-Path $FiltersDest $aliasBase) -Value $aliasContent -Encoding utf8 -NoNewline
        Write-Ok "  $aliasBase (alias)"
        $Total++
    }
}

# ── 5. Summary ──────────────────────────────────────────────────────
Write-Host ""
Write-Ok "Done! $Total filters installed to $FiltersDest"
Write-Info "Verify with: Get-ChildItem $FiltersDest"
Write-Info "Check savings: snip gain --daily"
