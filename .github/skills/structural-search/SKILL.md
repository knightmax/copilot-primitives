---
name: structural-search
description: >
  Synergy skill combining fd (file finder) with rg (ripgrep) for two-dimensional codebase search: structural search
  by name/path/extension AND textual search by content/pattern. Load this skill for codebase exploration ("what's in
  this project?"), dependency discovery (find imports and their locations), architecture analysis (map component
  relationships), security scanning (find secrets in specific file types), configuration audits (locate settings files
  then search their content), catalog investigations (find unmapped components = files named az-project.yaml WITHOUT
  spec.system), multi-repo navigation, or any search requiring both "where are the files?" AND "what's inside them?".
  Use even when the user says "explore this codebase", "find all references to X", "security scan", "what uses this
  dependency", "map the architecture", "locate configuration for Y" — these all need bi-dimensional search. fd answers
  structural questions (file tree, extensions, paths), rg answers content questions (text patterns, code usage). Together
  they cover 100% of deterministic search scenarios. Critical for catalog operations: find project directories (fd),
  then check their mapping status (rg). Saves 94-99% of tokens vs reading directories + files separately.
---

# Structural search — fd + rg

## Core rule

**When navigating a codebase, use two complementary search dimensions: `fd` for structural search (file names, extensions, paths) and `rg` for textual search (content, patterns, regex). Chain them when one dimension alone is insufficient.**

Each tool answers a different question:
- **fd**: "Where are the files?" (by name, extension, location)
- **rg**: "What's inside the files?" (by content, pattern)

## Prerequisites

Both tools must be available:

```bash
fd --version    # File finder
rg --version    # Ripgrep text search
```

See individual `fd` and `rg` skills for installation instructions.

## The three patterns

### Pattern 1: fd → rg (narrow then search)

Find files by structure first, then search their content:

```bash
# Find all project definitions, then search for system mappings
fd -g "az-project.yaml" catalog/components -x rg "spec.system" {}

# Find all pom.xml files, then search for a specific dependency
fd -g "pom.xml" . -x rg "spring-boot-starter-web" {}

# Find all Dockerfiles, then search for base image
fd -g "Dockerfile" . -x rg "^FROM" {}
```

```powershell
fd -g "az-project.yaml" catalog\components | ForEach-Object { rg "spec.system" $_ }
```

### Pattern 2: rg → fd (find content, explore structure)

Search content first to identify relevant directories, then explore their structure:

```bash
# Find which projects use a specific system, then list all files in those projects
rg -l "sa-1242-osmose" catalog/components | sed 's|/[^/]*$||' | sort -u | xargs -I{} fd . {}

# Find error handling patterns, then check what other files are nearby
rg -l "catch.*Exception" src/ | sed 's|/[^/]*$||' | sort -u | xargs -I{} fd -e java . {}
```

```powershell
rg -l "sa-1242-osmose" catalog\components | ForEach-Object { 
    $dir = Split-Path $_
    fd . $dir 
}
```

### Pattern 3: fd + rg parallel (two-angle coverage)

Use both simultaneously for comprehensive discovery:

```bash
# Structural: find all YAML files under a project
fd -e yaml . catalog/components/af-ose

# Textual: find all references to that project across the catalog
rg "af-ose" catalog --no-heading

# Combined: find files named like a pattern AND containing specific content
fd "osmose" catalog | xargs rg "type: repository" 2>/dev/null
```

## Usage patterns

### Codebase exploration

```bash
# Discover project structure (structural) + find entry points (textual)
fd -t f . src --max-depth 2          # File tree overview
rg "^(export )?class " src -l        # Classes/modules

# Find test files AND their tested subjects
fd -g "*test*" src                    # All test files
fd -g "*test*" src -x rg "describe|it\(" {}   # Test descriptions
```

```powershell
fd -t f . src --max-depth 2
rg "class " src -l
```

### Configuration audit

```bash
# Find all CI/CD pipeline files by name
fd -g "*.yml" .github/workflows 2>/dev/null; fd -g "*.yml" azure-pipelines 2>/dev/null

# Search for secrets/tokens across config files
fd -e yaml -e yml -e json . | xargs rg -i "token|secret|password|apikey" 2>/dev/null

# Find Kubernetes manifests AND check resource limits
fd -g "*.yaml" k8s/ | xargs rg "resources:" 2>/dev/null
```

### Catalog-specific patterns

```bash
# Find unmapped components (structural: project files, textual: missing system)
fd -g "az-project.yaml" catalog/components -x sh -c 'rg -q "spec.system" "$1" || echo "UNMAPPED: $1"' _ {}

# Find teams and their parent organization
fd -e yaml . catalog/teams -x rg "parent:" {}

# Find all components owned by a specific team
rg -l "owner: af-ose" catalog/components | head -10
fd -e yaml . catalog/components/af-ose   # Then explore that directory
```

### Dependency investigation

```bash
# Find all import/require statements for a module
rg "import.*from.*module-name" src -l     # Find importers
fd -g "module-name*" node_modules -t d    # Find the module itself

# Find Maven dependency usage
fd -g "pom.xml" . -x rg "artifactId.*hibernate" {}
rg "import.*hibernate" src -l
```

## Decision guide

| I know... | I want to find... | Use |
|-----------|------------------|-----|
| File name/extension | Files | `fd` alone |
| Text content | Files containing it | `rg` alone |
| File type + content | Specific content in specific file types | `fd` → `rg` |
| Content location | What else is in that area | `rg` → `fd` |
| Neither exactly | Everything about a topic | `fd` + `rg` parallel |
