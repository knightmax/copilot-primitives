---
name: fd
description: >
  Use fd to find files and directories from the command line instead of Get-ChildItem -Recurse (PowerShell) or
  find (Bash). Load this skill whenever you need to list files, search by filename pattern, filter by extension,
  explore project structure, locate specific files (az-project.yaml, pom.xml, *.test.js), count files of a type,
  or navigate multi-directory codebases. Use even when the user doesn't say "fd" — phrases like "list all YAML
  files", "find the project definitions", "how many components", "show me the repository files", "locate the
  pom.xml", "what's in the catalog/systems directory" all trigger this skill. fd automatically respects .gitignore
  (skips node_modules, build output, .git), outputs relative paths (shorter = fewer tokens), and supports regex
  patterns. Critical for Backstage catalogs (13k+ files), multi-repo navigation, and catalog exploration. Saves
  40-60% of tokens vs verbose absolute paths from Get-ChildItem. Essential first step before batch processing
  with yq/jq — fd locates files, then pipe to extractors.
---

# File search with fd

## Core rule

**When you need to find files by name, extension, or pattern, use `fd` on the command line instead of `Get-ChildItem -Recurse` (PowerShell) or `find` (Bash).**

`fd` outputs relative paths by default, respects `.gitignore` automatically, and uses an intuitive regex-aware syntax. For an AI agent, this matters because:

- **Relative paths consume fewer tokens**: `catalog/systems/sa-1242-osmose.yaml` (36 chars) vs `C:\Workspace\caas\developerhub-catalog\catalog\systems\sa-1242-osmose.yaml` (73 chars) — 50% reduction per file. Over 13,000 files, this saves ~120k tokens.
- **.gitignore awareness prevents noise**: Without it, you'd see thousands of irrelevant files (node_modules, build outputs, .git history) that waste tokens and obscure the actual project structure.
- **Faster iteration**: The model receives results in fewer tokens, processes them faster, and can act on them sooner.

## Prerequisites: check/install fd

Check availability first:

```bash
fd --version
```

If `fd` is not installed:

| OS | Installation command |
|----|---------------------|
| **Windows (winget)** | `winget install sharkdp.fd` |
| **Windows (manual)** | Download from https://github.com/sharkdp/fd/releases, extract `fd.exe` to a PATH directory |
| **Linux (apt)** | `sudo apt-get install -y fd-find` (binary is `fdfind`, alias to `fd`) |
| **Linux (yum)** | `sudo yum install -y fd-find` |
| **macOS** | `brew install fd` |

> **Note on Linux**: The Debian/Ubuntu package installs as `fdfind` to avoid conflict with another `fd` command. Create an alias: `alias fd=fdfind`.

## Shell compatibility

`fd` works natively in both Bash and PowerShell — no wrapping needed:

```bash
fd -e yaml . catalog/systems
```

```powershell
fd -e yaml . catalog\systems
```

## Usage patterns

### Find files by extension

```bash
fd -e yaml . catalog/systems
fd -e json . scripts
fd -e yaml -e json . catalog    # Multiple extensions
```

```powershell
fd -e yaml . catalog\systems
```

### Find files matching a pattern

```bash
fd osmose catalog
# Returns: catalog/teams/osmose-osmose-team.yaml, catalog/systems/sa-1242-osmose.yaml, ...
```

```powershell
fd osmose catalog
```

### Find only files or only directories

```bash
fd -t f osmose catalog     # Files only
fd -t d osmose catalog     # Directories only
```

### Find by exact name

```bash
fd -g "az-project.yaml" catalog/components
# All project definition files across subdirectories
```

### Count files

```bash
fd -e yaml . catalog/systems | wc -l
# → 749
```

```powershell
(fd -e yaml . catalog\systems).Count
# → 749
```

### List files then process

```bash
# Find all project definitions
fd -g "az-project.yaml" catalog/components | head -10

# Pass file list to another command
fd -e yaml . catalog/systems | xargs head -1
```

```powershell
# PowerShell pipeline
fd -e yaml . catalog\systems | ForEach-Object { Get-Content $_ -TotalCount 1 }
```

### Include gitignored files

```bash
fd -e log . --unrestricted       # -u ignores .gitignore
fd -e yaml . --no-ignore         # --no-ignore skips ignore rules
```

### Exclude specific directories

```bash
fd -e yaml . catalog --exclude teams --exclude users
```
