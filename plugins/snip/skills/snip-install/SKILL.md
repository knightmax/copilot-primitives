---
name: snip-install
description: "Install, configure, or update snip CLI and all output filters (Maven/mvnd, npm, dotnet). Use when setting up snip for the first time, adding filters to a new machine, updating existing filters, or after adding a new technology filter."
argument-hint: "Run install script to deploy or update snip + all filters."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip Install — CLI + All Filters

Installs [snip](https://github.com/edouard-claude/snip) and deploys all technology filters in one step.

## Quick Setup

**macOS / Linux:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/snip-install/scripts/install.sh"
```

**Windows (PowerShell):**
```powershell
& "${env:CLAUDE_PLUGIN_ROOT}\skills\snip-install\scripts\install.ps1"
```

## What Gets Installed

The script checks snip is available, then copies all filter profiles to `~/.config/snip/filters/` (macOS/Linux) or `%APPDATA%\snip\filters\` (Windows).

### Filters by Technology

| Technology | Filters | Savings |
|---|---|---|
| **Maven** (`mvn`) | mvn, mvn-test, mvn-compile, mvn-package, mvn-install, mvn-verify | 80-95% |
| **Maven Daemon** (`mvnd`) | Auto-generated aliases from mvn filters | 80-95% |
| **npm** | npm, npm-test, npm-install, npm-run, npm-ci | 80-95% |
| **dotnet** | dotnet-build, dotnet-test | 80-95% |

Total: **13 base filters + 6 mvnd aliases = 19 filters**

## Install snip (if missing)

**macOS:** `brew install snip`
**Windows:** `scoop install snip`
**Other:** See [releases](https://github.com/edouard-claude/snip/releases)

## How mvn/mvnd Aliasing Works

snip uses **exact command matching** — a filter for `mvn` does not match `mvnd`. The install script auto-generates `mvnd-*.yaml` aliases by copying each `mvn-*.yaml` filter and replacing `command: "mvn"` with `command: "mvnd"`.

## Adding a New Technology

1. Create a subdirectory: `filters/<techname>/`
2. Add `.yaml` filter files following the [snip filter format](https://github.com/edouard-claude/snip/wiki/Filters)
3. Re-run the install script — it auto-discovers all subdirectories
4. If the new tool has binary aliases (like mvn/mvnd), add alias generation to the install script

## Verify Installation

```bash
ls ~/.config/snip/filters/          # List installed filters
snip gain --daily                   # Check token savings
snip -v mvn test                    # Verbose mode to confirm filter match
```
