---
name: snip-filters-setup
description: "Shared installer for snip filter profiles. Use when creating or maintaining snip-* skills that need to install YAML filters for a CLI and avoid duplicated setup scripts."
argument-hint: "Use from other snip-* skills to install filters into snip global config."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip Filters Setup — Shared Installer for snip-* Skills

## Purpose

Provides reusable setup scripts used by tool-specific snip skills (`snip-jvm`, `snip-dotnet`, `snip-npm`, etc.) to install filter files into global snip config.

This skill centralizes:
- snip availability checks
- filter directory creation
- YAML filter copy logic
- optional command alias generation (`mvn` -> `mvnd`)

## Scripts

- PowerShell: `./scripts/install-filters.ps1`
- Bash: `./scripts/install-filters.sh`

## Parameters

Required:
- source directory containing `.yaml` filters
- display label for logs (`JVM`, `.NET`, `npm`, ...)

Optional:
- `alias-from` and `alias-to` to duplicate filters for an exact command alias
- `legacy-file-to-remove` for one-off cleanup

## Invocation Contract for Derived Skills

When a derived skill (`snip-jvm`, `snip-dotnet`, `snip-npm`, ...) needs setup, it should:
1. delegate to this skill
2. pass only its profile values (`source-dir`, `tool-label`, optional alias/legacy cleanup)
3. avoid duplicating script blocks locally

Canonical commands live here.

PowerShell template:

```powershell
& '.\.github\skills\snip-filters-setup\scripts\install-filters.ps1' `
	-SourceDir '<source-dir>' `
	-ToolLabel '<tool-label>' `
	[-AliasFrom '<alias-from>'] `
	[-AliasTo '<alias-to>'] `
	[-LegacyFileToRemove '<legacy-file-to-remove>']
```

Bash template:

```bash
bash .github/skills/snip-filters-setup/scripts/install-filters.sh \
	--source-dir <source-dir> \
	--tool-label <tool-label> \
	[--alias-from <alias-from>] \
	[--alias-to <alias-to>] \
	[--legacy-file-to-remove <legacy-file-to-remove>]
```

## Standard Pattern for Derived Skills

Derived skills do not need setup scripts.

Each tool-specific skill should keep only:
1. `SKILL.md`
2. `filters/*.yaml`

Use shared scripts directly:
- PowerShell: `./scripts/install-filters.ps1 -SourceDir <path> -ToolLabel <name> ...`
- Bash: `./scripts/install-filters.sh --source-dir <path> --tool-label <name> ...`

## Why This Exists

snip setup scripts are almost identical across skills. This skill removes duplication while preserving tool-specific behavior.
