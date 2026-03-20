# fd — File Search

> **Role**: Find files and directories by name, extension, or path.
> **Replaces**: `find` (Bash), `Get-ChildItem -Recurse` (PowerShell).
> **Savings**: 40-60% fewer tokens thanks to relative paths and `.gitignore` filtering.

## Why fd for AI Agents

`fd` solves two major token consumption problems:

1. **Relative paths by default** — `catalog/systems/osmose.yaml` (36 characters) instead of `/home/user/workspace/project/catalog/systems/osmose.yaml` (73 characters). Over 13,000 files, that's ~120k tokens saved.

2. **Automatic `.gitignore` filtering** — No `node_modules/`, `target/`, `.git/`, `build/`. Eliminates thousands of irrelevant files without configuration.

## Installation

| OS | Command |
|----|---------|
| **macOS** | `brew install fd` |
| **Linux (apt)** | `sudo apt-get install -y fd-find` |
| **Linux (yum)** | `sudo yum install -y fd-find` |
| **Windows (winget)** | `winget install sharkdp.fd` |

> **Linux note**: The Debian/Ubuntu package installs as `fdfind` (name conflict). Create an alias: `alias fd=fdfind`.

Verify:

```bash
fd --version
```

## Basic Syntax

```
fd [pattern] [path] [options]
```

- `pattern` — Regex by default, glob with `-g`
- `path` — Starting directory (`.` by default)
- Results are always relative paths

## Use Cases

### Find by extension

```bash
fd -e yaml . catalog/systems          # All YAML in catalog/systems
fd -e json . scripts                  # All JSON in scripts
fd -e yaml -e json . catalog          # YAML and JSON combined
```

### Find by pattern

```bash
fd osmose catalog
# → catalog/teams/osmose-osmose-team.yaml
# → catalog/systems/sa-1242-osmose.yaml
```

### Find by exact name (glob)

```bash
fd -g "az-project.yaml" catalog/components
fd -g "pom.xml" .
fd -g "Dockerfile" .
```

### Filter by type

```bash
fd -t f osmose catalog     # Files only
fd -t d osmose catalog     # Directories only
```

### Count results

```bash
fd -e yaml . catalog/systems | wc -l
# → 749
```

### Limit depth

```bash
fd -t f . src --max-depth 2    # Structure overview
```

### Exclude directories

```bash
fd -e yaml . catalog --exclude teams --exclude users
```

### Include ignored files

```bash
fd -e log . --unrestricted       # Ignores .gitignore
fd -e yaml . --no-ignore         # Same
```

### Execute a command on each result

```bash
fd -e yaml . catalog/systems -x yq '.metadata.name' {}
fd -g "pom.xml" . -x yq -p xml -oy '.project.version' {}
```

> This is the entry point to the [batch-config-audit](batch-config-audit.md) synergy.

## Comparison: fd vs Alternatives

### Searching 749 YAML files

| Tool | Output | Estimated Tokens |
|------|--------|-----------------|
| `find catalog/systems -name "*.yaml"` | Absolute paths, includes `.git` | ~35k |
| `Get-ChildItem -Recurse -Filter *.yaml` | Verbose objects, absolute paths | ~65k |
| `fd -e yaml . catalog/systems` | Relative paths, clean | ~18k |

### Exploring a 13,000-file directory

| Tool | Files Returned | Noise |
|------|---------------|-------|
| `find .` | ~40,000 (includes node_modules, .git) | High |
| `fd .` | ~13,000 (respects .gitignore) | Minimal |

## Most Useful Options

| Option | Effect |
|--------|--------|
| `-e ext` | Filter by extension |
| `-g "pattern"` | Glob search (not regex) |
| `-t f` / `-t d` | Files only / directories only |
| `--max-depth N` | Limit search depth |
| `--exclude dir` | Exclude a directory |
| `-x cmd {}` | Execute a command on each result |
| `--changed-within Xd` | Files modified within the last X days |
| `--no-ignore` | Include `.gitignore`-ignored files |

## Combinations with Other Tools

| Combination | Usage | See |
|-------------|-------|-----|
| `fd` + `yq` / `jq` / `xq` | Batch extraction of config fields | [batch-config-audit](batch-config-audit.md) |
| `fd` + `rg` | Two-dimensional search (structure + content) | [structural-search](structural-search.md) |
| `fd` + `wc -l` | File counting | — |
| `fd` + `xargs head` | Preview first lines | — |

← [Back to README](README.md)
