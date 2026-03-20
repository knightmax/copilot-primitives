---
name: snip-npm
description: "Use snip to reduce npm CLI output tokens. Load this skill before running any npm command: npm install, npm ci, npm test, npm run, npm run build, npm run lint, npm audit. Applies to all npm invocations."
argument-hint: "Loaded automatically when npm commands need to be run."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip npm — Token Reduction for npm CLI

## Purpose

Reduces `npm` terminal output by 80-95% using `snip` CLI filters.

**No hooks** (company policy blocks preToolUse hooks). The agent prefixes commands with `snip` directly.

## Rule: Always Prefix npm Commands with `snip`

**MANDATORY**: Every `npm` command MUST be prefixed with `snip`.

```powershell
# ✅ CORRECT
snip npm install
snip npm ci
snip npm test
snip npm run build
snip npm run lint
snip npm audit

# ❌ WRONG - no snip
npm install
npm test
npm run build
```

Applies to ALL npm subcommands: `install`, `ci`, `test`, `run`, `audit`, `publish`, etc.

## IMPORTANT — snip Has NO Output Until Command Finishes

> **CRITICAL: Empty output is NORMAL. It does NOT mean snip failed.**

`snip` buffers everything and prints only after the command exits. During the command, the terminal shows **nothing**.

**Rules:**
- **NEVER** interpret empty output as a snip failure
- **NEVER** fall back to bare `npm` because output was empty
- **NEVER** use `isBackground=false` — it will appear to hang

**Correct execution pattern:**

```
1. run_in_terminal(command="snip npm test", isBackground=true)
2. get_terminal_output(id=<terminal_id>)
3. If empty, command is still running, so poll again
4. When output appears, command is done, so read results
```

## First-Time Setup

### Quick Check

```powershell
Get-Command snip -ErrorAction SilentlyContinue; Test-Path "$env:APPDATA\snip\filters\npm-test.yaml"
```

If snip is missing: load `snip-core` skill and follow its install instructions.

If filters are missing: load and use `snip-filters-setup` skill with this profile:

- `source-dir`: `.github/skills/snip-npm/filters`
- `tool-label`: `npm`

The shared skill contains the canonical PowerShell/bash commands.

## Filters

| Command | Filter | What It Keeps |
|---------|--------|---------------|
| `snip npm install` | npm-install.yaml | Package change summary, vulnerabilities, errors |
| `snip npm ci` | npm-ci.yaml | Install/lockfile summary, vulnerabilities, errors |
| `snip npm test` | npm-test.yaml | Test results, pass/fail, errors |
| `snip npm run <script>` | npm-run.yaml | Script output summary, pass/fail, errors |
| `snip npm <any>` | npm.yaml | Errors, warnings, summary lines (fallback) |

**Removed**: `npm notice`, `npm info`, verbose dependency and fetch logs, blank lines.

## Fallback

If `snip` is not available and cannot be installed, run npm commands without it.

## Customizing Filters

Edit directly — changes apply immediately:

```powershell
notepad "$env:APPDATA\snip\filters\npm-test.yaml"
```

Reference filters are in `.github/skills/snip-npm/filters/`.
