---
name: snip-dotnet
description: "Use snip to reduce .NET CLI output tokens. Load this skill before running any dotnet command: dotnet build, dotnet test, dotnet run, dotnet publish, dotnet restore. Applies to all dotnet invocations."
argument-hint: "Loaded automatically when dotnet commands need to be run."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip .NET — Token Reduction for dotnet CLI

## Purpose

Reduces `dotnet` terminal output by 80-95% using `snip` CLI filters.

**No hooks** (company policy blocks preToolUse hooks). The agent prefixes commands with `snip` directly.

## Rule: Always Prefix dotnet Commands with `snip`

**MANDATORY**: Every `dotnet` command MUST be prefixed with `snip`.

```powershell
# ✅ CORRECT
snip dotnet build
snip dotnet test
snip dotnet publish -c Release
snip dotnet test --filter "FullyQualifiedName~MyTest"

# ❌ FAUX — no snip
dotnet build
dotnet test
```

Applies to ALL dotnet verbs: `build`, `test`, `run`, `publish`, `restore`, `clean`, etc.

## IMPORTANT — snip Has NO Output Until Build Finishes

> **CRITICAL: Empty output is NORMAL. It does NOT mean snip failed.**

`snip` buffers everything and prints only after the command exits. During the build, the terminal shows **nothing**.

**Rules:**
- **NEVER** interpret empty output as a snip failure
- **NEVER** fall back to bare `dotnet` because output was empty
- **NEVER** use `isBackground=false` — it will appear to hang

**Correct execution pattern:**

```
1. run_in_terminal(command="snip dotnet test", isBackground=true)
2. get_terminal_output(id=<terminal_id>)
3. If empty → build still running → poll again
4. When output appears → build done → read results
```

## First-Time Setup

### Quick Check

```powershell
Get-Command snip -ErrorAction SilentlyContinue; Test-Path "$env:APPDATA\snip\filters\dotnet-build.yaml"
```

If snip is missing → load `snip-core` skill and follow its install instructions.

If filters are missing → run the setup script:

```powershell
& '.\.github\skills\snip-dotnet\setup-filters.ps1'
```

## Filters

| Command | Filter | What It Keeps |
|---------|--------|---------------|
| `snip dotnet build` | dotnet-build.yaml | Errors, warnings, build result |
| `snip dotnet test` | dotnet-test.yaml | Test results, failures, summary |

**Removed**: restore messages, project path lines, Microsoft copyright, blank lines.

## Fallback

If `snip` is not available and cannot be installed, run `dotnet` commands without it.

## Customizing Filters

Edit directly — changes apply immediately:

```powershell
notepad "$env:APPDATA\snip\filters\dotnet-build.yaml"
```

Reference filters are in `.github/skills/snip-dotnet/filters/`.
