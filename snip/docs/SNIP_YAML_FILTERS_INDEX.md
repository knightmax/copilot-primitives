# snip YAML Filter Documentation Index

Complete reference materials for snip filter discovery, YAML syntax, and practical examples.

---

## Quick Links by Use Case

### **I want to get started immediately** → 
→ [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md) (5 min read)
- Copy-paste first filter
- Common patterns
- Testing your filter

### **I need Maven-specific filters**
→ [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) (Ready-to-use)
- 15 Maven filter examples
- compile, test, package, verify, checkstyle, spotbugs, jacoco, etc.
- Token savings estimates

### **I need complete YAML reference**
→ [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) (Comprehensive)
- Exact YAML syntax
- Filter discovery mechanism  
- All 16 pipeline actions
- Testing strategies
- Error handling

---

## Document Overview

| Document | Purpose | Audience | Time |
|----------|---------|----------|------|
| [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md) | Get running fast | New users | 5 min |
| [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) | Copy Maven filters | Java developers | 10 min |
| [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) | Learn syntax deeply | Advanced users | 20+ min |
| This file | Navigation guide | Everyone | 2 min |

---

## Key Findings from Repository Exploration

### Filter Discovery
- **Location**: `~/.config/snip/filters/` (user filters override built-in)
- **Format**: Only `.yaml` files (not `.yml`)
- **Naming**: Lowercase with hyphens: `mvn-test.yaml`, `git-log.yaml`
- **Loading**: Automatic, graceful degradation on parse errors
- **No restart needed**: Changes take effect immediately

### Exact YAML Structure
```yaml
name: "filter-name"           # Required
version: 1                    # Required
match:
  command: "mvn"              # Required: main command
  subcommand: "test"          # Optional: subcommand
  exclude_flags: [...]        # Optional: skip if user provides
  require_flags: [...]        # Optional: only if user provides
inject:                       # Optional: inject args before execution
  args: [...]
  defaults: {...}
  skip_if_present: [...]
pipeline: [...]               # Required: ordered actions
on_error: "passthrough"       # Optional: error handling
```

### 16 Pipeline Actions Available
1. `keep_lines` - Keep matching regex
2. `remove_lines` - Remove matching regex  
3. `truncate_lines` - Truncate long lines
4. `strip_ansi` - Remove color codes
5. `head` / `tail` - First/last N lines
6. `group_by` - Group by regex capture + count
7. `dedup` - Deduplicate lines + count
8. `json_extract` - Extract JSON fields
9. `json_schema` - Show JSON structure
10. `ndjson_stream` - Group newline-delimited JSON
11. `regex_extract` - Extract capture groups
12. `state_machine` - Multi-state processing
13. `aggregate` - Count pattern matches
14. `format_template` - Go template formatting
15. `compact_path` - Shorten file paths

### Token Savings (Real Data)
- `go test ./...`: 97.7% fewer tokens
- `git log`: 85.7% reduction
- `cargo test`: 99.2% reduction
- Maven filters: ~87% expected reduction

---

## Workflows

### Workflow 1: Quick Filter Setup (5 minutes)

1. Read: [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md)
2. Create: `mkdir -p ~/.config/snip/filters`
3. Copy: A filter from [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md)
4. Test: `snip -v mvn test`
5. Check: `snip gain`

### Workflow 2: Deep Learning (20 minutes)

1. Read: [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) (sections 1-4)
2. Understand: Filter discovery, YAML structure, match conditions
3. Study: Pipeline actions (section 5)
4. Review: Practical examples (section 6)

### Workflow 3: Create Custom Filter

1. Reference: [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) - Practical Examples section
2. Copy: Template from [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md)
3. Test regex at: https://regex101.com
4. Validate YAML at: https://www.yamllint.com
5. Test filter: `snip -v <command>`

---

## File Locations

```
~/.github/skills/setup-snip-hooks/
├── README.md                           # Main skill documentation
├── SKILL.md                           # Skill instructions
├── SNIP_YAML_REFERENCE.md             # ← Complete syntax reference (this exploration)
├── MAVEN_FILTERS_EXAMPLES.md          # ← Ready-to-use Maven filters (this exploration)
├── QUICK_START_YAML_FILTERS.md        # ← Quick start guide (this exploration)
├── SNIP_YAML_FILTERS_INDEX.md         # ← This file (navigation index)
└── profiles/*.yaml                   # TOML filters config files
```

User filter location:
```
~/.config/snip/filters/
├── mvn-test.yaml
├── mvn-compile.yaml
├── git-log.yaml
├── go-test.yaml
└── ... your filters ...
```

---

## Common Tasks

### Task: Create a Maven test filter
→ See [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) → Copy `mvn-test.yaml`

### Task: Learn regex patterns
→ Visit https://regex101.com (test patterns live)

### Task: See what actions do
→ See [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) → Section "16 Pipeline Actions"

### Task: Understand filter matching
→ See [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) → Section "Match Conditions"

### Task: Filter git commands
→ See [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) → Example 4: "Git Log Filter"

### Task: Create custom filter
→ See [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md) → Templates section

---

## Reference Material from Repository

These documents are based on authoritative source code from:
- Repository: https://github.com/edouard-claude/snip
- Source files analyzed:
  - `internal/filter/types.go` — Filter structure definitions
  - `internal/filter/parser.go` — YAML parsing & validation  
  - `internal/filter/actions.go` — 16 action implementations (639 lines)
  - `internal/filter/loader.go` — Filter discovery mechanism
  - `internal/filter/registry.go` — Filter matching logic
  - `tests/fixtures/` — Real test data
  - `README.md` — Official documentation
  - `CLAUDE.md` — Project internals guide

---

## Validation & Error Checking

### Validate YAML Syntax
```bash
# Option 1: Test with snip
snip -v mvn test    # Shows if YAML parses

# Option 2: Online validator  
# https://www.yamllint.com
```

### Validate Regex Patterns
```bash
# Online regex tester
# https://regex101.com
```

### Check Filter Savings
```bash
snip gain                   # Full dashboard
snip gain --top 1           # Top command by savings  
snip -v mvn test            # Show filter details
```

---

## Summary

You now have:

1. ✅ **QUICK_START_YAML_FILTERS.md** — Get started in 5 minutes
2. ✅ **MAVEN_FILTERS_EXAMPLES.md** — 15 ready-to-copy Maven filters
3. ✅ **SNIP_YAML_REFERENCE.md** — Complete 700+ line technical reference
4. ✅ **SNIP_YAML_FILTERS_INDEX.md** — This navigation guide

All based on authentic exploration of https://github.com/edouard-claude/snip repository.

---

## Next Steps

- **Beginners**: Start with [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md)
- **Intermediate**: Copy filters from [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md)
- **Advanced**: Master all details in [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md)

---

## Support

| Question | Resource |
|----------|----------|
| How do I get started? | [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md) |
| What filters are available for Maven? | [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) |
| What is the complete YAML syntax? | [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) |
| Where do my filters go? | `~/.config/snip/filters/` |
| How do I test my filter? | `snip -v <command>` then `snip gain` |
| Help with regex? | https://regex101.com |
| Help with YAML? | https://www.yamllint.com |
| snip repository? | https://github.com/edouard-claude/snip |

