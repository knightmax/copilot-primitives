---
name: snip-jvm
description: "Use snip to reduce Maven/mvnd CLI output tokens. Load this skill before running any Maven command: mvn, mvnd, mvn clean, mvn test, mvn package, mvn install, mvn verify, mvn compile, mvnd test, mvnd clean. Applies to all mvn and mvnd invocations."
argument-hint: "Loaded automatically when Maven/mvnd commands need to be run."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip JVM — Token Reduction for Maven / mvnd

## Purpose

Reduces Maven terminal output by 85-95% using `snip` CLI filters.

**No hooks** (company policy blocks preToolUse hooks). The agent prefixes commands with `snip` directly.

## Rule: Always Prefix Maven Commands with `snip`

**MANDATORY**: Every `mvn` or `mvnd` command MUST be prefixed with `snip`.

```powershell
# ✅ CORRECT
snip mvn clean test
snip mvn -pl gateway test
snip mvnd clean package -DskipTests
snip mvnd -pl gateway test -Dtest=HeadersSecurityTest

# ❌ FAUX — no snip
mvn clean test
mvnd -pl gateway test
```

Applies to ALL goals: `compile`, `test`, `verify`, `package`, `install`, `clean`, `dependency:tree`, etc.

## IMPORTANT — snip Has NO Output Until Build Finishes

> **CRITICAL: Empty output is NORMAL. It does NOT mean snip failed.**

`snip` buffers everything and prints only after the command exits. During the build, the terminal shows **nothing**.

**Rules:**
- **NEVER** interpret empty output as a snip failure
- **NEVER** fall back to bare `mvn`/`mvnd` because output was empty
- **NEVER** use `isBackground=false` — it will appear to hang

**Correct execution pattern:**

```
1. run_in_terminal(command="snip mvn -pl gateway test", isBackground=true)
2. get_terminal_output(id=<terminal_id>)
3. If empty → build still running → poll again
4. When output appears → build done → read results
```

## First-Time Setup

### Quick Check

```powershell
Get-Command snip -ErrorAction SilentlyContinue; Test-Path "$env:APPDATA\snip\filters\mvn.yaml"
```

If snip is missing → load `snip-core` skill and follow its install instructions.

If filters are missing → run the setup script:

```powershell
& '.\.github\skills\snip-jvm\setup-filters.ps1'
```

## Filters

| Command | Filter | What It Keeps |
|---------|--------|---------------|
| `snip mvn compile` | mvn-compile.yaml | Errors, warnings, BUILD result |
| `snip mvn test` | mvn-test.yaml | Test results, failures, errors, BUILD |
| `snip mvn verify` | mvn-verify.yaml | Failsafe results, BUILD |
| `snip mvn package` | mvn-package.yaml | JAR/WAR info, BUILD result |
| `snip mvn install` | mvn-install.yaml | BUILD, errors, test summary |
| `snip mvn <any>` | mvn.yaml | BUILD, errors, warnings (fallback) |
| `snip mvnd <any>` | Same filters as mvn | mvnd uses identical output format |

**Removed**: `[INFO] Downloading...`, `[INFO] Downloaded...`, `[DEBUG]`, blank lines, scanning messages.

## Fallback

If `snip` is not available and cannot be installed, run `mvn`/`mvnd` commands without it.

## Customizing Filters

Edit directly — changes apply immediately:

```powershell
notepad "$env:APPDATA\snip\filters\mvn-test.yaml"
```

Reference profiles are in `.github/skills/snip-jvm/filters/`.
