# Ready-to-Use snip Filter Examples for Maven Projects

Quick-copy YAML filters for common Maven and Java development tasks. Copy & paste into `~/.config/snip/filters/` and adjust patterns as needed.

---

## 1. Maven Clean Compile

**File**: `~/.config/snip/filters/mvn-clean-compile.yaml`

```yaml
name: "mvn-clean-compile"
version: 1
description: "Maven clean compile - filter out download messages"

match:
  command: "mvn"
  subcommand: "clean"
  require_flags: ["compile"]

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading from|Downloaded from|Scanning|Building jar)"
  - action: "remove_lines"
    pattern: "^\\[DEBUG\\]"
  - action: "keep_lines"
    pattern: "\\[ERROR\\]|\\[WARN\\]|BUILD|ERROR|WARNING|SUCCESS|Compiling"
  - action: "head"
    n: 100
  - action: "strip_ansi"

on_error: "passthrough"
```

---

## 2. Maven Surefire Tests

**File**: `~/.config/snip/filters/mvn-surefire.yaml`

```yaml
name: "mvn-surefire"
version: 1
description: "Filter Maven Surefire test output"

match:
  command: "mvn"
  subcommand: "test"

inject:
  defaults:
    "-DforkCount": "1.5C"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
  - action: "keep_lines"
    pattern: "Tests run:|Failures:|Errors:|Skipped:|BUILD SUCCESS|BUILD FAILURE|Running |TEST|FAIL|PASS"
  - action: "aggregate"
    patterns:
      "Tests run": "^\\[INFO\\]\\s+Tests run:"
      "Failures": "^\\[INFO\\]\\s+Failures:"
      "Errors": "^\\[INFO\\]\\s+Errors:"
      "Skipped": "^\\[INFO\\]\\s+Skipped:"
  - action: "format_template"
    template: "Surefire Results:\n{{.lines}}\n\nSummary:\n{{.stats}}"

on_error: "passthrough"
```

---

## 3. Maven Integration Tests

**File**: `~/.config/snip/filters/mvn-failsafe.yaml`

```yaml
name: "mvn-failsafe"
version: 1
description: "Filter Maven Failsafe integration test output"

match:
  command: "mvn"
  subcommand: "verify"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Building)"
  - action: "keep_lines"
    pattern: "Failsafe|Integration Test|BUILD|PASS|FAIL|SUCCESS|FAILURE"
  - action: "group_by"
    pattern: "^\\[INFO\\] (\\w+) Tests|BUILD (FAILURE|SUCCESS)"
    format: "{{.Key}}: {{.Count}}"
  - action: "truncate_lines"
    max: 100

on_error: "passthrough"
```

---

## 4. Checkstyle/Code Quality

**File**: `~/.config/snip/filters/mvn-checkstyle.yaml`

```yaml
name: "mvn-checkstyle"
version: 1
description: "Filter Maven Checkstyle violations to key patterns"

match:
  command: "mvn"
  subcommand: "checkstyle:check"

pipeline:
  - action: "keep_lines"
    pattern: "\\[ERROR\\]|violation|Checkstyle|BUILD|ERROR"
  - action: "regex_extract"
    pattern: "^(.+?):\\d+:\\d+:\\s+(.+)$"
    format: "$1 - $2"
  - action: "group_by"
    pattern: "^([^-]+)"
    top: 10
  - action: "format_template"
    template: "Checkstyle Issues:\n{{.lines}}"

on_error: "passthrough"
```

---

## 5. Spotbugs (Bug Detection)

**File**: `~/.config/snip/filters/mvn-spotbugs.yaml`

```yaml
name: "mvn-spotbugs"
version: 1
description: "Filter Maven Spotbugs analysis results"

match:
  command: "mvn"
  subcommand: "spotbugs:check"

pipeline:
  - action: "keep_lines"
    pattern: "\\[ERROR\\]|\\[WARN\\]|BUG|Confidence|Rank|Priority|BUILD"
  - action: "group_by"
    pattern: "\\[(\\w+)\\]"
    format: "{{.Key}}: {{.Count}}"
  - action: "aggregate"
    patterns:
      "High": "Confidence: HIGH"
      "Medium": "Confidence: MEDIUM"
      "Low": "Confidence: LOW"
  - action: "format_template"
    template: "Spotbugs Report:\n{{.lines}}\n\nDistribution:\n{{.stats}}"

on_error: "passthrough"
```

---

## 6. PMD Analysis

**File**: `~/.config/snip/filters/mvn-pmd.yaml`

```yaml
name: "mvn-pmd"
version: 1
description: "Filter PMD code analysis warnings"

match:
  command: "mvn"
  subcommand: "pmd:check"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Running)"
  - action: "keep_lines"
    pattern: "\\[WARN\\]|\\[ERROR\\]|PMD|violation|priority|rule|BUILD"
  - action: "regex_extract"
    pattern: "^(.+?):(.+?)\\s+Rule:(.+)$"
    format: "$2 - [$3]"
  - action: "group_by"
    pattern: "^(.+?)\\s+-"
    top: 15

on_error: "passthrough"
```

---

## 7. Jacoco Coverage Report

**File**: `~/.config/snip/filters/mvn-jacoco.yaml`

```yaml
name: "mvn-jacoco"
version: 1
description: "Filter Jacoco coverage analysis"

match:
  command: "mvn"
  subcommand: "verify"
  require_flags: ["jacoco"]

pipeline:
  - action: "keep_lines"
    pattern: "jacoco|Coverage|Line|Branch|Method|BUILD|Threshold"
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded)"
  - action: "regex_extract"
    pattern: "^\\[INFO\\]\\s+(.+?)\\:\\s+(.+?)%"
    format: "$1: $2%"
  - action: "format_template"
    template: "Jacoco Coverage:\n{{.lines}}"

on_error: "passthrough"
```

---

## 8. Assembly/Package

**File**: `~/.config/snip/filters/mvn-package.yaml`

```yaml
name: "mvn-package"
version: 1
description: "Filter Maven package phase (jar/war creation)"

match:
  command: "mvn"
  subcommand: "package"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning|Building|Processing)"
  - action: "keep_lines"
    pattern: "Building|Assembling|Packaging|BUILD|SUCCESS|FAILURE|ERROR"
  - action: "truncate_lines"
    max: 100
  - action: "format_template"
    template: "Package Results:\n{{.lines}}"

on_error: "passthrough"
```

---

## 9. Installation & Deployment

**File**: `~/.config/snip/filters/mvn-install.yaml`

```yaml
name: "mvn-install"
version: 1
description: "Filter Maven install phase (local/repo upload)"

match:
  command: "mvn"
  subcommand: "install"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning|Skipping)"
  - action: "keep_lines"
    pattern: "\\[INFO\\]\\s+(Building|Installing|Uploading|BUILD)"
  - action: "group_by"
    pattern: "^\\[INFO\\]\\s+(\\w+)"
    format: "{{.Key}}: {{.Count}}"

on_error: "passthrough"
```

---

## 10. Dependency Resolution

**File**: `~/.config/snip/filters/mvn-dependency-tree.yaml`

```yaml
name: "mvn-dependency-tree"
version: 1
description: "Filter Maven dependency tree to show only conflicts/issues"

match:
  command: "mvn"
  subcommand: "dependency:tree"

pipeline:
  - action: "keep_lines"
    pattern: "conflict|excluded|omitted|---->|WARN|ERROR"
  - action: "group_by"
    pattern: "(.+?)\\s+--"
    top: 10
  - action: "remove_lines"
    pattern: "^\\s*$"
  - action: "format_template"
    template: "Dependency Conflicts:\n{{.lines}}"

on_error: "passthrough"
```

---

## 11. Reports Generation

**File**: `~/.config/snip/filters/mvn-site.yaml`

```yaml
name: "mvn-site"
version: 1
description: "Filter Maven site generation"

match:
  command: "mvn"
  subcommand: "site"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Processing|Scanning)"
  - action: "keep_lines"
    pattern: "Generating|Rendering|Report|BUILD|SUCCESS|FAILURE"
  - action: "aggregate"
    patterns:
      "Generating": "^\\[INFO\\] Generating"
      "Reports": "^\\[INFO\\].*(Reports|Report)"
  - action: "format_template"
    template: "Site Generation:\n{{.lines}}\n\nSummary:\n{{.stats}}"

on_error: "passthrough"
```

---

## 12. Release Process

**File**: `~/.config/snip/filters/mvn-release.yaml`

```yaml
name: "mvn-release"
version: 1
description: "Filter Maven release plugin output"

match:
  command: "mvn"
  subcommand: "release:perform"

pipeline:
  - action: "keep_lines"
    pattern: "release|version|tag|commit|push|BUILD|SUCCESS|ERROR"
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
  - action: "truncate_lines"
    max: 100
  - action: "strip_ansi"

on_error: "passthrough"
```

---

## 13. Docker Multi-Module Build

**File**: `~/.config/snip/filters/mvn-docker-build.yaml`

```yaml
name: "mvn-docker-build"
version: 1
description: "Filter Maven build with Docker (Dockerfile Maven plugin)"

match:
  command: "mvn"
  subcommand: "dockerfile:build"

pipeline:
  - action: "keep_lines"
    pattern: "Step|Digest|Successfully|ERROR|FROM|RUN|EXPOSE|Push"
  - action: "remove_lines"
    pattern: "Sending build context|Removing intermediate"
  - action: "truncate_lines"
    max: 120
  - action: "format_template"
    template: "Docker Build Summary:\n{{.lines}}"

on_error: "passthrough"
```

---

## 14. Parallel Build (Optimization)

**File**: `~/.config/snip/filters/mvn-parallel.yaml`

```yaml
name: "mvn-parallel"
version: 1
description: "Filter Maven parallel build output"

match:
  command: "mvn"
  require_flags: ["-T"]

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning|Building jar)"
  - action: "keep_lines"
    pattern: "Building|\\[INFO\\] BUILD|ERROR|Test|modules"
  - action: "group_by"
    pattern: "^\\[([^\\]]+)\\]"
    top: 5
  - action: "format_template"
    template: "Parallel Build:\n{{.lines}}"

on_error: "passthrough"
```

---

## 15. Full Release Cycle (Clean → Test → Package → Deploy)

**File**: `~/.config/snip/filters/mvn-full-release.yaml`

```yaml
name: "mvn-full-release"
version: 1
description: "Filter Maven full release cycle (clean, test, package, deploy)"

match:
  command: "mvn"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning|Processing|Building|Generating)"
  - action: "remove_lines"
    pattern: "^\\[DEBUG\\]"
  - action: "keep_lines"
    pattern: "\\[ERROR\\]|\\[WARN\\]|BUILD|Tests|Failures|Errors|Deployed"
  - action: "aggregate"
    patterns:
      "Errors": "\\[ERROR\\]"
      "Warnings": "\\[WARN\\]"
      "Built": "BUILD SUCCESS"
  - action: "head"
    n: 50
  - action: "format_template"
    template: "Release Summary:\n{{.lines}}\n\nStats:\n{{.stats}}"

on_error: "passthrough"
```

---

## Installation Instructions

1. Create the filters directory:
```bash
mkdir -p ~/.config/snip/filters
```

2. Copy any filter YAML file above into `~/.config/snip/filters/`

```bash
# Example
cat > ~/.config/snip/filters/mvn-test.yaml << 'EOF'
name: "mvn-test"
version: 1
description: "Filter Maven test output"
...
EOF
```

3. Test the filter:
```bash
snip mvn test                # Should use the filter automatically
snip -v mvn test             # Show filter details
snip gain                    # See token savings
```

4. To reload filters (no restart needed):
```bash
# Filters are auto-discovered from ~/.config/snip/filters
# Just run snip again
```

---

## Customization Tips

### 1. Adjust for Your Logging Level

**For DEBUG output**:
```yaml
- action: "remove_lines"
  pattern: "^\\[DEBUG\\]|^\\[TRACE\\]"
```

**For quiet mode**:
```yaml
- action: "keep_lines"
  pattern: "\\[ERROR\\]|\\[WARN\\]|BUILD|SUCCESS"
```

### 2. Add Regex Patterns

Test patterns at https://regex101.com before adding to filters:
```yaml
- action: "keep_lines"
  pattern: "^\\[INFO\\]\\s+([A-Z]+):"  # Matches [INFO] followed by uppercase word
```

### 3. Chain Multiple Actions

Build complexity gradually:
```yaml
pipeline:
  - action: "remove_lines"      # Step 1: Clean noise
    pattern: "Downloading"
  - action: "keep_lines"        # Step 2: Keep important lines
    pattern: "ERROR|WARN|BUILD"
  - action: "group_by"          # Step 3: Summarize
    pattern: "^\\[(\\w+)\\]"
```

### 4. Template Formatting

Use Go template syntax for custom output:
```yaml
- action: "format_template"
  template: |
    ╔════════════════════════════╗
    ║  Build Summary             ║
    ║  Items: {{.count}}         ║
    ║  ━━━━━━━━━━━━━━━━━━━━━━━  ║
    {{.lines}}
    ╚════════════════════════════╝
```

---

## Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| Filter not triggering | Check `match.command` (e.g., `mvn` not `maven`) |
| Too much output still | Add more `remove_lines` patterns |
| Regex not matching | Test at https://regex101.com, use raw strings `\\` |
| YAML parse error | Validate YAML formatting (indentation, quotes) |

---

## Token Savings Reference

Expected token reductions for these filters:

| Command | Before | After | Reduction |
|---------|--------|-------|-----------|
| `mvn test` | ~800 tokens | ~100 tokens | 87.5% |
| `mvn compile` | ~600 tokens | ~80 tokens | 86.7% |
| `mvn clean compile` | ~900 tokens | ~120 tokens | 86.7% |
| `mvn verify` | ~1200 tokens | ~150 tokens | 87.5% |
| `mvn package` | ~700 tokens | ~90 tokens | 87.1% |

---

## See Also

- Main YAML Reference: [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md)
- Repository: https://github.com/edouard-claude/snip
- Wiki: https://github.com/edouard-claude/snip/wiki/Filter-DSL-Reference
