---
name: jq
description: "⚡ IMPORTANT: Auto-trigger for JSON operations. Use when: extract JSON field, check version in package.json, list config, filter objects, count items, parse API response. Surgical extraction 90-99% token savings. Essential for package.json, tsconfig, settings files."
---

# JSON manipulation with jq

## Core rule

**When you need to read, extract, filter or transform data from a JSON file, use `jq` on the command line instead of reading the entire file.**

Reading a full JSON file with Read consumes all the file's tokens (~800 tokens for a package.json, ~50,000 tokens for a large business event). With `jq`, you surgically extract only the data you need in a few tokens.

## Prerequisites: check/install jq

*IMPORTANT*: Check availability first:

```bash
jq --version
```

If `jq` is not installed:

| OS | Installation command |
|----|---------------------|
| **Windows (winget)** | `winget install jqlang.jq` |
| **Windows (manual)** | Download `jq-windows-amd64.exe` from https://github.com/jqlang/jq/releases, rename to `jq.exe`, place in a PATH directory (e.g. `C:\tools\jq\`) |
| **Linux (apt)** | `sudo apt-get install -y jq` |
| **Linux (yum)** | `sudo yum install -y jq` |
| **macOS** | `brew install jq` |

## Shell compatibility

### Bash / Git Bash (recommended)

Single quotes work natively — use them for all jq filters:

```bash
jq '.technical.sa' event.json
jq '[.payload.agreements[].agreement_id]' event.json
```

### PowerShell

Single quotes do NOT work for jq filters in PowerShell. Always wrap with `cmd /c`:

```powershell
# ✅ CORRECT in PowerShell
cmd /c 'jq ".technical.sa" event.json'

# ❌ BROKEN in PowerShell (quoting issues)
jq '.technical.sa' event.json
```

## Usage patterns

### Extract a value

**Example: Extract a single field from a large JSON event**

- Input: `event.json` (68,445 lines, 2.6 MB, ~692k tokens)
- Task: Get the SA name
- Output: `"OSMOSE"` (~1 token)
- Token saving: **-99.99%** (692k → 1 token)

```bash
jq '.technical.sa' event.json
# → "OSMOSE"
```

```powershell
# PowerShell equivalent
cmd /c 'jq ".technical.sa" event.json'
```

### List values from an array

```bash
jq '[.payload.agreements[].agreement_id]' event.json

# First element only
jq '.payload.agreements[0].agreement_id' event.json
```

```powershell
cmd /c 'jq "[.payload.agreements[].agreement_id]" event.json'
```

### Count elements

**Example: Count array items without loading the full file**

- Input: `event.json` (692k tokens, 38 agreements in payload)
- Task: How many agreements are there?
- Output: `38` (~1 token)
- Token saving: **-99.99%**

```bash
jq '.payload.agreements | length' event.json
# → 38
```

```powershell
cmd /c 'jq ".payload.agreements | length" event.json'
```

### Filter with select

```bash
jq '[.payload.agreements[] | select(.market_code == "PRE")]' event.json
```

```powershell
cmd /c 'jq "[.payload.agreements[] | select(.market_code == \"PRE\")]" event.json'
```

### Project specific fields

```bash
jq '[.payload.agreements[] | {id: .agreement_id, market: .market_code}]' event.json
```

```powershell
cmd /c 'jq "[.payload.agreements[] | {id: .agreement_id, market: .market_code}]" event.json'
```

### List keys of an object

```bash
jq 'keys' file.json
jq '.technical | keys' event.json
```

```powershell
cmd /c 'jq "keys" file.json'
cmd /c 'jq ".technical | keys" event.json'
```

### Modify a value

```bash
jq '.version = "2.0"' package.json
```

```powershell
cmd /c 'jq ".version = \"2.0\"" package.json'
```
