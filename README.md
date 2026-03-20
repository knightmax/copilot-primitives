# Copilot Primitives

A curated collection of AI-assisted coding primitives for daily development with GitHub Copilot. Reusable **instructions**, **skills**, and **documentation** designed to maximize developer productivity and minimize LLM token consumption.

## 📦 What's Inside

### 🏗️ Instructions (`.github/instructions/`)
Enforced guidelines for specific architectures and patterns:
- **Hexagonal Architecture** — Strict enforcement of ports & adapters for Java (`**/*.java`)
- **Follow-up Questions** — Confidence-based clarification before code generation (`**`)

### 💡 Skills (`.github/skills/`)
17 domain-specific workflows organized into four families:

#### Token-Saving CLI Tools
| Skill | Purpose | Token Savings |
|-------|---------|---------------|
| **fd** | Find files by name, extension, path | 40-60% |
| **rg** | Search text content inside files | 30-98% |
| **yq** | Extract YAML / TOML fields | 90-98% |
| **xq** | Extract XML fields (pom.xml, .csproj) | 90-99% |
| **jq** | Extract JSON fields | 90-99% |

#### Synergy Patterns
| Skill | Combination | Token Savings |
|-------|-------------|---------------|
| **batch-config-audit** | fd + yq/jq/xq — batch field extraction | 95-99% |
| **structural-search** | fd + rg — bi-dimensional codebase search | 94-99% |
| **java-investigation** | fd + jar + javap + rg — bytecode tracing | 87-95% |

#### Snip CLI (Output Filtering)
| Skill | Scope |
|-------|-------|
| **snip-core** | Installation & setup of [snip](https://github.com/edouard-claude/snip) |
| **snip-filters-setup** | Shared YAML filter installer |
| **snip-jvm** | Maven / mvnd output reduction (80-95%) |
| **snip-dotnet** | dotnet CLI output reduction |
| **snip-npm** | npm CLI output reduction |
| **setup-snip-hooks** | Full project hook scaffolding |

#### Other Skills
| Skill | Purpose |
|-------|---------|
| **javap** | JDK bytecode analysis (jar, javap, jdeps) |
| **frontend-slides** | Animation-rich HTML presentations |
| **hexagonal-architecture-audit** | Java architecture compliance scoring |

### 📚 Documentation (`docs/`)
Reference and training materials:

- **`token-saving-skills/`** — Guides for fd, rg, yq, xq, batch-config-audit, structural-search
- **`java-investigation/`** — Bytecode investigation guides (javap, pipeline, Blaze-Persistence case study)
- **`snip/`** — snip CLI reference (YAML filters, Maven examples, implementation details)
- **`snip-skills/`** — Snip skills architecture overview
- **`prez/`** — HTML slide presentations
  - `economie-de-tokens.html` — Token economy overview (French, Bold Signal theme)
  - `investigation-java.html` — Java investigation techniques (French, Terminal Green theme)

## 🚀 Quick Start

### Using Instructions
Drop into any project's `.github/instructions/` or reference in VS Code:
```json
{
  "instructions": ".github/instructions/hexagonal-architecture.instructions.md"
}
```

### Using Skills
Skills are discovered automatically by Copilot agents via description keywords. Reference them in your agent configuration:
```yaml
skills:
  - fd
  - rg
  - yq
  - snip-jvm
  - hexagonal-architecture-audit
```

### Token-Saving Example
```bash
# Instead of reading 42 pom.xml files (126k tokens)...
fd -g "pom.xml" . -x yq -p xml -oy '.project.version' {}
# → ~500 tokens total (-99.6%)
```

## 📁 Repository Structure

```
copilot-primitives/
├── .github/
│   ├── copilot-instructions.md          (workspace instructions)
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

## 💡 Key Concepts

### Skill Discovery
Agents find skills by matching keywords in the `description` field:
- ✅ `"Use when setting up snip CLI token reduction hooks..."`
- ❌ `"Scaffolds hooks for token reduction"`

### SKILL.md vs README.md
- **SKILL.md** — Comprehensive reference loaded by agents (theory, edge cases, troubleshooting)
- **README.md** — Quick start for humans (2-3 minutes)

### Layered Snip Architecture
```
snip-core → snip-filters-setup → snip-jvm / snip-dotnet / snip-npm
```
Each layer builds on the previous. `match.command` is exact: a `mvn` filter won't match `mvnd` — the shared installer handles aliases.

## 📄 License

**MIT License** — see [LICENSE](./LICENSE).

---

**Built for daily AI-assisted development.** 17 skills, 2 instructions, tested patterns for reducing LLM token consumption by 90-99%.
