# Copilot Primitives

A curated collection of AI-assisted coding primitives for daily development with GitHub Copilot. Reusable **instructions**, **skills**, and **documentation** designed to maximize developer productivity and minimize LLM token consumption.

## 📦 What's Inside

### 🏗️ Instructions (`.github/instructions/`)
Enforced guidelines for specific architectures and patterns:
- **Hexagonal Architecture** — Strict enforcement of ports & adapters for Java (`**/*.java`)
- **Follow-up Questions** — Confidence-based clarification before code generation (`**`)

### 💡 Skills (14 total)
Skills are now split between **workspace-local skills** and **plugin-packaged skills**:

#### Workspace-Local Skills (`.github/skills/`)
| Skill | Purpose |
|-------|---------|
| **frontend-slides** | Animation-rich HTML presentations |
| **hexagonal-architecture-audit** | Java architecture compliance scoring |
| **setup-snip-hooks** | Project hook scaffolding for snip setup |

#### Plugin-Packaged Skills (`plugins/*`)
| Plugin | Skills |
|-------|--------|
| **token-saving-cli** | fd, rg, jq, xq, yq, batch-config-audit, structural-search |
| **snip-plugin** | snip-auto, snip-install |
| **java-utilities** | javap, java-investigation |

#### Token-Saving CLI Tools (via `plugins/token-saving-cli`)
| Skill | Purpose | Token Savings |
|-------|---------|---------------|
| **fd** | Find files by name, extension, path | 40-60% |
| **rg** | Search text content inside files | 30-98% |
| **yq** | Extract YAML / TOML fields | 90-98% |
| **xq** | Extract XML fields (pom.xml, .csproj) | 90-99% |
| **jq** | Extract JSON fields | 90-99% |

#### Synergy Patterns (via `plugins/token-saving-cli`)
| Skill | Combination | Token Savings |
|-------|-------------|---------------|
| **batch-config-audit** | fd + yq/jq/xq — batch field extraction | 95-99% |
| **structural-search** | fd + rg — bi-dimensional codebase search | 94-99% |
| **java-investigation** | fd + jar + javap + rg — bytecode tracing | 87-95% |

#### Snip CLI (via `plugins/snip-plugin`)
| Skill | Scope |
|-------|-------|
| **snip-install** | Install [snip](https://github.com/edouard-claude/snip) CLI + all filters (Maven/mvnd, npm, dotnet) |
| **snip-auto** | Universal command proxy: always prefix with `snip` |

### 📚 Documentation (`docs/`)
Reference and training materials:

- **`token-saving-skills/`** — Guides for fd, rg, yq, xq, batch-config-audit, structural-search
- **`java-investigation/`** — Bytecode investigation guides (javap, pipeline, Blaze-Persistence case study)
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
Skills are discovered automatically by Copilot agents via description keywords. You can use workspace-local skills directly and package reusable sets through plugin manifests.

Example skill references:
```yaml
skills:
  - frontend-slides
  - setup-snip-hooks
  - hexagonal-architecture-audit
```

Plugin distribution metadata lives in `.github/plugin/marketplace.json`, with plugin manifests under `plugins/*/plugin.yaml`.

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
│   ├── plugin/
│   │   └── marketplace.json
│   └── skills/
│       ├── frontend-slides/             (HTML presentations)
│       ├── hexagonal-architecture-audit/
│       ├── setup-snip-hooks/            (project hook scaffolding)
│       └── ...
├── plugins/
│   ├── token-saving-cli/                (fd, rg, jq, xq, yq, batch-config-audit, structural-search)
│   ├── snip-plugin/                     (snip-auto, snip-install)
│   └── java-utilities/                  (javap, java-investigation)
├── docs/
│   ├── token-saving-skills/             (fd, rg, yq, xq guides)
│   ├── java-investigation/              (bytecode guides)
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

### Snip Architecture
```
snip-install (one-time setup) → snip-auto (every command)
```
All filters (Maven, npm, dotnet) are installed in one step. `snip-auto` instructs the agent to always prefix commands with `snip` — graceful degradation if no filter matches.

## 📄 License

**MIT License** — see [LICENSE](./LICENSE).

---

**Built for daily AI-assisted development.** 14 skills, 2 instructions, and plugin-ready packaging for reusable Copilot workflows.
