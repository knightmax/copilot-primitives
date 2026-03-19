---
name: "Copilot Primitives"
description: "This is a meta-repository for reusable AI-assisted coding workflows. It contains Instructions (architectural enforcement), Skills (domain-specific tasks), and Hooks (CLI automation). When working here, treat this as a package builder—focus on clarity, reusability, and test-driven validation of examples."
---

# Copilot Primitives Workspace Instructions

This repository is a **curated collection of AI-assisted coding primitives** designed for daily development with GitHub Copilot. Think of it as a "package" of reusable workflows and patterns.

## 📦 What This Repository Contains

### **Instructions** (`.github/instructions/`)
Enforced guidelines and rules that apply to specific code domains:
- **`hexagonal-architecture.instructions.md`** — Strict enforcement of Hexagonal Architecture (Ports & Adapters) principles for Java projects
  - Applies to: `**/*.java`
  - Validates: Domain independence, dependency inversion, layer separation, testability

### **Skills** (`.github/skills/`)
Domain-specific workflows optimized for particular tasks. Each skill includes documentation, templates, and asset bundles:

1. **`setup-snip-hooks/`** — Token reduction CLI integration
   - Used for: Scaffolding snip hooks in Maven/Java projects, reducing LLM output token consumption
   - Includes: Setup scripts (bash/PowerShell), Maven filter profiles, documentation
   - Key files: `SKILL.md` (detailed guide), `README.md` (quick start), `templates/`, `profiles/`

2. **`hexagonal-architecture-audit/`** — Architecture compliance evaluation
   - Used for: Auditing Java projects for hexagonal architecture compliance
   - Analyzes: Seven dimensions (domain independence, ports, adapters, DI, orchestration, testability, immutability)
   - Output: Detailed reports with scores, violations, recommendations
   - Key files: `SKILL.md`, `references/` (evaluation criteria)

3. **`frontend-slides/`** — Animation-rich HTML presentation builder
   - Used for: Creating or converting presentations to interactive web-based slides
   - Features: Zero-dependency, custom aesthetics, viewport-responsive design
   - Key files: `SKILL.md`, `STYLE_PRESETS.md`, `animation-patterns.md`, `viewport-base.css`, HTML templates

### **Hooks** (`.github/hooks/`)
Automation scripts for CLI token reduction and project setup:
- **`snip-rewrite.sh`** — Bash script for automating snip integration
- **`hooks.json`** — Hook configuration (when applied to projects, sets up preToolUse event handlers)

### **Documentation** (`.snip/docs/`)
Reference materials for the snip CLI tool:
- Quick start guides, YAML filter syntax, Maven examples, implementation details

## 🎯 Core Principles

### 1. **Reusability Above All**
Every skill, instruction, and hook must be:
- **Portable** — Can be dropped into other projects without modification
- **Well-documented** — Includes SKILL.md, README.md, and practical examples
- **Self-contained** — Includes all necessary templates, styles, and scripts

### 2. **Clarity and Discoverability**
- **Description field matters** — Use "Use when ..." to trigger agent discovery
- **Examples in SKILL.md** — Include concrete usage patterns, not just theory
- **README.md for quick start** — 2-3 minute setup, not just references
- **applyTo patterns** — Specific globs, not `**/*` unless truly universal

### 3. **Test-Driven Practice**
When creating or updating skills:
- **Include executable examples** — E.g., actual Maven commands for snip, HTML snippets for slides
- **Validate in real projects** — Test skill before committing
- **Document edge cases** — What works, what doesn't, why
- **Provide troubleshooting** — Common errors and solutions

### 4. **No Generic Output**
Especially for frontend skills (slides, aesthetics, design):
- Avoid "AI slop" — generic, distribution-tending outputs
- Make distinctive, context-specific choices
- Think creatively about design, typography, color, motion
- Vary aesthetics across examples to prevent convergence onto common patterns

## 📁 Repository Structure

```
copilot-primitives/
├── .github/
│   ├── instructions/
│   │   └── hexagonal-architecture.instructions.md
│   ├── skills/
│   │   ├── setup-snip-hooks/
│   │   │   ├── SKILL.md
│   │   │   ├── README.md
│   │   │   ├── profiles/        (Maven filter YAML files)
│   │   │   ├── filters/         (snip filter definitions)
│   │   │   └── templates/       (bash/PowerShell setup scripts)
│   │   ├── hexagonal-architecture-audit/
│   │   │   ├── SKILL.md
│   │   │   ├── references/      (evaluation criteria docs)
│   │   │   └── templates/       (report templates)
│   │   └── frontend-slides/
│   │       ├── SKILL.md
│   │       ├── STYLE_PRESETS.md
│   │       ├── animation-patterns.md
│   │       ├── viewport-base.css
│   │       ├── html-template.md
│   │       └── LICENSE
│   └── hooks/
│       ├── hooks.json
│       └── snip-rewrite.sh
├── snip/
│   ├── README.md               (snip CLI quick-start + links)
│   └── docs/                   (reference documentation)
├── README.md                    (project overview + usage)
├── LICENSE                      (MIT)
└── .git/
```

## 🚀 How to Work Here

### **Updating an Existing Skill**
1. Read the existing `SKILL.md` to understand scope and examples
2. Update content, add practical examples, test executable commands
3. Ensure `description` field accurately reflects the trigger condition
4. Update `README.md` if quick-start has changed
5. Verify all file references and links still work

### **Creating a New Skill**
1. Create `.github/skills/<name>/` directory
2. Write `SKILL.md` with:
   - YAML frontmatter (name, description, argument-hint, compatibility)
   - Core principles section
   - How-to guide with executable examples
   - Troubleshooting section
3. Create `README.md` (2-3 minute quick start)
4. Include supporting assets (templates, styles, references) as needed
5. Test in a real project before finalizing

### **Adding a New Instruction**
1. Create `.github/instructions/<domain>.instructions.md`
2. Include YAML frontmatter:
   - `name`: Human-readable name
   - `description`: Clear "Use when..." trigger
   - `applyTo`: Specific file glob pattern (e.g., `**/*.java`, `src/components/**/*.tsx`)
3. Document the architecture, principles, and rules clearly
4. Provide code examples showing compliance and violations
5. Include layer diagrams or flowcharts if helpful

### **Working with Hooks**
Hooks live in `.github/hooks/` and are referenced by VS Code extensions:
- **`snip-rewrite.sh`** — Executed via `preToolUse` event to rewrite CLI commands
- **`hooks.json`** — Configures when and how hooks fire (hardcoded cwd required)

When modifying hooks, ensure they are:
- Platform-aware (bash for Unix/Mac, PowerShell for Windows)
- Idempotent (can run multiple times safely)
- Non-blocking (don't hang the agent)

## 💡 Key Concepts

### **applyTo Patterns**
Controls when instructions are loaded:
- `**/*.java` — All Java files
- `src/api/**/*.ts` — TypeScript in API folder
- `.github/hooks/**` — All hooks (explicit loading)
- Avoid `**/*` unless the instruction truly applies everywhere (burns context)

### **Skill Discovery**
Agents find skills by matching keywords in the `description` field:
- ✅ Good: "Use when setting up snip CLI token reduction hooks..."
- ❌ Bad: "Scaffolds hooks for token reduction" (no trigger phrase)

### **SKILL.md vs README.md**
- **SKILL.md** — Comprehensive reference (theory, methodology, edge cases, troubleshooting)
- **README.md** — Quick start guide (2-3 minutes, essential steps only)

### **Hexagonal Architecture Compliance**
For Java files, the hexagonal architecture instruction enforces:
- **Domain Layer** — Framework-independent, no external dependencies
- **Application Layer** — Dependency injection configuration, entry points
- **Adapter Layers** — Technology-specific implementations of ports
- Dependency flow: External → Application → Ports → Domain (inward only)

## 🔄 Maintenance Guidelines

### **Testing & Validation**
- Test every executable example before committing
- Validate skill works in real projects (not just documentation)
- Run commands exactly as documented to ensure they work

### **Documentation Quality**
- Keep descriptions concise but specific (use "Use when..." pattern)
- Include both success and error cases
- Link to reference materials, don't replicate large docs
- Update frontmatter when changing scope or applicability

### **Avoiding Bloat**
- One skill per focused domain (don't merge unrelated features)
- Move large reference docs to `/snip/docs/` or subdirectories
- Keep SKILL.md under 100 lines when possible (detail in references/)
- Link to external sources instead of embedding entire docs

## 📝 Contributing

When adding new primitives:
1. Ensure the contribution solves a real, repeated problem
2. Document examples that work in your daily workflow
3. Keep instructions and skills focused and reusable
4. Follow the naming conventions and structure above
5. Test thoroughly before finalizing

## 🏛️ License

This repository is licensed under the **MIT License**. All skills, instructions, and documentation are free to use and extend.

---

**Built for daily AI-assisted development.** Optimize your coding workflow with proven patterns and reusable components.
