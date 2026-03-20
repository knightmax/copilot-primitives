# yq — YAML / TOML Extraction

> **Role**: Extract, filter, and transform YAML and TOML data from the command line.
> **Replaces**: Full YAML file reads by the agent.
> **Savings**: 90-98% of tokens — surgical field extraction.

## Why yq for AI Agents

A Backstage catalog YAML file is ~335 tokens. The agent often needs only a single field (`metadata.name`, `spec.owner`...). With `yq`, it extracts that field in ~5 tokens instead of loading all 335.

Over 749 files:
- **Without yq**: 749 × 335 = ~251,000 tokens
- **With yq**: 749 × 5 = ~3,700 tokens
- **Reduction: -98.5%**

## Installation

| OS | Command |
|----|---------|
| **macOS** | `brew install yq` |
| **Linux** | `sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq` |
| **Windows (winget)** | `winget install MikeFarah.yq` |

> **Warning**: use **mikefarah/yq** (Go), NOT `kislyuk/yq` (Python). The correct version shows: `yq (https://github.com/mikefarah/yq/) version v4.x`.

Verify:

```bash
yq --version
```

## Basic Syntax

```
yq 'expression' file.yaml
```

- The expression uses jq syntax
- Output is YAML by default, `-o json` for JSON

## Use Cases

### Extract a value

```bash
yq '.metadata.name' entity.yaml
# → sa-1242-osmose

yq '.spec.type' component.yaml
yq '.spec.owner' component.yaml
```

### Extract an annotation

```bash
yq '.metadata.annotations."groot/sa-id"' system.yaml
```

### List values

```bash
yq '.services | keys' docker-compose.yml
yq '.stages[].stage' azure-pipelines.yml
yq '.jobs[].name' .github/workflows/ci.yml
```

### Count elements

```bash
yq '.spec.targets | length' catalog-info.yaml
yq '.services | length' docker-compose.yml
```

### Filter with select

```bash
yq 'select(.spec.type == "repository")' component.yaml
yq '.dependencies[] | select(.scope == "test")' deps.yaml
```

### Modify a file (in-place)

```bash
yq -i '.spec.system = "sa-1242-osmose"' component.yaml
yq -i '.metadata.labels["managed-by"] = "automation"' entity.yaml
```

### Convert between formats

```bash
# YAML → JSON
yq -o json docker-compose.yml

# JSON → YAML
yq -P config.json

# Extract a field from a JSON file
yq -p json '.technical.sa' event.json
```

## Batch Processing

One of the most powerful patterns: extracting the same field from N files.

### With a loop

```bash
for f in catalog/systems/*.yaml; do
  yq '.metadata.name' "$f"
done
```

### With fd (recommended)

```bash
fd -e yaml . catalog/systems -x yq '.metadata.name' {}
```

> See [batch-config-audit](batch-config-audit.md) for advanced patterns.

### Owner audit

```bash
fd -e yaml . catalog/components -x sh -c '
  name=$(yq ".metadata.name" "$1")
  owner=$(yq ".spec.owner" "$1")
  echo "$name → $owner"
' _ {}
```

## Supported File Types

| Type | Examples | Flag |
|------|----------|------|
| **YAML** | Backstage catalog, docker-compose, GitHub Actions, K8s manifests, mkdocs.yml | (none, default) |
| **TOML** | Cargo.toml, pyproject.toml | `-p toml` |
| **JSON** | package.json, tsconfig.json | `-p json` |
| **XML** | pom.xml, .csproj, web.xml | `-p xml` (see [xq](xq.md)) |

## Shell Compatibility

```bash
# Bash — single quotes for filters
yq '.metadata.name' entity.yaml
yq '.spec.owner // "N/A"' entity.yaml
```

```powershell
# PowerShell — double quotes
yq ".metadata.name" entity.yaml

# For filters with | (pipe), wrap in cmd /c
cmd /c 'yq ".dependencies[] | select(.scope == \"test\")" deps.yaml'
```

## Most Useful Options

| Option | Effect |
|--------|--------|
| `-o json` | JSON output |
| `-o yaml` | YAML output (default) |
| `-P` | Pretty print (indented YAML) |
| `-p format` | Input parser (`json`, `toml`, `xml`) |
| `-i` | In-place modification |
| `// "default"` | Default value if field is missing |

## Combinations with Other Tools

| Combination | Usage | See |
|-------------|-------|-----|
| `fd` + `yq` | Batch extraction from N YAML files | [batch-config-audit](batch-config-audit.md) |
| `yq -p xml` | XML processing (alias xq) | [xq](xq.md) |
| `yq -p json` | Lightweight alternative to `jq` | — |

← [Back to README](README.md)
