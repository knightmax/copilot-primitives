# snip YAML Filter Syntax & Examples

Comprehensive reference for creating snip filter files. This guide covers the exact YAML syntax, how snip discovers and loads filters, and practical examples for Maven, tests, and compilation.

---

## Table of Contents

1. [Filter Discovery & Loading](#filter-discovery--loading)
2. [YAML Structure & Syntax](#yaml-structure--syntax)
3. [Match Conditions](#match-conditions)
4. [Argument Injection (Optional)](#argument-injection-optional)
5. [16 Pipeline Actions](#16-pipeline-actions)
6. [Practical Examples](#practical-examples)
7. [Testing Your Filters](#testing-your-filters)

---

## Filter Discovery & Loading

### Directory Structure

snip discovers filter files from two locations (in priority order):

1. **User filters** — `~/.config/snip/filters/` (highest priority)
2. **Embedded filters** — Built into the snip binary (fallback)

User filters override embedded filters with the same name.

### File Format & Naming

- **File extension**: Must be `.yaml` (not `.yml`)
- **Naming convention**: Use lowercase with hyphens, matching the tool name:
  - `git-log.yaml` for `git log` filtering
  - `go-test.yaml` for `go test` filtering
  - `mvn-compile.yaml` for `mvn compile` filtering
- **One filter per file**: Each `.yaml` file contains exactly one filter definition

### Loading Process

snip's loader (`internal/filter/loader.go`):

```go
func LoadUserFilters(dir string) ([]Filter, error) {
	entries, err := os.ReadDir(dir)
	// Only processes .yaml files, skips directories
	// On parse error: prints warning to stderr but continues (graceful degradation)
	// Successfully parsed filters are registered in the filter registry
}
```

**Key behaviors**:
- ✅ Automatically discovers all `.yaml` files in `~/.config/snip/filters/`
- ✓ Silently skips invalid YAML with error message (graceful degradation)
- ✓ User filters override built-in filters with same name
- ✗ Subdirectories are ignored (flat structure only)

---

## YAML Structure & Syntax

### Complete Filter Skeleton

```yaml
name: "filter-name"
version: 1
description: "What this filter does"

match:
  command: "tool-name"                    # Required: main command (git, go, mvn, etc.)
  subcommand: "subcommand"                # Optional: git log, git status, mvn compile, etc.
  exclude_flags: ["--format", "--pretty"]  # Optional: skip filtering if these flags present
  require_flags: ["--verbose"]            # Optional: only filter if these flags present

inject:                                    # Optional: inject args before execution
  args: ["--arg1", "--arg2"]              # Args to always inject
  defaults:                               # Default values for flags
    "-n": "10"
    "--max-lines": "50"
  skip_if_present: ["--format", "--pretty"]  # Don't inject if user already provided these

pipeline:                                  # Required: ordered sequence of filtering actions
  - action: "keep_lines"
    pattern: "\\S"                        # Regex pattern
  - action: "head"
    n: 10                                 # Action-specific params
  - action: "format_template"
    template: "{{.count}} items:\n{{.lines}}"

on_error: "passthrough"                   # Error handling: "passthrough", "empty", or "template"
```

### Field Reference

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | ✓ | Unique identifier for the filter |
| `version` | int | ✓ | Always `1` (for future versioning) |
| `description` | string | ✗ | Human-readable description |
| `match.command` | string | ✓ | Main command to match (git, go, mvn, cargo, etc.) |
| `match.subcommand` | string | ✗ | Subcommand or flag (log, test, compile, etc.) |
| `match.exclude_flags` | array | ✗ | Skip filtering if any of these flags present |
| `match.require_flags` | array | ✗ | Only filter if ALL of these flags present |
| `inject.args` | array | ✗ | Arguments to inject before execution |
| `inject.defaults` | map | ✗ | Default flag values (map of flag → value) |
| `inject.skip_if_present` | array | ✗ | Don't inject if user already provided these |
| `pipeline` | array | ✓ | List of filtering actions (in order) |
| `on_error` | string | ✗ | Error handling mode (default: "passthrough") |

### Validation Rules

snip validates filters on load (`internal/filter/parser.go`):

```go
func ValidateFilter(f *Filter) error {
	if f.Name == "" {
		return fmt.Errorf("validate filter: missing 'name'")
	}
	if f.Match.Command == "" {
		return fmt.Errorf("validate filter %q: missing 'match.command'", f.Name)
	}
	for i, action := range f.Pipeline {
		if action.ActionName == "" {
			return fmt.Errorf("validate filter: pipeline[%d] missing 'action'", i)
		}
		if _, ok := GetAction(action.ActionName); !ok {
			return fmt.Errorf("validate filter: pipeline[%d] unknown action %q", i, action.ActionName)
		}
	}
	return nil
}
```

**Required fields**:
- `name` — must not be empty
- `match.command` — must not be empty
- `pipeline` — each action must have valid `action` name

---

## Match Conditions

### Simple Match

Filters any `git log` command:

```yaml
match:
  command: "git"
  subcommand: "log"
```

### With Flag Conditions

Only filter `go test` if user doesn't specify `-json`:

```yaml
match:
  command: "go"
  subcommand: "test"
  exclude_flags: ["-json", "-v"]  # Skip filtering if these flags present
```

Filter only if user specifies `--verbose`:

```yaml
match:
  command: "mvn"
  subcommand: "compile"
  require_flags: ["--verbose"]    # Only filter if ALL these flags present
```

### Registry Matching

Snip matches against command and subcommand extracted from shell arguments:

```go
// For: git log --oneline
Command:    "git"
Subcommand: "log"
Args:       ["--oneline"]

// For: mvn clean compile -T 4
Command:    "mvn"
Subcommand: "clean" (first non-flag arg)
Args:       ["clean", "compile", "-T", "4"]

// For: go test ./...
Command:    "go"
Subcommand: "test"
Args:       ["./..."]
```

---

## Argument Injection (Optional)

### Purpose

Inject arguments **before** command execution to optimize output at the source (e.g., `git log --pretty=format:...`).

### Injection Process

```go
type Inject struct {
	Args          []string          // Always inject these
	Defaults      map[string]string // Default flag values
	SkipIfPresent []string          // Don't inject if user provided these
}
```

**Example**: For `git log`, inject `--oneline` by default:

```yaml
inject:
  args: ["--pretty=format:%h %s (%ar) <%an>", "--no-merges"]
  defaults:
    "-n": "10"
  skip_if_present: ["--format", "--pretty", "--oneline"]
```

- ✓ Always adds `--pretty=format:%h %s (%ar) <%an>` and `--no-merges`
- ✓ Adds `-n 10` if not already present
- ✗ Skips injection if user provided `--format`, `--pretty`, or `--oneline`

### Use Cases

1. **Optimize at source**: `git log --pretty=format:...` produces compact output upfront
2. **Set defaults**: `go test -v -count=1` (-v for verbose, -count=1 disables cache)
3. **Add safe flags**: `cargo test --no-capture` (always safe, improves output)

---

## 16 Pipeline Actions

Pipeline actions process output line-by-line. Each action receives `ActionResult` and returns filtered `ActionResult`.

### ActionResult Structure

```go
type ActionResult struct {
	Lines    []string           // Output lines
	Metadata map[string]any     // Context data (groups, stats, etc.)
}
```

### Action Reference

#### 1. `keep_lines` — Keep matching lines

```yaml
- action: "keep_lines"
  pattern: "\\S"  # Regex pattern (required)
```

Keeps lines matching the regex. Inverse of `remove_lines`.

**Example**: Keep only non-blank lines
```yaml
- action: "keep_lines"
  pattern: "\\S"
```

---

#### 2. `remove_lines` — Remove matching lines

```yaml
- action: "remove_lines"
  pattern: "^Compiling"  # Regex pattern (required)
```

Removes lines matching the regex.

**Example**: Remove compilation progress lines
```yaml
- action: "remove_lines"
  pattern: "^\\[.*%\\]|Compiling|Building"
```

---

#### 3. `truncate_lines` — Truncate long lines

```yaml
- action: "truncate_lines"
  max: 80  # Max line length (default: 120)
```

Truncates each line to max length.

**Example**: Limit to 80 chars per line
```yaml
- action: "truncate_lines"
  max: 80
```

---

#### 4. `strip_ansi` — Remove ANSI escape codes

```yaml
- action: "strip_ansi"
```

Removes color codes and terminal formatting.

**Example**: Clean colored test output
```yaml
- action: "strip_ansi"
```

---

#### 5. `head` — Keep first N lines

```yaml
- action: "head"
  n: 10  # Number of lines to keep (default: 10)
```

**Example**: Keep first 20 lines
```yaml
- action: "head"
  n: 20
```

---

#### 6. `tail` — Keep last N lines

```yaml
- action: "tail"
  n: 10  # Number of lines to keep (default: 10)
```

**Example**: Keep last 5 lines (summary)
```yaml
- action: "tail"
  n: 5
```

---

#### 7. `group_by` — Group and count by regex capture

```yaml
- action: "group_by"
  pattern: "^\\[(\\w+)\\]"      # Regex with capture group (required)
  top: 10                        # Top N groups (0 = all, default: 0)
  format: "{{.Key}}: {{.Count}}" # Output format (default shown)
```

Groups lines by first regex capture group and counts occurrences.

**Example**: Group test results by status
```yaml
- action: "group_by"
  pattern: "^(PASS|FAIL|SKIP)"
  format: "{{.Key}}: {{.Count}}"
```

Output:
```
FAIL: 3
PASS: 47
SKIP: 2
```

---

#### 8. `dedup` — Deduplicate lines

```yaml
- action: "dedup"
  normalize: "trim"  # Optional: "trim" | "lowercase" | "full" (default: no norm)
  limit: 5           # Optional: max groups to show
```

Deduplicates lines, shows count of duplicates.

**Example**: Deduplicate error messages
```yaml
- action: "dedup"
  normalize: "trim"
```

Output: `error: package not found (x5)`

---

#### 9. `json_extract` — Extract JSON fields

```yaml
- action: "json_extract"
  fields: ["name", "status", "count"]  # JSON fields to extract (required)
```

Extracts specified fields from JSON objects.

**Example**: Extract key fields from JSON test results
```yaml
- action: "json_extract"
  fields: ["test", "result", "duration"]
```

---

#### 10. `json_schema` — Infer JSON schema

```yaml
- action: "json_schema"
  max_depth: 3  # Max depth to traverse (default: 3)
```

Infers and displays schema of JSON objects.

**Example**: Show structure of API response
```yaml
- action: "json_schema"
  max_depth: 2
```

---

#### 11. `ndjson_stream` — Process newline-delimited JSON

```yaml
- action: "ndjson_stream"
  group_by: "package"              # Group by field (optional)
  format: "{{.Key}}: {{.Count}}"   # Format (default shown)
```

Groups newline-delimited JSON by field.

**Example**: Group test results by package
```yaml
- action: "ndjson_stream"
  group_by: "module"
  format: "{{.Key}}: {{.Count}} tests"
```

---

#### 12. `regex_extract` — Extract regex captures

```yaml
- action: "regex_extract"
  pattern: "^(\\w+):\\s+(.+)$"    # Regex with capture groups (required)
  format: "$1 → $2"                # Format with $1, $2, ... (optional)
```

Extracts regex capture groups.

**Example**: Extract error level and message
```yaml
- action: "regex_extract"
  pattern: "^\\[(\\w+)\\]\\s+(.+)$"
  format: "[$1] $2"
```

---

#### 13. `state_machine` — Multi-state line processing

```yaml
- action: "state_machine"
  states:
    start:
      keep: "^\\[(BUILD|TEST)\\]"
      until: "^\\[ERROR\\]"
      next: "errors"
    errors:
      keep: "^."
      until: "^\\[SUMMARY\\]"
      next: "summary"
    summary:
      keep: "^.*"
```

Processes lines in multiple states, useful for complex output patterns.

---

#### 14. `aggregate` — Count pattern matches

```yaml
- action: "aggregate"
  patterns:
    passed: "^✓"
    failed: "^✗"
    skipped: "^○"
```

Counts lines matching each pattern.

**Example**: Summarize test results
```yaml
- action: "aggregate"
  patterns:
    pass: "^ok\\s+"
    fail: "^FAIL\\s+"
    skip: "^skip\\s+"
```

Output:
```
fail: 2
pass: 45
skip: 3
```

---

#### 15. `format_template` — Go template formatting

```yaml
- action: "format_template"
  template: "{{.count}} items processed\n{{.lines}}"
```

Formats output using Go text/template syntax.

**Available variables**:
- `{{.lines}}` — All output lines (joined with newlines)
- `{{.count}}` — Number of lines
- `{{.groups}}` — Grouped data (from `group_by`)
- `{{.stats}}` — Statistics (from `aggregate`)

**Example**: Format as summary
```yaml
- action: "format_template"
  template: "Test Summary\n============\n{{.lines}}\nTotal: {{.count}}"
```

---

#### 16. `compact_path` — Shorten file paths

```yaml
- action: "compact_path"
```

Removes directory prefixes, keeps only filename.

**Example**: Shorten paths
```
src/main/java/com/example/Main.java → Main.java
lib/utils.js                         → utils.js
README.md                           → README.md
```

---

## Practical Examples

### Example 1: Maven Compilation Filter

**File**: `~/.config/snip/filters/mvn-compile.yaml`

```yaml
name: "mvn-compile"
version: 1
description: "Filter Maven compile output to show only errors and summary"

match:
  command: "mvn"
  subcommand: "compile"

inject:
  defaults:
    "-q": ""  # Quiet mode default

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Scanning|Building|Downloading|Downloaded)"
  - action: "remove_lines"
    pattern: "^\\[DEBUG\\]"
  - action: "keep_lines"
    pattern: "\\[ERROR\\]|\\[WARN\\]|BUILD|ERROR|WARNING|SUCCESS"
  - action: "truncate_lines"
    max: 120
  - action: "strip_ansi"
  - action: "head"
    n: 50

on_error: "passthrough"
```

**Usage**:
```bash
snip mvn compile      # Filters output
snip mvn clean compile # Also matches (compile is subcommand)
```

**Token savings**: ~85% (reduces Maven debug spam)

---

### Example 2: Maven Test Filter

**File**: `~/.config/snip/filters/mvn-test.yaml`

```yaml
name: "mvn-test"
version: 1
description: "Summarize Maven test results"

match:
  command: "mvn"
  subcommand: "test"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning|Building)"
  - action: "remove_lines"
    pattern: "^\\[DEBUG\\]"
  - action: "keep_lines"
    pattern: "Tests run:|Failures:|Errors:|Skipped:|BUILD|SUCCESS|FAILURE"
  - action: "group_by"
    pattern: "^.*?(Tests run|Failures|Errors|Skipped|BUILD|SUCCESS).*"
    format: "{{.Key}}: {{.Count}}"
  - action: "format_template"
    template: "Test Summary:\n{{.lines}}"

on_error: "passthrough"
```

---

### Example 3: Go Test Filter

**File**: `~/.config/snip/filters/go-test.yaml`

```yaml
name: "go-test"
version: 1
description: "Condense go test output to summary"

match:
  command: "go"
  subcommand: "test"
  exclude_flags: ["-json", "-v"]

inject:
  args: ["--cover"]
  defaults:
    "-count": "1"

pipeline:
  - action: "remove_lines"
    pattern: "^\\?|^ok\\s+"
  - action: "keep_lines"
    pattern: "PASS|FAIL|coverage|go test"
  - action: "remove_lines"
    pattern: "^\\s*$"
  - action: "aggregate"
    patterns:
      passed: "^ok\\s+"
      failed: "^FAIL\\s+"
  - action: "format_template"
    template: "Test Results:\n{{.lines}}"

on_error: "passthrough"
```

---

### Example 4: Git Log Filter

**File**: `~/.config/snip/filters/git-log.yaml` (built-in example)

```yaml
name: "git-log"
version: 1
description: "Condense git log to one-liner per commit"

match:
  command: "git"
  subcommand: "log"
  exclude_flags: ["--format", "--pretty", "--oneline"]

inject:
  args: ["--pretty=format:%h %s (%ar) <%an>", "--no-merges"]
  defaults:
    "-n": "10"
  skip_if_present: ["--format", "--pretty", "--oneline"]

pipeline:
  - action: "keep_lines"
    pattern: "\\S"
  - action: "truncate_lines"
    max: 80
  - action: "format_template"
    template: "{{.count}} commits:\n{{.lines}}"

on_error: "passthrough"
```

---

### Example 5: Maven Dependency Filter

**File**: `~/.config/snip/filters/mvn-dependency.yaml`

```yaml
name: "mvn-dependency"
version: 1
description: "Filter Maven dependency tree to show only conflicts and key info"

match:
  command: "mvn"
  subcommand: "dependency"

pipeline:
  - action: "remove_lines"
    pattern: "^\\[INFO\\]\\s+(Downloading|Downloaded|Scanning)"
  - action: "keep_lines"
    pattern: "conflict|excluded|omitted|->|compile|provided|runtime"
  - action: "group_by"
    pattern: "^.*?\\[INFO\\]\\s+(.+?)\\s+--"
    top: 10
  - action: "format_template"
    template: "Dependency Summary:\n{{.lines}}"

on_error: "passthrough"
```

---

### Example 6: Docker Build Filter

**File**: `~/.config/snip/filters/docker-build.yaml`

```yaml
name: "docker-build"
version: 1
description: "Filter Docker build output to show only key steps"

match:
  command: "docker"
  subcommand: "build"

pipeline:
  - action: "remove_lines"
    pattern: "^Sending build context|Removing intermediate|Step\\s+\\d+\\s+RUN\\s.*#@"
  - action: "keep_lines"
    pattern: "Step|Digest|Successfully|ERROR|from|ADD|COPY|RUN|EXPOSE|ENV"
  - action: "truncate_lines"
    max: 100
  - action: "aggregate"
    patterns:
      steps: "^Step"
      success: "^Successfully"
      error: "ERROR"
  - action: "format_template"
    template: "Build Summary:\n{{.lines}}\n\nStats:\n{{.stats}}"

on_error: "passthrough"
```

---

## Testing Your Filters

### 1. Syntax Validation

Use snip's built-in parser to validate YAML:

```bash
snip -v mvn compile    # -v shows filter details
```

If valid, snip shows:
```
Using filter: mvn-compile
...actual filtered output...
```

If invalid YAML, stderr shows error:
```
snip: skipping invalid filter mvn-compile.yaml: parse filter: ...
```

### 2. Manual Testing

```bash
# Test filter without snip
cat sample_output.txt | snip mvn compile  # Won't work; need actual command

# Test with actual command
snip mvn compile -X 2>&1 | head -n 50   # See filtered output

# Compare raw vs filtered
mvn compile 2>&1 | wc -l                 # Raw line count
snip mvn compile 2>&1 | wc -l            # Filtered line count
```

### 3. Create Test Fixtures

For integration testing like in the snip repository:

```bash
mkdir -p tests/fixtures
# Capture raw output
mvn compile 2>&1 > tests/fixtures/mvn_compile_raw.txt
# Your filter will be tested against this
```

### 4. Check Token Savings

After using snip, check the dashboard:

```bash
snip gain                # Full report
snip gain --top 1        # Top command by savings
snip gain --json         # Machine-readable
```

---

## Common Patterns

### Pattern 1: Suppress INFO Messages, Keep Errors

```yaml
- action: "remove_lines"
  pattern: "^\\[INFO\\]|^\\[DEBUG\\]"
- action: "keep_lines"
  pattern: "\\[ERROR\\]|\\[WARN\\]|FAIL|error:|warning:"
```

### Pattern 2: Group Results by Status

```yaml
- action: "aggregate"
  patterns:
    passed: "^✓|^PASS|^ok "
    failed: "^✗|^FAIL|^FAILED"
    skipped: "^⊘|^SKIP|^skipped"
```

### Pattern 3: Extract Key Information

```yaml
- action: "regex_extract"
  pattern: "(.+?)\\s+in\\s+(.+?)ms"
  format: "$1 ($2ms)"
```

### Pattern 4: Compact Summary

```yaml
- action: "head"
  n: 1  # Keep only first line
- action: "tail"
  n: 1  # Keep only last line (summary)
```

### Pattern 5: ANSI Color Cleanup + Truncate

```yaml
- action: "strip_ansi"
- action: "truncate_lines"
  max: 80
```

---

## Error Handling

### `on_error` Modes

| Mode | Behavior |
|------|----------|
| `passthrough` | Show raw unfiltered output on filter error (default) |
| `empty` | Show empty output on filter error |
| `template` | Use custom template (not commonly used) |

**Example**: Graceful fallback

```yaml
on_error: "passthrough"  # If filter fails, show raw output
```

### Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Filter not found | Bad filename (e.g., `.yml` instead of `.yaml`) | Rename to `.yaml` |
| Filter not matching | `match.command` doesn't match | Check exact command name (e.g., `git` not `g`) |
| No output | Pattern too restrictive | Test regex at https://regex101.com |
| Errors in stderr | Filter YAML syntax error | Run `snip init` to validate |

---

## References

- **Repository**: https://github.com/edouard-claude/snip
- **Wiki**: https://github.com/edouard-claude/snip/wiki/Filter-DSL-Reference
- **Source**: `internal/filter/` directory (types.go, actions.go, loader.go)
- **Tests**: `internal/filter/actions_integration_test.go` for integration test examples

---

## Summary

**YAML Filter Essentials**:

1. ✓ Files go in `~/.config/snip/filters/` with `.yaml` extension
2. ✓ Name matches command: `git-log.yaml`, `mvn-compile.yaml`, etc.
3. ✓ Required fields: `name`, `match.command`, `pipeline`
4. ✓ Optional: `inject` (argument injection), `exclude_flags`, `require_flags`
5. ✓ Compose pipelines from 16 actions (keep_lines, remove_lines, aggregate, etc.)
6. ✓ Use regex patterns for powerful filtering
7. ✓ Test with `snip gain` to see token savings

**Token savings examples** (from real data):
- `go test ./...`: 97.7% (689 → 16 tokens)
- `git log`: 85.7% (371 → 53 tokens)
- `cargo test`: 99.2% (591 → 5 tokens)
