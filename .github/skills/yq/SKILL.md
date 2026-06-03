---
name: yq
description: "⚡ IMPORTANT: Auto-trigger for YAML/TOML/XML. Use when: extract YAML fields, check catalog metadata, list pipeline config, audit docker-compose, extract Kubernetes manifests. Supports YAML/TOML/XML. Batch operations save 95-98% tokens. 90-99% savings vs reading full files."
---

# YAML manipulation with yq

## Core rule

**When you need to read, extract, filter or transform data from a YAML file, use `yq` on the command line instead of reading the entire file.**

`yq` is the `jq` of the YAML/TOML/XML world. It uses the same filter syntax as `jq` but on YAML files. Essential for manipulating Backstage catalog files, docker-compose, CI/CD pipelines, mkdocs.yml, etc.

## Prerequisites: check/install yq

*IMPORTANT*: Check availability first:

```bash
yq --version
```

If `yq` is not installed:

| OS | Installation command |
|----|---------------------|
| **Windows (winget)** | `winget install MikeFarah.yq` |
| **Windows (manual)** | Download `yq_windows_amd64.exe` from https://github.com/mikefarah/yq/releases, rename to `yq.exe`, place in a PATH directory (e.g. `C:\tools\yq\`) |
| **Linux** | `sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq` |
| **macOS** | `brew install yq` |

> **Warning**: there are two different `yq` tools. Use **mikefarah/yq** (https://github.com/mikefarah/yq), NOT `kislyuk/yq` (Python wrapper). The correct one shows: `yq (https://github.com/mikefarah/yq/) version v4.x`.

## Shell compatibility

`yq` works natively in both Bash and PowerShell — no wrapping needed (unlike `jq` in PowerShell):

```bash
yq '.metadata.name' catalog/systems/sa-1242-osmose.yaml
```

```powershell
yq ".metadata.name" catalog\systems\sa-1242-osmose.yaml
```

## Usage patterns

### Extract a value

```bash
yq '.metadata.name' catalog/systems/sa-1242-osmose.yaml
# → sa-1242-osmose

yq '.spec.type' catalog/components/af-ose/az-project.yaml
yq '.spec.owner' catalog/components/af-ose/az-project.yaml
```

```powershell
yq ".metadata.name" catalog\systems\sa-1242-osmose.yaml
```

### Extract an annotation

```bash
yq '.metadata.annotations."groot/sa-id"' catalog/systems/sa-1242-osmose.yaml
```

```powershell
yq '.metadata.annotations."groot/sa-id"' catalog\systems\sa-1242-osmose.yaml
```

### List values

```bash
yq '.services | keys' docker-compose.yml
yq '.stages[].stage' azure-pipelines/generate-catalog.yml
```

### Count elements

```bash
yq '.spec.targets | length' catalog/catalog-info.yaml
```

### Filter

```bash
yq 'select(.spec.type == "repository")' catalog/components/af-ose/*.yaml
```

### Modify a YAML file (in-place)

```bash
yq -i '.spec.system = "sa-1242-osmose"' catalog/components/af-ose/az-project.yaml
yq -i '.metadata.labels["managed-by"] = "automation"' entity.yaml
```

### Convert YAML to JSON

```bash
# YAML → JSON output
yq -o json docker-compose.yml

# JSON → YAML (yq can read JSON directly)
yq -P config.json

# Extract a field from a JSON file
yq -p json '.technical.sa' event.json
```

```powershell
yq -o json docker-compose.yml
yq -P config.json
```

### Batch audit of YAML files

**Example: Extract entity names from all Backstage systems**

- Input: 749 YAML files in `catalog/systems/` (~251k tokens total if read individually)
- Task: Get the name of each system
- Output: 749 names (~3.7k tokens)
- Token saving: **-98.5%** (251k → 3.7k)

```bash
# Extract name from all catalog systems
for f in catalog/systems/*.yaml; do yq '.metadata.name' "$f"; done
```

```powershell
# PowerShell equivalent
Get-ChildItem catalog\systems\*.yaml | ForEach-Object { yq ".metadata.name" $_.FullName }
```

**Example: Audit component owners in a project**

```bash
for f in catalog/components/af-ose/*.yaml; do yq '.spec.owner' "$f"; done
```

```powershell
# PowerShell equivalent
Get-ChildItem catalog\systems\*.yaml | ForEach-Object { yq ".metadata.name" $_.FullName }
```

**Why this matters**: Reading 43 agent files individually = ~12k tokens. Using `fd -x yq` = ~200 tokens (98% reduction).
