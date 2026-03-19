# Copilot Primitives

A curated collection of AI-assisted coding workflows, tools, and patterns for daily development. This repository contains reusable **instructions**, **skills**, and **hooks** designed to enhance productivity with GitHub Copilot and other AI tools.

## 📦 What's Inside

### 🏗️ Instructions
Enforced guidelines for specific architectures and patterns:
- **[Hexagonal Architecture](https://github.com/alallier/clean-architecture-manga)** — Strict enforcement of ports & adapters principles for Java projects
  - Ensures domain independence, dependency inversion, and testability
  - Apply to: `**/*.java`

### 💡 Skills
Domain-specific workflows and best practices for specialized tasks:

#### 1. **Frontend Slides** 
Create stunning, animation-rich HTML presentations from scratch or convert PowerPoint files into web-based slides.
- Use for: Building presentations, converting PPT/PPTX to interactive HTML, creating talks/pitches
- Features: Animation patterns, style presets, viewport-responsive CSS
- Files: `SKILL.md`, `STYLE_PRESETS.md`, `animation-patterns.md`, HTML templates

#### 2. **Hexagonal Architecture Audit**
Comprehensive evaluation of Java project compliance with hexagonal architecture principles.
- Analyzes: Domain independence, port definition, adapter isolation, dependency injection, application orchestration, testability, model immutability
- Outputs: Detailed reports with percentage scores, violation listings, actionable recommendations
- Use for: Architecture validation, refactoring guidance, compliance checking

#### 3. **Setup Snip Hooks**
Integration and configuration guide for [snip](https://github.com/edouard-claude/snip) — a token reduction CLI for Maven/Java projects.
- Features: Pre-built Maven filter profiles, token savings tracking, automated setup
- Includes: 5 ready-to-use profiles (`mvn-compile`, `mvn-test`, `mvn-verify`, `mvn-package`)
- Use for: Reducing LLM token consumption in Maven workflows, optimizing CI/CD pipelines
- Quick start: See [setup-snip-hooks README](./github/skills/setup-snip-hooks/README.md)

### 🔗 Hooks
Utility scripts and configuration for automation:
- **snip-rewrite.sh** — Automated setup script for snip integration
- **hooks.json** — Hook configuration

### 📚 Snip CLI Documentation
Complete reference documentation for snip integration:
- [Quick Start YAML Filters](./snip/docs/QUICK_START_YAML_FILTERS.md) — 5-minute filter syntax tutorial
- [SNIP YAML Reference](./snip/docs/SNIP_YAML_REFERENCE.md) — Comprehensive syntax documentation (21KB)
- [SNIP YAML Filters Index](./snip/docs/SNIP_YAML_FILTERS_INDEX.md) — Navigation index
- [Maven Filters Examples](./snip/docs/MAVEN_FILTERS_EXAMPLES.md) — 15+ ready-to-use examples
- [Implementation Summary](./snip/docs/IMPLEMENTATION_SUMMARY.md) — Architecture and implementation details
- [Snip Exploration Results](./snip/docs/SNIP_EXPLORATION_RESULTS.md) — Research findings

## 🚀 Quick Start

### Using Instructions in Your Project
Add to your VS Code workspace settings or use with Copilot extensions:
```json
{
  "instructions": "./github/instructions/hexagonal-architecture.instructions.md"
}
```

### Using Skills
Reference skills in your GitHub Copilot instructions or agent configurations:
```yaml
# In your .instructions.md or AGENTS.md
skills:
  - frontend-slides
  - hexagonal-architecture-audit
  - setup-snip-hooks
```

### Setup Snip Hooks
```bash
# One-time setup for a Maven project
bash .github/skills/setup-snip-hooks/templates/snip-rewrite.sh <project>

# Use with Maven commands (automatically applies filters)
snip mvn clean test
snip mvn clean compile

# Check token savings
snip gain --daily
```

## 🏛️ Architecture

The repository follows a modular structure:
- **`.github/instructions/`** — Architectural rules and coding guidelines
- **`.github/skills/`** — Domain-specific workflows with documentation
- **`.github/hooks/`** — Automation utilities
- **`snip/`** — CLI documentation and reference materials
- **`LICENSE`** — MIT License

## 💻 Technologies & Tools

- **snip** — Token reduction CLI for Maven
- **Hexagonal Architecture** — Clean architecture pattern for Java
- **GitHub Copilot** — AI-powered code assistance
- **HTML/CSS/JavaScript** — Frontend presentation framework

## 📖 Documentation

Each skill includes comprehensive documentation:
- `SKILL.md` — Detailed usage guide and best practices
- `README.md` — Quick start guide
- Domain-specific reference files for deep-dive learning

## 👨‍💻 Author

**knight_max** — Created as a personal toolkit for enhanced AI-assisted development workflows.

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](./LICENSE) file for details.

## 🤝 Usage in Your Workflow

This repository is designed to be:
1. **Referenced** in your GitHub Copilot configuration for behavioral guidelines
2. **Cloned/Submoduled** into other projects for instruction reuse
3. **Extended** with your own custom skills and instructions
4. **Iterated** as you discover new patterns and workflows

## 🎯 Key Features

- ✅ Pre-built skills for common development tasks
- ✅ Strict architectural enforcement through instructions
- ✅ Token optimization for LLM-driven development
- ✅ Well-documented, production-ready patterns
- ✅ MIT Licensed — free to use and extend

---

**Built for daily development with AI assistance.** Optimize your coding workflow with proven patterns and reusable components.
