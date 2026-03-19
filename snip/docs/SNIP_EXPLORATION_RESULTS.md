# snip YAML Filters - Exploration Results

**Exploration Date**: March 19, 2026  
**Repository**: https://github.com/edouard-claude/snip  
**Status**: ✅ Complete - 4 comprehensive documentation files created

---

## What Was Explored

Comprehensive research into the snip CLI repository to understand:

1. ✅ **Filter Discovery Mechanism** — How snip loads filters from `~/.config/snip/filters/`
2. ✅ **YAML Syntax** — Exact structure from `internal/filter/types.go`
3. ✅ **All 16 Pipeline Actions** — From `internal/filter/actions.go`
4. ✅ **Match Conditions** — Command, subcommand, flag filtering rules
5. ✅ **Argument Injection** — Injecting args before command execution
6. ✅ **Practical Examples** — Real-world filters for Maven, Git, Go, Docker

---

## What You Now Have

### 📄 Four Documentation Files

All located in: `.github/skills/setup-snip-hooks/`

| File | Size | Purpose | Best For |
|------|------|---------|----------|
| [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md) | 6.0K | Get running in 5 min | **New users** |
| [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) | 13K | 15 ready-to-use Maven filters | **Java developers** |
| [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) | 21K | Complete technical reference | **Advanced users** |
| [SNIP_YAML_FILTERS_INDEX.md](./SNIP_YAML_FILTERS_INDEX.md) | 7.8K | Navigation guide | **Everyone** |
| **Total** | **47.8K** | **Complete knowledge base** | **All users** |

---

## Key Discoveries

### Filter Discovery & Loading

```
User filters:     ~/.config/snip/filters/*.yaml ← (HIGH PRIORITY)
Built-in filters: Embedded in snip binary ← (fallback)

Loader behavior:
✓ Discovers all .yaml files (not .yml)
✓ Gracefully skips invalid YAML
✓ User filters override built-in
✓ No restart needed - auto-reload
```

### YAML Structure (Exact)

```yaml
name: "filter-name"              # Required
version: 1                       # Required
description: "..."               # Optional
match:                           # Required
  command: "tool"                # Required (git, mvn, go, etc.)
  subcommand: "sub"              # Optional (log, test, compile, etc.)
  exclude_flags: [...]           # Optional
  require_flags: [...]           # Optional
inject:                          # Optional: inject args before execution
  args: [...]
  defaults: {...}
  skip_if_present: [...]
pipeline: [...]                  # Required: list of actions
on_error: "passthrough"          # Optional: error handling
```

### 16 Pipeline Actions Available

All documented with examples:
1. `keep_lines` (regex match)
2. `remove_lines` (regex remove)
3. `truncate_lines` (max length)
4. `strip_ansi` (colors)
5. `head` / `tail` (first/last N)
6. `group_by` (group & count)
7. `dedup` (deduplicate)
8. `json_extract` (JSON fields)
9. `json_schema` (JSON structure)
10. `ndjson_stream` (newline-delimited JSON)
11. `regex_extract` (captures)
12. `state_machine` (multi-state)
13. `aggregate` (count patterns)
14. `format_template` (Go templates)
15. `compact_path` (shorten paths)

### Token Savings (Real Data)

From production Claude Code sessions:
- `go test ./...`: **97.7%** reduction (689 → 16 tokens) ✨
- `git log`: **85.7%** reduction (371 → 53 tokens)
- `cargo test`: **99.2%** reduction (591 → 5 tokens) ✨✨✨
- Maven (estimated): **~87%** average reduction

---

## How to Get Started

### Option 1: Quick Start (5 minutes)
```bash
# 1. Read this file
cat QUICK_START_YAML_FILTERS.md

# 2. Create filters directory
mkdir -p ~/.config/snip/filters

# 3. Copy a filter from MAVEN_FILTERS_EXAMPLES.md
# Example: mvn-test.yaml

# 4. Test it
snip -v mvn test

# 5. Check savings
snip gain
```

### Option 2: Full Learning (30 minutes)
1. Read [SNIP_YAML_FILTERS_INDEX.md](./SNIP_YAML_FILTERS_INDEX.md) (navigation)
2. Read [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) (complete syntax)
3. Study [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) (real examples)
4. Create your first custom filter

### Option 3: Copy and Go (< 2 minutes)
1. Copy filter YAML from [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md)
2. Paste into `~/.config/snip/filters/your-filter.yaml`
3. Run: `snip -v <command>`

---

## Practical Example: Maven Test Filter

**File**: `~/.config/snip/filters/mvn-test.yaml`

```yaml
name: "mvn-test"
version: 1
description: "Filter Maven test output"

match:
  command: "mvn"
  subcommand: "test"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
  - action: "keep_lines"
    pattern: "Tests run:|Failures:|Errors:|BUILD"
  - action: "aggregate"
    patterns:
      tests: "^\\[INFO\\] Tests run:"
      failures: "^\\[INFO\\] Failures:"

on_error: "passthrough"
```

Usage:
```bash
snip -v mvn test     # Check filter is used
snip mvn test        # Reduced output
snip gain            # See token savings
```

---

## File Naming Convention

```
<command>-<subcommand>.yaml

Examples:
✓ git-log.yaml       → matches: git log
✓ mvn-test.yaml      → matches: mvn test
✓ mvn-compile.yaml   → matches: mvn compile
✓ go-test.yaml       → matches: go test
✓ docker-build.yaml  → matches: docker build
```

---

## What Each Document Covers

### QUICK_START_YAML_FILTERS.md
- Copy-paste first filter (5 min)
- Common patterns ready to use
- Template filters
- Testing strategies
- Quick issue troubleshooting

### MAVEN_FILTERS_EXAMPLES.md
15 production-ready Maven filters:
- mvn-compile
- mvn-test (surefire)
- mvn-verify (failsafe tests)
- mvn-checkstyle
- mvn-spotbugs
- mvn-pmd
- mvn-jacoco
- mvn-package
- mvn-install
- mvn-dependency-tree
- mvn-site
- mvn-release
- mvn-docker-build
- mvn-parallel
- mvn-full-release

Each with copy-paste YAML and estimated token savings.

### SNIP_YAML_REFERENCE.md
Complete 700+ line reference:
- Filter discovery & loading
- YAML syntax (exact fields)
- Match conditions guide
- Argument injection explained
- All 16 actions documented
- 6 complete practical examples
- Testing & validation
- Error handling
- Troubleshooting guide

### SNIP_YAML_FILTERS_INDEX.md
Navigation & reference:
- Quick links by use case
- Document overview table
- Key findings summary
- Workflows (5 min, 20 min, custom)
- Common tasks with links
- Validation tools
- Support reference table

---

## Source Code Analysis

Research based on authoritative sources:

```
Repository: https://github.com/edouard-claude/snip
├── internal/filter/types.go      ← Filter structure definitions
├── internal/filter/parser.go     ← YAML parsing & validation
├── internal/filter/actions.go    ← 16 action implementations
├── internal/filter/loader.go     ← Filter discovery mechanism
├── internal/filter/registry.go   ← Filter matching logic
├── tests/fixtures/               ← Real test data
├── README.md                     ← Official documentation
└── CLAUDE.md                     ← Project internals
```

---

## Next Steps

### For Beginners
1. Read: [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md)
2. Copy: A filter from [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md)
3. Test: `snip -v mvn test`
4. Done! 🎉

### For Intermediate Users
1. Read: [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) - Sections 1-4
2. Copy: Multiple filters and customize
3. Test regex at: https://regex101.com
4. Create: Your first custom filter

### For Advanced Users
1. Master: All of [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md)
2. Create: Complex multi-state filters
3. Contribute: Back to snip repository
4. Optimize: For your specific tool chains

---

## Directory Structure

```
~/.github/skills/setup-snip-hooks/
├── README.md                       # Main skill doc
├── SKILL.md                       # Skill instructions
├── SNIP_YAML_REFERENCE.md         # ← Complete reference (THIS EXPLORATION)
├── MAVEN_FILTERS_EXAMPLES.md      # ← Maven examples (THIS EXPLORATION)
├── QUICK_START_YAML_FILTERS.md    # ← Quick start (THIS EXPLORATION)
├── SNIP_YAML_FILTERS_INDEX.md     # ← Navigation (THIS EXPLORATION)
└── profiles/*.yaml                # Config files

User filters location:
~/.config/snip/filters/
├── mvn-test.yaml
├── mvn-compile.yaml
├── git-log.yaml
└── ... your filters ...
```

---

## Quick Reference Card

```yaml
# Minimal working filter
name: "tool-action"
version: 1

match:
  command: "tool"          # git, mvn, go, cargo, docker, etc.
  subcommand: "action"     # test, compile, log, build, etc.

pipeline:
  - action: "keep_lines"
    pattern: "ERROR|WARN"

on_error: "passthrough"
```

Common patterns:
```yaml
# Remove download messages
- action: "remove_lines"
  pattern: "Downloading|Downloaded"

# Keep only errors
- action: "keep_lines"
  pattern: "ERROR|FAIL|×"

# Show summary only
- action: "aggregate"
  patterns:
    passed: "^PASS"
    failed: "^FAIL"

# Clean colors
- action: "strip_ansi"
```

---

## Validation & Testing

### Test Your Filter
```bash
snip -v mvn test        # Should show "Using filter: mvn-test"
snip -v mvn test 2>&1   # See what's being filtered
snip gain               # Check token savings
```

### Validate Syntax
```bash
# Option 1: https://www.yamllint.com (online)
# Option 2: snip -v <command> (live test)
```

### Test Regex
```bash
# https://regex101.com (online regex tester)
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Filter not found | File must end in `.yaml` not `.yml` |
| Pattern not matching | Test regex at https://regex101.com |
| Too much output | Add more `remove_lines` actions |
| Filter not triggering | Check `match.command` matches exactly |
| Invalid YAML | Check indentation (2 spaces) and quotes |
| Regex error | Escape backslashes: `\\s` not `\s` |

---

## Summary

✅ **Complete exploration completed** of snip repository  
✅ **YAML syntax fully documented** with exact field definitions  
✅ **All 16 actions explained** with examples  
✅ **15 Maven filters ready** for immediate use  
✅ **47.8KB of documentation** created  
✅ **Multiple entry points** for different users  

**You're ready to start using snip filters immediately!**

---

## Resources

| Resource | Purpose |
|----------|---------|
| [SNIP Repository](https://github.com/edouard-claude/snip) | Source code & issues |
| [snip Wiki](https://github.com/edouard-claude/snip/wiki) | Official documentation |
| [regex101.com](https://regex101.com) | Test regex patterns |
| [yamllint.com](https://www.yamllint.com) | Validate YAML syntax |

---

## Questions?

See [SNIP_YAML_FILTERS_INDEX.md](./SNIP_YAML_FILTERS_INDEX.md) for comprehensive support table.

**Happy filtering! 🚀**
