# snip CLI Documentation & Reference

Reference documentation for [snip](https://github.com/edouard-claude/snip) — Token reduction CLI for Maven/Java projects.

## 📍 Quick Links

**To use snip in your Maven project:**
→ See [`.github/skills/setup-snip-hooks/`](./.github/skills/setup-snip-hooks/)

**Skill Documentation:**
- [`SKILL.md`](../.github/skills/setup-snip-hooks/SKILL.md) — Complete snip integration guide
- [`README.md`](../.github/skills/setup-snip-hooks/README.md) — Quick start (2 minutes)

**Maven Filters (5 ready-to-use profiles):**
- [`profiles/mvn-compile.yaml`](../.github/skills/setup-snip-hooks/profiles/) — `snip mvn compile`
- [`profiles/mvn-test.yaml`](../.github/skills/setup-snip-hooks/profiles/) — `snip mvn test`
- [`profiles/mvn-verify.yaml`](../.github/skills/setup-snip-hooks/profiles/) — `snip mvn verify`
- [`profiles/mvn-package.yaml`](../.github/skills/setup-snip-hooks/profiles/) — `snip mvn package`
- [`profiles/mvn.yaml`](../.github/skills/setup-snip-hooks/profiles/) — Fallback filter

## 📚 Reference Documentation

Located in `/snip/docs/` for deep-dive learning:

### For Learning snip Syntax
1. **[QUICK_START_YAML_FILTERS.md](./docs/QUICK_START_YAML_FILTERS.md)** — 5-minute filter syntax tutorial
2. **[SNIP_YAML_REFERENCE.md](./docs/SNIP_YAML_REFERENCE.md)** — Comprehensive syntax reference (21KB)
3. **[SNIP_YAML_FILTERS_INDEX.md](./docs/SNIP_YAML_FILTERS_INDEX.md)** — Navigation index

### For Maven Filter Examples
- **[MAVEN_FILTERS_EXAMPLES.md](./docs/MAVEN_FILTERS_EXAMPLES.md)** — 15+ ready-to-use filter examples

### For Project Details
- **[IMPLEMENTATION_SUMMARY.md](./docs/IMPLEMENTATION_SUMMARY.md)** — Implementation details & architecture
- **[SNIP_EXPLORATION_RESULTS.md](./docs/SNIP_EXPLORATION_RESULTS.md)** — snip research findings

## 🚀 Quick Start

```bash
# 1. Setup snip (one-time, installs filters globally)
bash .github/skills/setup-snip-hooks/templates/snip-rewrite.sh <project>

# 2. Use with any Maven command
snip mvn clean test        # Automatically uses mvn-test.yaml
snip mvn clean compile     # Automatically uses mvn-compile.yaml

# 3. Check token savings
snip gain --daily
```

## ✨ Results

- **Token Reduction**: 93.4% average
- **Commands Tested**: compile, test, verify, package
- **Projects Tested**: Good & bad architecture examples
- **Setup Time**: < 2 minutes

## 📦 File Structure

```
.github/skills/setup-snip-hooks/   ← Skill directory (essential files)
├── SKILL.md                         ← Full skill documentation  
├── README.md                        ← Quick start guide
├── templates/
│   └── snip-rewrite.sh             ← Setup automation script
├── profiles/
│   ├── mvn-compile.yaml
│   ├── mvn-test.yaml
│   ├── mvn-verify.yaml
│   ├── mvn-package.yaml
│   └── mvn.yaml
└── filters/                         ← Additional filters

/snip/                               ← Reference documentation (this folder)
├── README.md                        ← This file
└── docs/                            ← Deep-dive guides
    ├── QUICK_START_YAML_FILTERS.md
    ├── SNIP_YAML_REFERENCE.md
    ├── MAVEN_FILTERS_EXAMPLES.md
    ├── IMPLEMENTATION_SUMMARY.md
    ├── SNIP_EXPLORATION_RESULTS.md
    └── SNIP_YAML_FILTERS_INDEX.md
```

## 🔗 External Links

- **snip Repository**: https://github.com/edouard-claude/snip
- **snip Documentation**: https://github.com/edouard-claude/snip/tree/main/docs

---

**Status**: ✓ Production Ready | **Token Savings**: 93.4% | **Setup**: < 2 minutes
