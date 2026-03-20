---
name: snip-maven
description: Use snip to reduce Maven CLI output tokens. Load this skill before running any Maven command (mvn clean, mvn test, mvn package, mvn install, mvn verify, mvn compile). Applies to all Maven invocations.
argument-hint: "Loaded automatically when Maven commands need to be run. Ensures snip token reduction is active."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip Maven — Token Reduction for Maven Commands

## Purpose

Reduces Maven terminal output by 85-95% using `snip` CLI filters. This avoids blowing up the agent's context window with verbose download/scan/debug lines.

**This skill does NOT use hooks** (company policy blocks preToolUse hooks). Instead, the agent follows these instructions to prefix Maven commands with `snip` directly.

## Rule: Always Prefix Maven Commands with `snip`

**MANDATORY**: Every time you run a Maven command in the terminal, prefix it with `snip`.

**PowerShell (Windows)**: `snip` et `mvn` sont des exécutables externes — stderr est invisible sans `2>&1`. Toujours rediriger stderr vers stdout.

```powershell
# ✅ CORRECT — snip + stderr capturé
snip mvn clean test 2>&1
snip mvn -pl gateway test 2>&1
snip mvn clean package -DskipTests 2>&1
snip mvn -pl gateway test -Dtest=HeadersSecurityTest 2>&1

# ❌ FAUX — stderr perdu silencieusement
snip mvn clean test
snip mvn -pl gateway test

# ❌ FAUX — pas de snip
mvn clean test
mvn -pl gateway test
```

This applies to ALL Maven invocations: `compile`, `test`, `verify`, `package`, `install`, `clean`, `dependency:tree`, etc.

## First-Time Setup

Before the first Maven command, check if snip is available and filters are installed.

### Quick Check (run this first)

```powershell
# Windows
Get-Command snip -ErrorAction SilentlyContinue; Test-Path "$env:APPDATA\snip\filters\mvn.yaml"
```

```bash
# macOS / Linux
command -v snip && test -f ~/.config/snip/filters/mvn.yaml && echo "OK"
```

### If snip is NOT configured

Run the setup script from the skill directory:

**Windows (PowerShell):**
```powershell
& '.\.github\skills\snip-maven\setup-snip.ps1'
```

**macOS / Linux:**
```bash
bash .github/skills/snip-maven/setup-snip.sh
```

This installs 6 Maven filter profiles globally. No hooks, no project modifications.

### If snip is NOT installed

**Windows:**
```powershell
scoop install snip
# Then run setup script above
```

**macOS:**
```bash
brew install snip
# Then run setup script above
```

## How It Works

snip discovers filters automatically based on the command:

| Command | Filter Used | What It Keeps |
|---------|-------------|---------------|
| `snip mvn compile` | mvn-compile.yaml | Errors, warnings, BUILD result |
| `snip mvn test` | mvn-test.yaml | Test results, failures, errors, BUILD |
| `snip mvn verify` | mvn-verify.yaml | Failsafe results, BUILD |
| `snip mvn package` | mvn-package.yaml | JAR/WAR info, BUILD result |
| `snip mvn install` | mvn-install.yaml | BUILD, errors, test summary |
| `snip mvn <any>` | mvn.yaml | BUILD, errors, warnings (fallback) |

**Removed**: `[INFO] Downloading...`, `[INFO] Downloaded...`, `[DEBUG]`, blank lines, scanning messages — typically 85-95% of output.

## Fallback

If `snip` is not available and cannot be installed, run Maven commands normally. The skill degrades gracefully — output will just be verbose.

## Filter Locations

| OS | Path |
|----|------|
| Windows | `%APPDATA%\snip\filters\mvn-*.yaml` |
| macOS / Linux | `~/.config/snip/filters/mvn-*.yaml` |

## Token Savings Stats

```powershell
snip gain --daily
snip gain --weekly
```

## Customizing Filters

Edit filters directly — changes take effect immediately:

```powershell
# Windows
notepad "$env:APPDATA\snip\filters\mvn-test.yaml"
```

```bash
# macOS / Linux
vi ~/.config/snip/filters/mvn-test.yaml
```

Reference profiles are in `.github/skills/snip-maven/profiles/` and `.github/skills/snip-maven/filters/`.
