# snip + AI Agent Workflow

## Why use snip in an AI environment

When an AI agent runs build/test commands, raw CLI output is often much larger than needed.

Main issues without filtering:
- Token waste: long logs consume context budget quickly
- Signal dilution: useful failures are mixed with low-value noise
- Slower iterations: more output to parse means slower diagnosis
- Higher error risk: critical lines can be missed in verbose output

`snip` solves this by filtering command output to keep high-signal lines.

## What snip does

`snip` wraps a CLI command and applies YAML filter profiles.

Examples:
- `snip mvn test`
- `snip dotnet build`
- `snip npm test`
- `snip git log` (built-in filter)

Typical effects:
- Keep: failures, errors, warnings, build/test summaries
- Remove: downloads, verbose info lines, blank noise, repetitive progress lines
- Reduce output volume by 80-99%

**Graceful degradation**: if no filter matches a command, snip passes the output through unchanged. This makes it safe to proxy **every** command through snip.

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
Do not fall back to bare CLI because output is temporarily empty.

## Skill architecture

Two skills, clearly separated by concern:

```
snip-install          snip-auto
(one-time setup)      (every command)
     │                     │
     ▼                     ▼
Install snip CLI      Rule: always prefix
Deploy all filters    with "snip <cmd>"
(mvn, npm, dotnet)    Graceful degradation
Generate aliases      if no filter matches
(mvn → mvnd)
```

### 1) `snip-install`

Role:
- Verify `snip` installation
- Deploy all technology filters to `~/.config/snip/filters/`
- Generate command aliases (e.g. `mvn` → `mvnd`)

Filters are organized by technology in subdirectories:
```
.github/skills/snip-install/filters/
├── mvn/       (6 filters: mvn, test, compile, package, install, verify)
├── npm/       (5 filters: npm, test, install, run, ci)
└── dotnet/    (2 filters: build, test)
```

One command installs everything:
```bash
bash .github/skills/snip-install/scripts/install.sh
```

### 2) `snip-auto`

Role:
- Instruct the agent to **always** prefix terminal commands with `snip`
- No allow-list — applies universally to every command
- Guard against double-prefixing (`snip snip ...`)

This skill is ultra-lightweight (loaded frequently, minimal context cost).

## Why universal proxy (no command list)

snip has built-in graceful degradation: if no filter matches, the command output passes through unchanged. This means:

- Proxying a command without a filter = zero cost (output is identical)
- Token tracking still records the command
- Adding a new technology = just drop a filter YAML file, no skill changes needed

A hardcoded command list (like in hook-based approaches) would require maintenance every time a new tool is supported. The universal proxy approach is maximally extensible.

## Exact matching and alias design

`snip` command matching is exact: a filter for `mvn` does **not** match `mvnd`.

The install script auto-generates `mvnd-*.yaml` aliases by copying each `mvn-*.yaml` filter and replacing `command: "mvn"` with `command: "mvnd"`.

## Setup

```bash
# macOS / Linux
bash .github/skills/snip-install/scripts/install.sh

# Windows PowerShell
& '.\.github\skills\snip-install\scripts\install.ps1'
```

## Adding a new technology

1. Create `filters/<techname>/` subdirectory in `snip-install`
2. Add `.yaml` filter files
3. Re-run the install script — it auto-discovers all subdirectories
4. If the tool has binary aliases, add alias generation to the install script

## Outcome

- Lower token usage in AI loops (80-99% reduction with filters)
- Safe universal proxy (zero cost when no filter matches)
- One install command for all technologies
- Extensible: new technology = new filter folder, no skill changes
