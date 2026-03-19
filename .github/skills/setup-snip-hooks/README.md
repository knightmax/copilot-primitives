# snip Setup Skill — Quick Start

[![snip](https://img.shields.io/badge/snip-v0.6.3-brightgreen)](https://github.com/edouard-claude/snip)
[![Maven](https://img.shields.io/badge/Maven-3.9+-blue)](https://maven.apache.org)
[![Token Reduction](https://img.shields.io/badge/Token%20Reduction-93%25-success)](https://github.com/edouard-claude/snip)

Automatically configure `snip` CLI token reduction for Maven/Java projects with global filter installation.

---

## 🚀 Quick Start (2 minutes)

### macOS / Linux

**1. Install snip** (first time only)
```bash
curl -L https://github.com/edouard-claude/snip/releases/download/v0.6.3/snip-macos \
  -o /usr/local/bin/snip && chmod +x /usr/local/bin/snip
snip --version
```

**2. Run setup script**
```bash
cd /path/to/workspace
bash .github/skills/setup-snip-hooks/templates/snip-rewrite.sh rescue-mission-good-architecture
```

**3. Try it out**
```bash
cd rescue-mission-good-architecture
snip mvn clean test        # Run with reduced noise
snip gain --daily          # See token savings (93%+ reduction!)
```

### Windows (PowerShell)

**1. Install snip** (first time only)
```powershell
# Option A: Using Scoop
scoop install snip

# Option B: Manual download
# Download from: https://github.com/edouard-claude/snip/releases
# Extract and add to PATH

snip --version
```

**2. Run setup script**
```powershell
cd C:\path\to\workspace

# Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the setup
& '.\​.github\skills\setup-snip-hooks\templates\snip-rewrite.ps1' rescue-mission-good-architecture
```

**3. Try it out**
```powershell
cd rescue-mission-good-architecture
snip mvn clean test        # Run with reduced noise
snip gain --daily          # See token savings (93%+ reduction!)
```

---
## ✨ Automatisation Activée

**After setup is complete, Maven commands are automatically proxified!**

### When you make a Copilot prompt:

```
You: "run mvn clean test in the project"
Copilot automatically executes: snip mvn clean test
```

The setup installs a **preToolUse hook** in `.github/hooks/` that intercepts:
- ✅ `mvn` commands → proxified via snip
- ✅ Plus 15+ other commands (npm, docker, git, cargo, etc.)
- ❌ Your manual terminal commands are not affected

This means:
- **93%+ token reduction** automatically applied
- **Only when Copilot runs commands**
- **No manual setup needed** — the hook runs automatically

---
## � Filter Installation Paths

After setup, filters are installed to:

| Platform | Location |
|----------|----------|
| **macOS / Linux** | `~/.config/snip/filters/` |
| **Windows** | `%APPDATA%\snip\filters\` |

All Maven snip profiles are installed globally — they work across **all projects** automatically.

---

## 📊 What You Get

| Metric | Value |
|--------|-------|
| **Token Reduction** | 93%+ average |
| **Setup Time** | < 2 minutes |
| **Filters Provided** | 6 Maven profiles |
| **Scope** | Global (per-platform location) |

---

## 📦 Available Filters

- `mvn-compile.yaml` — `snip mvn compile` — Build with reduced noise
- `mvn-test.yaml` — `snip mvn test` — Surefire tests with concise output
- `mvn-verify.yaml` — `snip mvn verify` — Failsafe integration tests
- `mvn-package.yaml` — `snip mvn package` — JAR/WAR build steps
- `mvn-install.yaml` — `snip mvn install` — Build, test, and local installation
- `mvn.yaml` — `snip mvn <any>` — General Maven fallback filter

---

## 🎯 How It Works

1. **Setup** installs filters globally to `~/.config/snip/filters/`
2. **snip** automatically discovers filters using `"match.command"` and `"match.subcommand"`
3. **Filters reduce** verbose output, keep errors/warnings/build results
4. **Result**: CLI output with ~93% fewer tokens

**Example**: `snip mvn test` → Automatically uses `mvn-test.yaml` → Output with test results only

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [SKILL.md](./SKILL.md) | Full skill documentation |
| [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md) | Complete filter syntax reference |
| [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md) | 15+ ready-to-use Maven filters |
| [QUICK_START_YAML_FILTERS.md](./QUICK_START_YAML_FILTERS.md) | 5-min filter tutorial |
| [SNIP_EXPLORATION_RESULTS.md](./SNIP_EXPLORATION_RESULTS.md) | Research & deep dive |

---

## ✅ Verification

After setup, verify everything works:

```bash
# Check installed filters
ls ~/.config/snip/filters/mvn-*.yaml

# Test with verbose output to see filter applied
snip -vv mvn clean compile

# View token savings report
snip gain --daily
snip gain --weekly
```

---

## 🛠️ Customization

Edit any filter to customize its behavior:

```bash
# Edit the test filter
nano ~/.config/snip/filters/mvn-test.yaml
```

Changes  take effect immediately. For syntax, see [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md).

---

## 🔗 Resources

- **snip GitHub**: https://github.com/edouard-claude/snip
- **snip Wiki**: https://github.com/edouard-claude/snip/wiki
- **YAML Syntax**: [SNIP_YAML_REFERENCE.md](./SNIP_YAML_REFERENCE.md)
- **Filter Examples**: [MAVEN_FILTERS_EXAMPLES.md](./MAVEN_FILTERS_EXAMPLES.md)

---

## 🤔 FAQ

**Q: Where are the filters installed?**  
A: `~/.config/snip/filters/` (global, works across all projects)

**Q: Do I need to run setup for each project?**  
A: No. Setup once, all Maven projects can use snip immediately.

**Q: Can I customize the filters?**  
A: Yes! Edit `~/.config/snip/filters/mvn-*.yaml` (change takes effect immediately)

**Q: How much token reduction?**  
A: ~93.6% average (tracked by `snip gain --daily`)

**Q: Does it slow down Maven?**  
A: No, snip only post-processes output, doesn't affect build performance

---

## 📝 License

This skill uses [snip](https://github.com/edouard-claude/snip) which is licensed under [MIT](https://github.com/edouard-claude/snip/blob/main/LICENSE).

