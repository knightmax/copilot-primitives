#
# .github/hooks/snip-rewrite.ps1
# ==============================
# Copilot preToolUse hook that intercepts and rewrites commands through snip (Windows PowerShell)
#
# This hook is called by Copilot before executing terminal commands.
# It intercepts supported commands and rewrites them to use snip for token reduction.
#
# Supported commands: mvn, npm, yarn, pnpm, docker, kubectl, git, make, etc.
#

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$CommandArgs
)

# Extract command and arguments
if ($CommandArgs.Count -eq 0) {
    exit 1
}

$Command = $CommandArgs[0]
$Args = $CommandArgs[1..($CommandArgs.Count - 1)]

# List of commands to rewrite through snip
$SnipEnabledCommands = @(
    "mvn",
    "npm",
    "yarn",
    "pnpm",
    "docker",
    "kubectl",
    "git",
    "make",
    "pip",
    "pytest",
    "gradle",
    "cargo",
    "dotnet",
    "go",
    "rustc"
)

# Check if command should be rewritten
$ShouldRewrite = $Command -in $SnipEnabledCommands

# If command should use snip, prepend it
if ($ShouldRewrite) {
    # Check if snip is available
    $SnipExists = $null -ne (Get-Command snip -ErrorAction SilentlyContinue)
    
    if ($SnipExists) {
        # Rebuild the command with snip
        & snip $Command @Args
        exit $LASTEXITCODE
    }
}

# Execute the command as-is if not rewritten
& $Command @Args
exit $LASTEXITCODE
