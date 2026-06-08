---
name: fd
description: "⚡ IMPORTANT: Auto-trigger for file discovery. Use when: find files, locate configs, list by extension, what files exist, explore directory structure, search for pom.xml/config files. Regex-aware, .gitignore-respecting. 40-60% token savings vs traditional find/Get-ChildItem."
---

# File search with fd

## Core rule

**When you need to find files by name, extension, or pattern, use `fd` on the command line instead of `Get-ChildItem -Recurse` (PowerShell) or `find` (Bash).**

`fd` outputs relative paths by default, respects `.gitignore` automatically, and uses an intuitive regex-aware syntax. For an AI agent, this matters because:

- **Relative paths consume fewer tokens**: `catalog/systems/sa-1242-osmose.yaml` (36 chars) vs `C:\Workspace\caas\developerhub-catalog\catalog\systems\sa-1242-osmose.yaml` (73 chars) — 50% reduction per file. Over 13,000 files, this saves ~120k tokens.
- **.gitignore awareness prevents noise**: Without it, you'd see thousands of irrelevant files (node_modules, build outputs, .git history) that waste tokens and obscure the actual project structure.
- **Faster iteration**: The model receives results in fewer tokens, processes them faster, and can act on them sooner.

## Prerequisites: check/install fd

*IMPORTANT*: Check availability first:

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
