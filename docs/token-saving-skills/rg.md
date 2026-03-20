# rg — Text Search (ripgrep)

> **Role**: Search for text or regex patterns inside files.
> **Replaces**: `grep -r` (Bash), `Select-String` (PowerShell), full file reads.
> **Savings**: 30-98% fewer tokens — only matching lines are returned.

## Why rg for AI Agents

The default reflex of an agent when asked to "find X in the code" is to read files one by one. With `rg`, the agent gets the relevant lines directly:

- **Surgical extraction** — A 2.6 MB JSON file (~692k tokens) containing 415 occurrences of a term → `rg` returns those 415 lines (~6k tokens). Reduction: **98%**.
- **Relative paths** — Same benefit as `fd`, fewer tokens per result.
- **`.gitignore` filtering** — No searching in build artifacts, dependencies, or generated files.
- **3-4× faster** than `Select-String` on large projects (10k+ files).

## Installation

| OS | Command |
|----|---------|
| **macOS** | `brew install ripgrep` |
| **Linux (apt)** | `sudo apt-get install -y ripgrep` |
| **Linux (yum)** | `sudo yum install -y ripgrep` |
| **Windows (winget)** | `winget install BurntSushi.ripgrep.MSVC` |

Verify:

```bash
rg --version
```

## Basic Syntax

```
rg "pattern" [path] [options]
```

- `pattern` — Regex by default
- `path` — Directory or file to search (`.` by default)
- Output: `file:line:content` by default

## Use Cases

### Search for a string

```bash
rg "agreement_id" event.json
rg "spec.system" catalog/components
rg "TODO" src/
```

### List files only (no content)

```bash
rg -l "type: repository" catalog/components
# → Just file paths, one per line
```

> The `-l` flag is the most token-efficient mode: it returns **only file names**.

### Count occurrences

```bash
rg -c "agreement_id" event.json
# → event.json:415
```

### Search with regex

```bash
rg "sa-\d{4}-" catalog/systems --no-filename -o    # Extract patterns
rg "owner: .*team" catalog/components -l             # Files with team owners
rg "^FROM" Dockerfile                                # Lines starting with FROM
```

### Extract only matching text

```bash
rg "name: (.*)" catalog/systems --no-filename -o
# → name: sa-1242-osmose
# → name: sa-3456-atlas
```

### Show context (surrounding lines)

```bash
rg "spec.system" catalog/components/af-ose -A 2 -B 2
# 2 lines before and after each match
```

### Restrict by file type

```bash
rg "TODO" -t yaml catalog          # YAML files only
rg "agreement_id" -t json .        # JSON files only
rg "import" -t java src/           # Java files only
```

### Preview a replacement (without modifying)

```bash
rg "old-system" catalog/components -r "new-system"
# Shows what the replacement would look like — does NOT modify files
```

### Include ignored files

```bash
rg "pattern" --no-ignore      # Ignores .gitignore rules
rg "pattern" -uuu             # Fully unrestricted mode
```

## Comparison: rg vs Alternatives

### Searching a 2.6 MB JSON file

| Approach | Tokens Consumed |
|----------|----------------|
| `read_file` (full read) | ~692,000 |
| `rg "agreement_id" event.json` (415 matches) | ~6,000 |
| **Reduction** | **-98%** |

### Searching 10,000 component files

| Approach | Tokens Consumed |
|----------|----------------|
| Sequential reads by the agent | ~3,000,000+ |
| `rg -l "owner: team-x" catalog/components` | ~2,000 |
| **Reduction** | **-99%+** |

## Most Useful Options

| Option | Effect |
|--------|--------|
| `-l` | List files only (no content) |
| `-c` | Count matches per file |
| `-o` | Show only matching text |
| `--no-filename` | Remove file names from output |
| `-A N` / `-B N` | Show N lines after / before |
| `-t type` | Restrict to a file type (yaml, json, java...) |
| `-i` | Case-insensitive search |
| `-r "replacement"` | Replacement preview (read-only) |
| `--no-ignore` | Include ignored files |
| `-w` | Whole word matches only |

## Combinations with Other Tools

| Combination | Usage | See |
|-------------|-------|-----|
| `fd` → `rg` | Find files then search inside | [structural-search](structural-search.md) |
| `rg` → `fd` | Identify directories then explore their structure | [structural-search](structural-search.md) |
| `rg -l` + `wc -l` | Count files containing a pattern | — |
| `rg -l` + `xargs` | Chain with other commands | — |

## Advanced Use Cases

### Security audit

```bash
# Search for potential secrets in code
rg -i "password|secret|apikey|token" src/ -l
```

### Count by directory

```bash
# Count components per project
rg -l "type: repository" catalog/components \
  | sed 's|/[^/]*$||' | sort | uniq -c | sort -rn
```

### Multi-pattern search

```bash
rg "import.*hibernate|@Entity|@Table" src/ -l
```

← [Back to README](README.md)
