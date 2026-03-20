---
name: batch-config-audit
description: >
  Synergy skill combining fd (file finder) with yq/jq/xq (config parsers) to audit configuration files in batch
  operations. Load this skill when extracting the same field from many config files at once: auditing Backstage
  catalog entities (check 749 systems for annotations, verify component owners, find unmapped components), scanning
  Maven projects (extract versions from all pom.xml), validating CI/CD pipelines (check cron schedules across repos),
  generating compliance reports, creating CSV exports of catalog metadata, batch-checking JSON/YAML/XML configs for
  security issues, or producing dashboards from distributed configuration. Use even when the user says "audit the
  catalog", "check all components", "list all system names", "export entity metadata", "validate pipeline configs",
  "generate a report of owners" — this is the batch audit pattern. This is the highest-impact synergy: transforms
  O(n × file_size) token cost into O(n × field_size), typically 95-99% reduction. Essential for Backstage catalog
  operations with 10k+ entities. Replaces reading files one by one with a single fd + yq/jq pipeline.
---

# Batch config audit — fd + yq/jq/xq

## Core rule

**Extract the same field from many config files with `fd` + `yq`/`jq`/`xq` instead of reading each file individually.**

Transforms token cost from O(n × file_size) to O(n × field_size) — typically **95-99% reduction**.

## Prerequisites

Both tools must be available:

```bash
fd --version    # File finder
yq --version    # YAML/XML parser (mikefarah/yq)
jq --version    # JSON parser
```

See individual `fd`, `yq`, `jq`, and `xq` skills for installation instructions.

## The pattern

```
fd [find files] | xargs -I{} [extract field from each] {}
```

Or with fd's built-in `-x` (exec) flag:

```
fd [find files] -x [extract command] {}
```

## Usage patterns

### YAML batch audit

**Example: Audit all Backstage system entities**

- Input: 749 YAML files (~335 tokens each = ~251k tokens if read individually)
- Task: Extract metadata.name from each
- Output: 749 entity names (~2k tokens for names + ~3k for fd output = ~5k total)
- Token saving: **-98%** (251k → 5k)

```bash
# Extract entity names from all 749 system files
fd -e yaml . catalog/systems -x yq '.metadata.name' {}
```

**Example: Find components without owners**

- Input: 10,862 component YAML files
- Task: List files where spec.owner is null
- Output: Subset of file paths (only the unmapped ones)
- Token saving: **-99%+** (only returns matches, not all 10k files)

```bash
fd -e yaml . catalog/components -x sh -c 'owner=$(yq ".spec.owner" "$1"); [ "$owner" = "null" ] && echo "$1"' _ {}
```

```powershell
# PowerShell equivalent
fd -e yaml . catalog\systems | ForEach-Object { yq ".metadata.name" $_ }

# With file name context
fd -e yaml . catalog\components\af-ose | ForEach-Object { 
    $name = yq ".metadata.name" $_
    $owner = yq ".spec.owner" $_
    "$name → $owner"
}
```

### JSON batch audit

```bash
# Extract version from all package.json files
fd -g "package.json" . -x jq -r '.version // "N/A"' {}

# List scripts across all package.json files
fd -g "package.json" . -x sh -c 'echo "=== $1 ==="; jq -r ".scripts | keys[]" "$1" 2>/dev/null' _ {}

# Find all tsconfig.json and check their target
fd -g "tsconfig.json" . -x jq -r '.compilerOptions.target // "not set"' {}
```

```powershell
fd -g "package.json" . | ForEach-Object { 
    $v = cmd /c "jq -r "".version // """"N/A"""""" ""$_"""
    "$_ → $v"
}
```

### XML batch audit (pom.xml)

```bash
# Extract version from all pom.xml files
fd -g "pom.xml" . -x yq -p xml -oy '.project.version' {}

# List all artifactIds across a multi-module Maven project
fd -g "pom.xml" . -x sh -c 'echo "$(yq -p xml -oy ".project.artifactId" "$1") ($(yq -p xml -oy ".project.version" "$1"))"' _ {}

# Find pom.xml files using a specific dependency
fd -g "pom.xml" . -x sh -c 'deps=$(yq -p xml -oy ".project.dependencies.dependency[].artifactId" "$1" 2>/dev/null); echo "$deps" | grep -q "spring-boot" && echo "$1"' _ {}
```

```powershell
fd -g "pom.xml" . | ForEach-Object { 
    $aid = yq -p xml -oy ".project.artifactId" $_
    $ver = yq -p xml -oy ".project.version" $_
    "$aid → $ver"
}
```

### Generate reports / CSV output

**Example: Generate a catalog report with 3 fields per component**

- Input: 500 component files (~150k tokens if read individually)
- Task: Create CSV with name, type, owner for each
- Output: CSV file (~3k tokens for the extracted data)
- Token saving: **-98%**

```bash
# Generate CSV: name,type,owner for all components
echo "name,type,owner"
fd -e yaml . catalog/components -x sh -c '
    name=$(yq ".metadata.name" "$1")
    type=$(yq ".spec.type" "$1")
    owner=$(yq ".spec.owner" "$1")
    echo "$name,$type,$owner"
' _ {}
```

```powershell
# PowerShell CSV generation
fd -e yaml . catalog\components | ForEach-Object {
    [PSCustomObject]@{
        Name  = yq ".metadata.name" $_
        Type  = yq ".spec.type" $_
        Owner = yq ".spec.owner" $_
    }
} | Export-Csv -Path report.csv -NoTypeInformation
```

### Targeted audit with fd filters

```bash
# Only audit files modified in the last 7 days
fd -e yaml . catalog/systems --changed-within 7d -x yq '.metadata.name' {}

# Audit only repository components (not projects)
fd -e yaml . catalog/components --exclude "az-project.yaml" -x yq '.spec.type' {}

# Audit only project definitions
fd -g "az-project.yaml" catalog/components -x yq '.spec.system // "UNMAPPED"' {}
```

## Why this synergy works

**Without this synergy** (reading files individually):
- Read 749 system files, each ~335 tokens = **~251k tokens total**
- The model loads 749 complete YAML files into context
- Most of each file (annotations, labels, links, etc.) is irrelevant to the task
- Token cost scales with total file size

**With this synergy** (`fd -x yq`):
- fd finds the 749 files = ~3k tokens
- yq extracts just `.metadata.name` from each = ~2k tokens (1 name × 749 files)
- **~5k tokens total** for the same information
- Token cost scales with the size of extracted fields only, not entire files

**The math:** 251k → 5k tokens = **98% reduction**. Essential for catalog operations (10k+ entities), Maven projects (hundreds of poms), or any batch extraction task.

## When to use this synergy

| Situation | Individual tools | This synergy |
|-----------|-----------------|--------------|
| Check 1 file's field | Use yq/jq directly | Overkill |
| Extract field from 10+ files | 10× read_file calls | `fd -x yq` — one command |
| Audit all 749 systems | Read all = ~251k tokens | `fd -x yq` = ~5k tokens |
| Generate catalog report | Manual file-by-file | CSV in seconds |
