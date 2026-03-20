# snip + AI Agent Workflow

## Why use snip in an AI environment

When an AI agent runs build/test commands, raw CLI output is often much larger than needed.

Main issues without filtering:
- Token waste: long logs consume context budget quickly
- Signal dilution: useful failures are mixed with low-value noise
- Slower iterations: more output to parse means slower diagnosis
- Higher error risk: critical lines can be missed in verbose output

`snip` solves this by filtering command output to keep high-signal lines.

In this repository, `snip` is used as a first-class operational rule for agent-driven CLI execution.

## What snip does

`snip` wraps a CLI command and applies YAML filter profiles.

Examples:
- `snip mvn test`
- `snip dotnet build`
- `snip npm test`

Typical effects:
- Keep: failures, errors, warnings, build/test summaries
- Remove: downloads, verbose info lines, blank noise, repetitive progress lines

Observed objective in this setup:
- Reduce output volume by about 80-95%
- Preserve debugging-relevant information

## Critical runtime behavior (important for AI agents)

`snip` is buffered:
- It prints nothing while the wrapped command is still running
- It emits output only after the command exits

So, empty output during execution is normal.

Correct execution pattern for agents:
1. Start command in background (`isBackground=true`)
2. Poll with `get_terminal_output`
3. Keep polling if output is empty
4. Interpret output only once command completes

Do not treat empty output as failure.
Do not fallback to bare CLI because output is temporarily empty.

## Skill architecture in this repo

The skill design is intentionally layered to avoid duplication.

### 1) `snip-core`
Role:
- Verify `snip` installation
- Prepare global snip filters directory

Does not:
- Install tool-specific filters

Scripts:
- PowerShell: `.github/skills/snip-core/scripts/setup-snip.ps1`
- Bash: `.github/skills/snip-core/scripts/setup-snip.sh`

### 2) `snip-filters-setup`
Role:
- Shared installer for filter profiles (`*.yaml`)
- Common logic used by all tool-specific snip skills

Handles:
- `snip` availability check
- Global filters directory creation
- Copy of YAML filters
- Optional command alias generation (for exact command matching), e.g. `mvn` -> `mvnd`

Scripts:
- PowerShell: `.github/skills/snip-filters-setup/scripts/install-filters.ps1`
- Bash: `.github/skills/snip-filters-setup/scripts/install-filters.sh`

### 3) Tool-specific skills
- `snip-jvm`
- `snip-dotnet`
- `snip-npm`

Role:
- Define operational usage rules for each CLI family
- Provide each skill's `filters/*.yaml` profiles
- Delegate filter installation to `snip-filters-setup`

These skills no longer carry local setup scripts.

## Triggering and usage model

Skills can be activated in two ways:
- Automatically by model relevance (based on skill description and prompt intent)
- Manually as slash commands

### Automatic trigger (expected flow)

1. User asks to run a command in a tool family (`mvn`, `dotnet`, `npm`)
2. Matching tool-specific skill is loaded (`snip-jvm`, `snip-dotnet`, or `snip-npm`)
3. Skill enforces rule: prefix command with `snip`
4. If setup is missing:
   - Use `snip-core` for base installation check
   - Use `snip-filters-setup` to install relevant filter profiles
5. Command executes with filtered output

### Manual trigger

You can invoke skills explicitly with slash commands, then follow their setup/usage instructions.

## End-to-end chaining of skills

Standard chain used in this repo:
1. `snip-core` (base check/install readiness)
2. `snip-filters-setup` (shared profile installer)
3. One derived skill (`snip-jvm`, `snip-dotnet`, `snip-npm`) for command execution rules and filters

Practical interpretation:
- `snip-core` = foundation
- `snip-filters-setup` = shared installer engine
- Derived skill = domain policy + filter set

## Exact matching and alias design

`snip` command matching is exact.

Implication:
- A filter matching `mvn` does not automatically match `mvnd`

Solution used here:
- Shared installer can generate alias variants (`mvn` -> `mvnd`) for JVM profiles

This keeps one canonical filter family while supporting multiple binaries.

## Setup examples

### Core setup

PowerShell:
```powershell
& '.\.github\skills\snip-core\scripts\setup-snip.ps1'
```

Bash:
```bash
bash .github/skills/snip-core/scripts/setup-snip.sh
```

### Install JVM filters via shared installer

PowerShell:
```powershell
& '.\.github\skills\snip-filters-setup\scripts\install-filters.ps1' `
  -SourceDir '.\.github\skills\snip-jvm\filters' `
  -ToolLabel 'JVM' `
  -AliasFrom 'mvn' `
  -AliasTo 'mvnd' `
  -LegacyFileToRemove 'mvnd-mvn.yaml'
```

Bash:
```bash
bash .github/skills/snip-filters-setup/scripts/install-filters.sh \
  --source-dir .github/skills/snip-jvm/filters \
  --tool-label JVM \
  --alias-from mvn \
  --alias-to mvnd \
  --legacy-file-to-remove mvnd-mvn.yaml
```

### Install .NET filters via shared installer

Bash:
```bash
bash .github/skills/snip-filters-setup/scripts/install-filters.sh \
  --source-dir .github/skills/snip-dotnet/filters \
  --tool-label .NET
```

### Install npm filters via shared installer

Bash:
```bash
bash .github/skills/snip-filters-setup/scripts/install-filters.sh \
  --source-dir .github/skills/snip-npm/filters \
  --tool-label npm
```

## Day-to-day agent rules

Operational rules for AI-assisted execution:
- Always prefix `mvn`, `mvnd`, `dotnet`, `npm` commands with `snip`
- Use background execution for long commands
- Poll for completion; do not assume failure on empty output
- Keep filter logic centralized in shared setup + derived `filters/*.yaml`
- Avoid duplicate setup scripts in derived skills

## Maintenance guide

When adding a new tool family (`snip-xyz`):
1. Create `.github/skills/snip-xyz/SKILL.md`
2. Add `.github/skills/snip-xyz/filters/*.yaml`
3. Reuse `snip-filters-setup` scripts for installation
4. If multiple binaries are needed, configure alias generation in shared installer arguments
5. Document trigger keywords clearly in the new skill description

## Outcome

This architecture provides:
- Lower token usage in AI loops
- Better signal-to-noise in terminal diagnostics
- Reusable setup logic with minimal duplication
- Clear skill chaining for predictable behavior
