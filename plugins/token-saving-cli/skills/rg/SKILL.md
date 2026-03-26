---
name: rg
description: >
  Use ripgrep (rg) to search text content inside files from the command line instead of Select-String (PowerShell),
  grep -r (Bash), or reading entire files. Load this skill for searching across codebases: finding annotations in
  catalog files, locating component owners, searching for API keys/secrets/tokens (security audit), tracking imports
  or dependencies, finding configuration values, discovering class usage, identifying error patterns, or searching
  logs. Use even when the user doesn't say "ripgrep" or "rg" — phrases like "search for", "find files containing",
  "which components use this system", "locate all TODOs", "find the annotation", "security scan for secrets",
  "what files import this module" all trigger this skill. rg respects .gitignore (skips build artifacts), outputs
  compact relative paths, and is 3-4x faster than Select-String on 10k+ file codebases. Essential for Backstage
  catalog operations (find unmapped components, search owners, locate systems by annotation). Saves 30-98% of tokens
  by extracting only matching lines instead of reading full files. Combine with -l flag to list files only (maximum
  token efficiency).
---

# Text search with ripgrep (rg)

## Core rule

**When you need to search for text content inside files, use `rg` on the command line instead of `Select-String` (PowerShell), `grep -r` (Bash), or reading entire files.**

`rg` (ripgrep) is a fast regex-aware search tool that respects `.gitignore`, outputs relative paths, and produces compact results. For an AI agent, this matters because:

- **Extracts only matching lines**: Instead of loading a 2.6 MB JSON file (~692k tokens) and searching in-context, `rg` returns just the 415 matching lines (~6k tokens) — a 98% reduction.
- **Relative paths reduce overhead**: Same benefit as `fd` — shorter paths = fewer tokens per match.
- **.gitignore awareness**: Automatically skips build artifacts, dependencies, and generated code that would add noise and consume tokens without providing value.
- **Speed at scale**: 3-4x faster than `Select-String` on 10k+ files means results arrive sooner, and the model can act on them faster.

## Prerequisites: check/install ripgrep

Check availability first:

```bash
rg --version
```

If `rg` is not installed:

| OS | Installation command |
|----|---------------------|
| **Windows (winget)** | `winget install BurntSushi.ripgrep.MSVC` |
| **Windows (manual)** | Download from https://github.com/BurntSushi/ripgrep/releases, extract `rg.exe` to a PATH directory |
| **Linux (apt)** | `sudo apt-get install -y ripgrep` |
| **Linux (yum)** | `sudo yum install -y ripgrep` |
| **macOS** | `brew install ripgrep` |

## Shell compatibility

`rg` works natively in both Bash and PowerShell — no wrapping needed:

```bash
rg "groot/sa-id" catalog/systems
```

```powershell
rg "groot/sa-id" catalog\systems
```

## Usage patterns

### Search for a string

```bash
rg "agreement_id" event.json
rg "spec.system" catalog/components
```

```powershell
rg "agreement_id" event.json
rg "spec.system" catalog\components
```

### List files containing a pattern (no content)

```bash
rg -l "type: repository" catalog/components
# → Just the file paths, one per line

rg -l "groot-sa-majeur" catalog/systems | wc -l
# → 749
```

```powershell
(rg -l "groot-sa-majeur" catalog\systems).Count
```

### Count matches per file

```bash
rg -c "agreement_id" event.json
# → event.json:415
```

### Search with regex

```bash
rg "sa-\d{4}-" catalog/systems --no-filename -o | sort -u
rg "owner: .*team" catalog/components -l
```

### Extract specific lines (like grep -o)

```bash
rg "name: (.*)" catalog/systems --no-filename -o
# Extracts just the matching lines, no file paths
```

```powershell
rg "name: (.*)" catalog\systems --no-filename -o
```

### Search with context lines

```bash
rg "spec.system" catalog/components/af-ose -A 2 -B 2
# Shows 2 lines before and after each match
```

### Restrict to specific file types

```bash
rg "TODO" -t yaml catalog
rg "agreement_id" -t json .project
```

### Include gitignored files

```bash
rg "pattern" --no-ignore              # Skip .gitignore rules
rg "pattern" -uuu                     # Unrestricted (all files)
```

### Replace text (preview)

```bash
rg "old-system" catalog/components -r "new-system"
# Shows what replacements would look like (does NOT modify files)
```

### Combine results with other commands

```bash
# Count components per project directory
rg -l "type: repository" catalog/components | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn
```

```powershell
# PowerShell equivalent
rg -l "type: repository" catalog\components | Group-Object { Split-Path (Split-Path $_) -Leaf } | Sort-Object Count -Descending
```
