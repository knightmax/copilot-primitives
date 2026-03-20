# structural-search — Two-Dimensional Search (fd + rg)

> **Role**: Combine structural search (file names/paths) and textual search (content) for complete code exploration.
> **Combination**: `fd` (structural dimension) + `rg` (textual dimension).
> **Savings**: 94-99% of tokens vs reading directories + files separately.

## The Principle

Each tool answers a different question:

| Dimension | Tool | Question |
|-----------|------|----------|
| **Structural** | `fd` | "Where are the files?" (by name, extension, path) |
| **Textual** | `rg` | "What's in the files?" (by content, pattern) |

Alone, each covers 50% of cases. Combined, they cover **100% of deterministic searches**.

## Prerequisites

```bash
fd --version
rg --version
```

See [fd.md](fd.md) and [rg.md](rg.md) for installation.

## The Three Patterns

### Pattern 1: fd → rg (filter then search)

Find files by their structure, then search within their content.

```bash
# Find project files, then check system mapping
fd -g "az-project.yaml" catalog/components -x rg "spec.system" {}

# Find pom.xml files, then search for a dependency
fd -g "pom.xml" . -x rg "spring-boot-starter-web" {}

# Find Dockerfiles, then extract the base image
fd -g "Dockerfile" . -x rg "^FROM" {}
```

**When to use**: you know the file type, you're looking for specific content inside.

### Pattern 2: rg → fd (search then explore)

Search for content to identify directories, then explore their structure.

```bash
# Find projects using a system, then list all their files
rg -l "sa-1242-osmose" catalog/components \
  | sed 's|/[^/]*$||' | sort -u \
  | xargs -I{} fd . {}

# Find files with error handling, then see the context
rg -l "catch.*Exception" src/ \
  | sed 's|/[^/]*$||' | sort -u \
  | xargs -I{} fd -e java . {}
```

**When to use**: you know a content pattern, you want to understand the surrounding environment.

### Pattern 3: fd + rg in parallel (full coverage)

Use both angles simultaneously for complete exploration.

```bash
# Structural: YAML files of a project
fd -e yaml . catalog/components/af-ose

# Textual: references to this project across the catalog
rg "af-ose" catalog --no-heading

# Combined: files named like a pattern AND containing text
fd "osmose" catalog | xargs rg "type: repository" 2>/dev/null
```

**When to use**: initial exploration, you don't know exactly what you're looking for.

## Use Cases

### Codebase Exploration

```bash
# Project structure (overview)
fd -t f . src --max-depth 2

# Entry points (classes/modules)
rg "^(export )?class " src -l

# Test files + their descriptions
fd -g "*test*" src -x rg "describe\|it(" {} 2>/dev/null
```

### Configuration Audit

```bash
# Find CI/CD pipelines
fd -g "*.yml" .github/workflows 2>/dev/null
fd -g "*.yml" azure-pipelines 2>/dev/null

# Security scan in config files
fd -e yaml -e yml -e json . | xargs rg -i "token|secret|password|apikey" 2>/dev/null

# Check Kubernetes resource limits
fd -g "*.yaml" k8s/ | xargs rg "resources:" 2>/dev/null
```

### Catalog Audit (Backstage)

```bash
# Find unmapped components (project file without spec.system)
fd -g "az-project.yaml" catalog/components -x sh -c '
  rg -q "spec.system" "$1" || echo "UNMAPPED: $1"
' _ {}

# Find teams and their parent organization
fd -e yaml . catalog/teams -x rg "parent:" {}

# Components of a specific team
rg -l "owner: af-ose" catalog/components | head -10
fd -e yaml . catalog/components/af-ose
```

### Dependency Investigation

```bash
# Find importers of a module
rg "import.*from.*module-name" src -l

# Find the module itself
fd -g "module-name*" node_modules -t d

# Maven dependency usage
fd -g "pom.xml" . -x rg "artifactId.*hibernate" {}
rg "import.*hibernate" src -l
```

## Decision Guide

```
I know...                        → I use...
│
├── File name/extension          → fd alone
├── Content I'm searching for    → rg alone
├── Type AND content             → fd → rg (Pattern 1)
├── Content, I want the context  → rg → fd (Pattern 2)
└── Nothing specific             → fd + rg in parallel (Pattern 3)
```

| I know... | I want to find... | Tool |
|-----------|-------------------|------|
| Name/extension | Files | `fd` alone |
| Text content | Files containing it | `rg` alone |
| File type + content | Specific content in a precise type | `fd` → `rg` |
| Content location | The surrounding structure | `rg` → `fd` |
| Nothing specific | Everything about a topic | `fd` + `rg` in parallel |

## Comparison with the Naive Approach

### Finding unmapped components among 500 files

| Approach | Steps | Tokens |
|----------|-------|--------|
| Naive agent | `list_dir` + `read_file` × 500 | ~150,000 |
| `fd` + `rg` | 1 command | ~1,000 |
| **Reduction** | | **-99%** |

### Exploring a new project

| Approach | Steps | Tokens |
|----------|-------|--------|
| Naive agent | Recursive `list_dir` + selective `read_file` | ~50,000 |
| `fd --max-depth 2` + `rg "class\|function\|export" -l` | 2 commands | ~3,000 |
| **Reduction** | | **-94%** |

← [Back to README](README.md)
