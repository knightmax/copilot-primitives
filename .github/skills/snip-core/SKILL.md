---
name: snip-core
description: "Core snip CLI setup and verification. Loaded by other snip-* skills when they need to check or install snip. Load this skill when the user asks to install snip, check snip installation, or when another snip skill references it for first-time setup."
argument-hint: "Verify snip is installed and ready. Run setup if needed."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip Core — Installation & Verification

## Purpose

Provides snip CLI installation check and first-time setup. This skill is referenced by tool-specific snip skills (`snip-jvm`, `snip-dotnet`, etc.) when setup is needed.

**This skill does NOT install filters.** Filter installation is handled by `snip-filters-setup` using tool-specific `filters/*.yaml` profiles.

## Quick Check

Before any snip command, verify snip is available:

```powershell
# Windows PowerShell
Get-Command snip -ErrorAction SilentlyContinue
```

## Install snip

If snip is not found:

**Windows (PowerShell):**
```powershell
scoop install snip
```

**macOS:**
```bash
brew install snip
```

## Setup Scripts

Use the scripts in the skill `scripts/` folder:

**Windows (PowerShell):**
```powershell
& '.\.github\skills\snip-core\scripts\setup-snip.ps1'
```

**macOS/Linux:**
```bash
bash .github/skills/snip-core/scripts/setup-snip.sh
```

## IMPORTANT — snip Produces NO Output Until the Command Finishes

> **CRITICAL: Read this section carefully. Misunderstanding it causes the #1 agent mistake.**

`snip` **buffers the entire output** of the wrapped command and only prints it **after the command exits**. During execution, the terminal shows **absolutely nothing** — no progress, no partial output, no streaming.

### What this means for you (the agent)

1. **Empty output is NORMAL** — it does NOT mean snip failed, is not installed, or that the command errored. It means the build is still running.
2. **NEVER interpret empty output as a failure.** NEVER fall back to running without snip because you saw no output.
3. **NEVER retry the command** or switch to bare `mvn`/`dotnet` because the output was empty.

### How to run snip commands

**Use `isBackground=true`**, then poll with `get_terminal_output`:

```
1. Launch:  run_in_terminal(command="snip mvn -pl gateway test", isBackground=true)
2. Poll:    get_terminal_output(id=<terminal_id>)
3. If output is empty → the build is still running → wait and poll again
4. When output appears → the build is done → read the results
```

**NEVER use `isBackground=false`** — the tool call will block with zero visible output for the entire build duration, which looks like a hang and triggers incorrect fallback behavior.

### Common mistake (DO NOT DO THIS)

```
❌ Agent runs: snip mvn test
❌ Agent sees: (empty output)
❌ Agent thinks: "snip failed, let me try without snip"
❌ Agent runs: mvn test

This is WRONG. The empty output meant the build was still running.
```

## Filters Directory

| OS | Path |
|----|------|
| Windows | `%APPDATA%\snip\filters\` |
| macOS / Linux | `~/.config/snip/filters/` |

## Token Savings Stats

```powershell
snip gain --daily
snip gain --weekly
```
