# batch-config-audit — Batch Audit (fd + yq/jq/xq)

> **Role**: Extract the same field from N configuration files in a single command.
> **Combination**: `fd` (locating) + `yq` / `jq` / `xq` (extraction).
> **Savings**: 95-99% of tokens — cost proportional to field size, not file size.

## The Principle

```
Cost without synergy:  O(n × file_size)     → read N complete files
Cost with synergy:     O(n × field_size)    → extract 1 field from N files
```

This is the highest-impact synergy: it transforms an operation linear in file size into one linear in field size. On a catalog of 749 entities, we go from **~251k tokens to ~5k tokens**.

## Prerequisites

```bash
fd --version    # File search
yq --version    # YAML/XML parser (mikefarah/yq)
jq --version    # JSON parser
```

See [fd.md](fd.md), [yq.md](yq.md), [xq.md](xq.md) for installation.

## The Fundamental Pattern

### With `-x` (fd's built-in exec)

```bash
fd [find files] -x [extract field] {}
```

### With xargs

```bash
fd [find files] | xargs -I{} [extract field] {}
```

## YAML Audit

### Extract names of all entities

```bash
fd -e yaml . catalog/systems -x yq '.metadata.name' {}
```

| Metric | Value |
|--------|-------|
| Input | 749 YAML files (~335 tokens each) |
| Without synergy | ~251,000 tokens |
| With synergy | ~5,000 tokens |
| **Reduction** | **-98%** |

### Find components without an owner

```bash
fd -e yaml . catalog/components -x sh -c '
  owner=$(yq ".spec.owner" "$1")
  [ "$owner" = "null" ] && echo "$1"
' _ {}
```

### Audit owners of a project

```bash
fd -e yaml . catalog/components/af-ose -x sh -c '
  name=$(yq ".metadata.name" "$1")
  owner=$(yq ".spec.owner" "$1")
  echo "$name → $owner"
' _ {}
```

### Recently modified files

```bash
fd -e yaml . catalog/systems --changed-within 7d -x yq '.metadata.name' {}
```

## JSON Audit

### Version of all package.json files

```bash
fd -g "package.json" . -x jq -r '.version // "N/A"' {}
```

### Available scripts per project

```bash
fd -g "package.json" . -x sh -c '
  echo "=== $1 ==="
  jq -r ".scripts | keys[]" "$1" 2>/dev/null
' _ {}
```

### Check TypeScript target

```bash
fd -g "tsconfig.json" . -x jq -r '.compilerOptions.target // "not defined"' {}
```

## XML Audit (pom.xml)

### Version of each Maven module

```bash
fd -g "pom.xml" . -x yq -p xml -oy '.project.version' {}
```

### ArtifactId + version

```bash
fd -g "pom.xml" . -x sh -c '
  aid=$(yq -p xml -oy ".project.artifactId" "$1")
  ver=$(yq -p xml -oy ".project.version" "$1")
  echo "$aid ($ver)"
' _ {}
```

### Find projects using a specific dependency

```bash
fd -g "pom.xml" . -x sh -c '
  deps=$(yq -p xml -oy ".project.dependencies.dependency[].artifactId" "$1" 2>/dev/null)
  echo "$deps" | grep -q "spring-boot" && echo "$1"
' _ {}
```

## Report Generation

### CSV with 3 fields per component

```bash
echo "name,type,owner"
fd -e yaml . catalog/components -x sh -c '
  name=$(yq ".metadata.name" "$1")
  type=$(yq ".spec.type" "$1")
  owner=$(yq ".spec.owner" "$1")
  echo "$name,$type,$owner"
' _ {}
```

| Metric | Value |
|--------|-------|
| Input | 500 component files (~300 tokens each) |
| Without synergy | ~150,000 tokens |
| With synergy | ~3,000 tokens |
| **Reduction** | **-98%** |

### PowerShell export to CSV

```powershell
fd -e yaml . catalog\components | ForEach-Object {
    [PSCustomObject]@{
        Name  = yq ".metadata.name" $_
        Type  = yq ".spec.type" $_
        Owner = yq ".spec.owner" $_
    }
} | Export-Csv -Path report.csv -NoTypeInformation
```

## When to Use This Synergy

| Situation | Recommended Approach |
|-----------|---------------------|
| 1 file, 1 field | `yq` / `jq` directly |
| 1 file, multiple fields | `yq` / `jq` directly |
| 10+ files, same field | **This synergy** (`fd -x yq`) |
| 100+ files, same field | **This synergy** (mandatory) |
| CSV report generation | **This synergy** |
| Batch compliance audit | **This synergy** |

## Why It Works

**Without synergy** (individual reads):
- The agent calls `read_file` 749 times
- Each call loads the full file (~335 tokens)
- Most content (annotations, labels, links) is useless
- Total cost: **~251,000 tokens**

**With synergy** (`fd -x yq`):
- `fd` finds the 749 files (~3k tokens)
- `yq` extracts `.metadata.name` from each (~2k tokens)
- Only the requested field passes through the context
- Total cost: **~5,000 tokens**

The cost no longer depends on file size, but on the size of the extracted fields.

← [Back to README](README.md)
