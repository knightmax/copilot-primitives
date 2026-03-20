---
name: "Copilot Primitives"
description: "This is a meta-repository for reusable AI-assisted coding workflows. It contains Instructions (architectural enforcement), Skills (domain-specific tasks), and Documentation (training materials, presentations). When working here, treat this as a package builder—focus on clarity, reusability, and test-driven validation of examples."
---

# Copilot Primitives Workspace Instructions

This repository is a **curated collection of AI-assisted coding primitives** designed for daily development with GitHub Copilot. Think of it as a "package" of reusable workflows and patterns.

## 📦 What This Repository Contains

### **Instructions** (`.github/instructions/`)
Enforced guidelines and rules that apply to specific code domains:
- **`hexagonal-architecture.instructions.md`** — Strict enforcement of Hexagonal Architecture (Ports & Adapters) principles for Java projects
  - Applies to: `**/*.java`
  - Validates: Domain independence, dependency inversion, layer separation, testability
- **`follow-up-question.instructions.md`** — Confidence-based clarification before code generation
  - Applies to: `**`

### **Skills** (`.github/skills/`)
17 domain-specific workflows organized into four families:

#### Token-Saving CLI Tools
- **`fd/`** — Find files by name, extension, path (40-60% savings)
- **`rg/`** — Search text content inside files with ripgrep (30-98% savings)
- **`yq/`** — Extract YAML / TOML fields (90-98% savings)
- **`xq/`** — Extract XML fields via `yq -p xml` (90-99% savings)
- **`jq/`** — Extract JSON fields (90-99% savings)

#### Synergy Patterns
- **`batch-config-audit/`** — fd + yq/jq/xq: batch extraction of the same field from N config files (95-99% savings)
- **`structural-search/`** — fd + rg: bi-dimensional search by structure AND content (94-99% savings)
- **`java-investigation/`** — fd + jar + javap + rg: bytecode-level tracing pipeline (87-95% savings)

#### Snip CLI (Output Filtering)
- **`snip-core/`** — Installation & verification of [snip](https://github.com/edouard-claude/snip)
- **`snip-filters-setup/`** — Shared YAML filter installer, handles command aliases (mvn → mvnd)
- **`snip-jvm/`** — Maven / mvnd output reduction (80-95%)
- **`snip-dotnet/`** — dotnet CLI output reduction
- **`snip-npm/`** — npm CLI output reduction
- **`setup-snip-hooks/`** — Full project hook scaffolding for Maven/Java

#### Other Skills
- **`javap/`** — JDK bytecode analysis reference (jar, javap, jdeps)
- **`frontend-slides/`** — Zero-dependency, viewport-responsive HTML presentations
- **`hexagonal-architecture-audit/`** — Seven-dimension architecture compliance scoring

### **Documentation** (`docs/`)
Training materials, reference guides, and presentations:
- **`token-saving-skills/`** — Guides for fd, rg, yq, xq, batch-config-audit, structural-search
- **`java-investigation/`** — Bytecode investigation guides, Blaze-Persistence case study
- **`snip/`** — snip CLI reference (YAML filters, Maven examples, implementation)
- **`snip-skills/`** — Snip skills architecture overview
- **`prez/`** — HTML slide presentations (French)
  - `economie-de-tokens.html` — Token economy (Bold Signal theme, 15 slides)
  - `investigation-java.html` — Java investigation (Terminal Green theme, 14 slides)

## 🎯 Core Principles

### 1. **Reusability Above All**
Every skill and instruction must be:
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
│   ├── copilot-instructions.md
│   ├── instructions/
│   │   ├── follow-up-question.instructions.md
│   │   └── hexagonal-architecture.instructions.md
│   └── skills/
│       ├── fd/                          (file finder)
│       ├── rg/                          (ripgrep)
│       ├── yq/                          (YAML/TOML extractor)
│       ├── xq/                          (XML extractor)
│       ├── jq/                          (JSON extractor)
│       ├── batch-config-audit/          (fd + yq/jq/xq synergy)
│       ├── structural-search/           (fd + rg synergy)
│       ├── java-investigation/          (bytecode pipeline)
│       ├── javap/                       (JDK bytecode tools)
│       ├── snip-core/                   (snip install/setup)
│       ├── snip-filters-setup/          (shared filter installer)
│       ├── snip-jvm/                    (Maven/mvnd filters)
│       ├── snip-dotnet/                 (dotnet filters)
│       ├── snip-npm/                    (npm filters)
│       ├── setup-snip-hooks/            (project hook scaffolding)
│       ├── frontend-slides/             (HTML presentations)
│       └── hexagonal-architecture-audit/
├── docs/
│   ├── token-saving-skills/             (fd, rg, yq, xq guides)
│   ├── java-investigation/              (bytecode guides)
│   ├── snip/                            (snip reference docs)
│   ├── snip-skills/                     (skills architecture)
│   └── prez/                            (HTML slide decks)
├── README.md
└── LICENSE                              (MIT)
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

### **Working with Documentation**
Documentation lives in `docs/` and is organized by topic:
- **`token-saving-skills/`** — One README + one guide per tool (fd, rg, yq, xq) + synergies
- **`java-investigation/`** — README + javap reference + investigation pipeline guide
- **`snip/`** — Complete snip CLI reference (YAML filters, Maven examples)
- **`snip-skills/`** — Architecture overview of the layered snip skills
- **`prez/`** — Self-contained single-file HTML presentations (viewport-responsive, no dependencies)

When updating docs, keep them aligned with the matching skill's SKILL.md.

## 💡 Key Concepts

### **applyTo Patterns**
Controls when instructions are loaded:
- `**/*.java` — All Java files
- `src/api/**/*.ts` — TypeScript in API folder
- `**` — Universal (use sparingly, burns context)
- Avoid `**/*` unless the instruction truly applies everywhere

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
- Move large reference docs to `docs/` or subdirectories
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
