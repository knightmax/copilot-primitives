# snip YAML Filters - Quick Start Guide

Copy-paste this to get started in 5 minutes.

---

## Step 1: Create Filters Directory

```bash
mkdir -p ~/.config/snip/filters
```

## Step 2: Create Your First Filter

**Maven Test Filter** — `~/.config/snip/filters/mvn-test.yaml`:

```yaml
name: "mvn-test"
version: 1
description: "Filter Maven test output to show only results"

match:
  command: "mvn"
  subcommand: "test"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
  - action: "remove_lines"
    pattern: "^\\[DEBUG\\]"
  - action: "keep_lines"
    pattern: "Tests run:|Failures:|Errors:|BUILD|SUCCESS|FAILURE"
  - action: "strip_ansi"

on_error: "passthrough"
```

## Step 3: Test It

```bash
snip -v mvn test                # Show filter being used
snip mvn clean test             # Run with filter
snip gain                       # See token savings
```

---

## Common Patterns - Copy & Paste

### Pattern: Remove Download Messages (Maven)

```yaml
- action: "remove_lines"
  pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
```

### Pattern: Keep Only Errors & Warnings

```yaml
- action: "keep_lines"
  pattern: "\\[ERROR\\]|\\[WARN\\]|FAIL|BUILD"
```

### Pattern: Group By Status

```yaml
- action: "aggregate"
  patterns:
    passed: "^PASS|^✓|^ok"
    failed: "^FAIL|^✗|^FAILED"
```

### Pattern: Show Summary Only

```yaml
- action: "remove_lines"
  pattern: ".+[0-9]%"  # Remove progress lines
- action: "tail"
  n: 10                # Show last 10 lines only
```

### Pattern: Clean ANSI Colors

```yaml
- action: "strip_ansi"
```

---

## Quick Filter Templates

### Template 1: Build Output (Compile/Package)

```yaml
name: "your-tool-build"
version: 1
match:
  command: "your-tool"
  subcommand: "build"
pipeline:
  - action: "remove_lines"
    pattern: "Downloading|Scanning|Building"
  - action: "keep_lines"
    pattern: "SUCCESS|FAILURE|ERROR|Warning"
on_error: "passthrough"
```

### Template 2: Test Output

```yaml
name: "your-tool-test"
version: 1
match:
  command: "your-tool"
  subcommand: "test"
pipeline:
  - action: "remove_lines"
    pattern: "^\\s*$|Downloading"
  - action: "aggregate"
    patterns:
      passed: "PASS|✓"
      failed: "FAIL|✗"
on_error: "passthrough"
```

### Template 3: Dependency/Conflict Resolution

```yaml
name: "your-tool-deps"
version: 1
match:
  command: "your-tool"
  subcommand: "deps"
pipeline:
  - action: "keep_lines"
    pattern: "conflict|excluded|ERROR"
  - action: "group_by"
    pattern: "(.+?)\\s+--"
on_error: "passthrough"
```

---

## Real Example: Maven Full Stack

Copy these to `~/.config/snip/filters/`:

**mvn-compile.yaml**:
```yaml
name: "mvn-compile"
version: 1
match:
  command: "mvn"
  subcommand: "compile"
pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded)"
  - action: "keep_lines"
    pattern: "\\[ERROR\\]|\\[WARN\\]|BUILD|ERROR"
  - action: "strip_ansi"
on_error: "passthrough"
```

**mvn-test.yaml**:
```yaml
name: "mvn-test"
version: 1
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

**mvn-package.yaml**:
```yaml
name: "mvn-package"
version: 1
match:
  command: "mvn"
  subcommand: "package"
pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
  - action: "keep_lines"
    pattern: "Building|Packaging|BUILD|SUCCESS|FAILURE"
  - action: "head"
    n: 50
on_error: "passthrough"
```

---

## Testing Your Filters

```bash
# Check if filter works
snip -v mvn test

# Should see output like:
# Using filter: mvn-test
# [filtered output...]

# Check token savings
snip gain

# Compare sizes
mvn test 2>&1 | wc -l           # Raw lines
snip mvn test 2>&1 | wc -l      # Filtered lines
```

---

## YAML Syntax Cheat Sheet

```yaml
# Required
name: "filter-name"
version: 1
match:
  command: "tool"              # Main command
pipeline:
  - action: "action-name"      # Action type
    param: value               # Action parameter

# Optional
description: "What it does"
match:
  subcommand: "sub"            # Sub-command
  exclude_flags: ["--flag"]    # Skip if these present
  require_flags: ["--flag"]    # Only if these present
inject:
  args: ["--arg"]              # Inject before execution
  defaults:
    "-x": "10"                 # Default flag values
  skip_if_present: ["--flag"]  # Don't inject if user has this
on_error: "passthrough"        # "passthrough" | "empty"
```

---

## Common Issues

| Issue | Fix |
|-------|-----|
| Filter not found | Check filename ends in `.yaml` not `.yml` |
| Pattern not matching | Test regex at https://regex101.com |
| Too much output | Add more `remove_lines` actions |
| No filter triggering | Check `match.command` matches exactly |
| YAML error | Validate indentation (2 spaces) |

---

## File Locations

**User filters**: `~/.config/snip/filters/`
**Config**: `~/.config/snip/config.toml`
**Database**: `~/.local/share/snip/tracking.db`

---

## Next Steps

1. ✓ Create `~/.config/snip/filters/` directory
2. ✓ Copy a filter YAML file
3. ✓ Test with `snip -v <command>`
4. ✓ Check savings with `snip gain`
5. ✓ Customize regex patterns as needed
6. ✓ Share your filters!

---

## Full Documentation

See these files for complete reference:
- [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) — Complete syntax & all 16 actions
- [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) — 15 ready-to-use Maven filters

---

## Resources

- **Repository**: https://github.com/edouard-claude/snip
- **Wiki**: https://github.com/edouard-claude/snip/wiki
- **Filter DSL Reference**: https://github.com/edouard-claude/snip/wiki/Filter-DSL-Reference

---

## Questions?

- Test regex patterns: https://regex101.com
- YAML validation: https://www.yamllint.com
- Check filter with: `snip -v <command>`
- Validate format: `snip config`

