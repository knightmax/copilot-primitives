---
name: setup-snip-hooks
description: Use when setting up snip CLI token reduction hooks in a project, before first terminal commands are run
argument-hint: "Run this skill to scaffold snip preToolUse hooks for CLI token reduction in a project. Follow the instructions in the generated SKILL.md file to complete setup."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# Setup snip Hooks for Maven/Java Projects

Scaffolds `snip` preToolUse hooks into a project's `.github/hooks/` directory and configures snip profiles for Java/Maven output reduction. The hook automatically rewrites supported CLI commands (including `mvn`) through `snip` to reduce output tokens.

## Why per-project hooks?

Copilot/VS Code hooks require a **hardcoded `cwd`** in `hooks.json` — there is no environment variable (like `${CLAUDE_PLUGIN_ROOT}`) to resolve the hook script path dynamically. The hook must live inside the project so the relative path works.

## When to Use

- New project needs snip token reduction
- Project has no `.github/hooks/snip-rewrite.sh` yet
- `snip` and `jq` are available on the machine

## Prerequisites

### macOS / Linux

```bash
# Verify snip is installed
command -v snip   # must exist

# For setup script (bash)
command -v jq     # must exist
```

Installation:
```bash
# macOS
brew install snip jq

# Ubuntu/Debian
sudo apt-get install jq
# For snip, download from: https://github.com/edouard-claude/snip/releases
# or: cargo install snip

# Verify
snip --version
jq --version
```

### Windows (PowerShell)

```powershell
# Verify snip is installed
Get-Command snip
```

Installation (choose one):
```powershell
# Option 1: Using Scoop
scoop install snip

# Option 2: Manual download
# Download from: https://github.com/edouard-claude/snip/releases
# Extract to: C:\Program Files\snip\
# Add to PATH or call explicitly

# Verify
snip --version
```

## Setup Steps

Choose the script for your OS and run it:

### macOS / Linux

```bash
cd /path/to/your/workspace

# Run bash setup
bash .github/skills/setup-snip-hooks/templates/snip-rewrite.sh <project-root>
```

Example:
```bash
bash .github/skills/setup-snip-hooks/templates/snip-rewrite.sh rescue-mission-good-architecture
```

### Windows (PowerShell)

```powershell
cd \path\to\your\workspace

# Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run PowerShell setup
& '.\​.github\skills\setup-snip-hooks\templates\snip-rewrite.ps1' <project-root>
```

Example:
```powershell
& '.\​.github\skills\setup-snip-hooks\templates\snip-rewrite.ps1' rescue-mission-good-architecture
```

Or from PowerShell prompt in the directory:
```powershell
cd .github/skills/setup-snip-hooks/templates
.\\snip-rewrite.ps1 ../../../../../../rescue-mission-good-architecture
```

## What Gets Created

| File | Purpose |
|------|---------|
| `~/.config/snip/filters/mvn-*.yaml` (macOS/Linux) | Maven snip filter profiles (global) |
| `%APPDATA%\snip\filters\mvn-*.yaml` (Windows) | Maven snip filter profiles (global) |
| `.github/hooks/snip-rewrite.sh` | Bash hook that intercepts commands |
| `.github/hooks/snip-rewrite.ps1` | PowerShell hook for Windows |
| `.github/hooks/hooks.json` | Copilot plugin hook configuration |
| `.snip/README.md` | Reference documentation in project |
| `.vscode/settings.json` | VS Code integration settings |

## 🎯 How Automation Works

After setup, Maven commands are **automatically proxified through snip**:

**In Copilot prompts:**
```
User: "run mvn clean test"
Copilot executes: snip mvn clean test  ← Automatically!
```

**In terminal directly:**
```bash
# This still works normally (not proxified)
mvn clean test

# But if using snip for token reduction:
snip mvn clean test
```

The hook is registered in `.github/hooks/hooks.json` and intercepts commands that Copilot/Claude Code attempts to run in the terminal.

### Available Maven Filters

| Filter | Command | What it does |
|--------|---------|------------|
| **mvn-compile.yaml** | `snip mvn compile` | Filters build verbose output |
| **mvn-test.yaml** | `snip mvn test` | Filters Surefire test output |
| **mvn-verify.yaml** | `snip mvn verify` | Filters Failsafe integration tests |
| **mvn-package.yaml** | `snip mvn package` | Filters JAR/WAR building output |
| **mvn-install.yaml** | `snip mvn install` | Filters build, test, and installation output |
| **mvn.yaml** | `snip mvn <any>` | General Maven filter (fallback) |

## Common Commands: Windows vs macOS/Linux

| Task | macOS / Linux | Windows PowerShell |
|------|---------------|-------------------|
| **Check snip installation** | `command -v snip` | `Get-Command snip` |
| **View filter directory** | `ls ~/.config/snip/filters/` | `Get-ChildItem $env:APPDATA\snip\filters` |
| **Edit a filter** | `vi ~/.config/snip/filters/mvn-test.yaml` | `notepad $env:APPDATA\snip\filters\mvn-test.yaml` |
| **Run Maven with snip** | `snip mvn clean test` | `snip mvn clean test` |
| **See token savings** | `snip gain --daily` | `snip gain --daily` |

### Usage

Once installed, snip automatically applies the correct filter based on the Maven command:

```batch
# All platforms - Commands are identical!
snip mvn clean compile      # Compile - uses mvn-compile.yaml (93% reduction)
snip mvn test               # Run tests - uses mvn-test.yaml
snip mvn verify             # Integration tests - uses mvn-verify.yaml
snip mvn package            # Package JAR/WAR - uses mvn-package.yaml
snip mvn install            # Install to local repo - uses mvn-install.yaml
snip gain --daily           # View token savings
```
snip gain --daily
snip gain --weekly
```

### How It Works

snip discovers filters automatically:
1. Scans `~/.config/snip/filters/` for `.yaml` files
2. Matches filter's `match.command` and `match.subcommand` to your command
3. Applies the pipeline rules to reduce output
4. Returns filtered, cleaner output

**Example**: When you run `snip mvn test`:
- snip finds `mvn-test.yaml` in `~/.config/snip/filters/`
- Filter matches `command: "mvn"` and `subcommand: "test"`
- Pipeline removes verbose lines, keeps test results
- Output has ~93% fewer tokens

### Customizing Filters

Edit any Maven filter directly:

```bash
# Edit the test filter
vi ~/.config/snip/filters/mvn-test.yaml
```

Modifications take effect immediately (no restart needed).

For syntax reference, see [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md)



## Dojo-Specific Usage

This DOJO has multiple Maven projects in the `rescue-mission-good-architecture` and `rescue-mission-bad-architecture` modules. Setup snip once, and use it across all projects:

### First-Time Setup

```bash
# Run the setup script for the good architecture example
bash .github/skills/setup-snip-hooks/templates/snip-rewrite.sh rescue-mission-good-architecture
```

This installs filters globally to `~/.config/snip/filters/`. After setup, all Maven projects in your workspace can use snip.

### Test on Good Architecture

```bash
cd rescue-mission-good-architecture
snip mvn clean test  # 93.6% token reduction
snip gain --daily    # See savings
```

### Compare with Bad Architecture

```bash
# For comparison with monolithic approach
cd rescue-mission-bad-architecture
snip mvn clean test
```

### Verify Installation

```bash
# Check installed filters
ls -la ~/.config/snip/filters/mvn-*.yaml

# Test with verbose output
snip -vv mvn test
```

---

**Hook not triggering?**
- Verify `snip` and `jq` are installed: `command -v snip && command -v jq`
- Check hook file permissions: `ls -la .github/hooks/snip-rewrite.sh`
- Verify `.github/hooks/hooks.json` exists and is valid JSON

**Snip filter not working?**
- Verify filter exists: `ls -la ~/.config/snip/filters/maven-*.yaml`
- Test filter directly:
  ```bash
  mvn clean compile 2>&1 | snip --filter maven-build
  ```
- Check snip configuration: `snip config list`

**Revert changes**:
```bash
rm -rf .github/hooks/
git checkout .github/
```

---

## For Framework Developers

This skill provides **templates** and **per-language filters** to extend `snip` support to new projects without requiring plugin modifications.

**To add a new language/filter:**

1. Create `filters/<lang>-<goal>.yaml` in this skill
2. Update `SKILL.md` with setup instructions for the new filter
3. Update `snip-rewrite.sh` to include the new command in the `case` statement (if not already supported)
4. Test with real project output

**Filter Structure** (YAML):
```yaml
name: "<lang>-<goal>"
version: 1
description: "Short description of what snip removes vs keeps"

match:
  command: "mvn"  # or other CLI
  subcommand: "<goal>"  # optional, e.g., "test" or "build"

pipeline:
  - action: "strip_ansi"  # Remove color codes
  - action: "remove_lines"
    pattern: "regex pattern to remove"
  - action: "keep_lines"
    pattern: "regex pattern to keep (inverse of remove)"
  - action: "compact_path"  # Shorten long paths
  - action: "format_template"
    template: "Final formatted output"

on_error: "passthrough"  # If snip fails, pass original output
```
