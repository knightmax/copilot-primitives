# Token-Saving Skills — CLI Tools for AI Agents

## The Problem

AI coding agents (GitHub Copilot, Claude, Cursor...) consume **tokens** with every interaction. Reading a 500-line file, listing a 10,000-file directory, or displaying raw `mvn test` output — all of it translates into billed tokens and wasted context.

An LLM's context window is a **finite resource**. Every unnecessary token:
- **Shrinks the available window** for reasoning and relevant code
- **Dilutes the signal**: critical information gets buried in noise
- **Slows down iterations**: more data to analyze = slower responses
- **Increases cost**: input tokens are billed by providers

## The Solution: Surgical Extraction

Instead of reading entire files, **extract only the fields you need** directly from the command line. Six CLI tools, combined into two synergies, cover 95% of use cases.

### Base Tools

| Tool | Role | Typical Savings |
|------|------|----------------|
| [**fd**](fd.md) | Find files by name, extension, path | 40-60% vs `find` / `Get-ChildItem` |
| [**rg**](rg.md) | Search text inside files | 30-98% vs full file reads |
| [**yq**](yq.md) | Extract YAML / TOML fields | 90-98% vs full file reads |
| [**xq**](xq.md) | Extract XML fields (`yq -p xml`) | 90-99% vs full file reads |

### Synergies

| Synergy | Combination | Typical Savings |
|---------|-------------|----------------|
| [**batch-config-audit**](batch-config-audit.md) | `fd` + `yq`/`jq`/`xq` — batch extraction | 95-99% |
| [**structural-search**](structural-search.md) | `fd` + `rg` — two-dimensional search | 94-99% |

## Why These Tools Specifically?

These tools share three properties essential for AI agents:

1. **Relative paths by default** — `catalog/systems/osmose.yaml` instead of `/home/user/workspace/project/catalog/systems/osmose.yaml`. Fewer characters = fewer tokens.

2. **`.gitignore` awareness** — No `node_modules/`, no `target/`, no `.git/`. Automatically eliminates noise without configuration.

3. **Compact, structured output** — Each tool returns exactly the requested information, nothing more.

## The Numbers

Real-world case: auditing 749 system entities in a Backstage catalog.

| Approach | Tokens Consumed | Time |
|----------|----------------|------|
| Read each file (`read_file` × 749) | ~251,000 tokens | Minutes |
| `fd -e yaml . catalog/systems -x yq '.metadata.name' {}` | ~5,000 tokens | Seconds |
| **Reduction** | **-98%** | |

## Quick Install

All tools install in a single command:

### macOS (Homebrew)

```bash
brew install fd ripgrep yq jq
```

### Linux (apt)

```bash
sudo apt-get install -y fd-find ripgrep
# yq: see docs/token-saving-skills/yq.md for manual installation
```

### Windows (winget)

```powershell
winget install sharkdp.fd
winget install BurntSushi.ripgrep.MSVC
winget install MikeFarah.yq
winget install jqlang.jq
```

> **Note**: `xq` is not a separate tool — it's `yq` with the `-p xml` flag.

## Decision Tree

```
What are you looking for?
│
├── Files (by name, extension, path)
│   └── → fd
│
├── Text inside files
│   └── → rg
│
├── A field in a YAML/TOML file
│   └── → yq
│
├── A field in an XML file (pom.xml, .csproj...)
│   └── → xq (yq -p xml)
│
├── The same field across N config files
│   └── → batch-config-audit (fd + yq/jq/xq)
│
└── Files of a certain type containing specific text
    └── → structural-search (fd + rg)
```

## Integration with AI Agents

These skills are designed as **Copilot primitives** (`SKILL.md` files) automatically loaded by the agent when a request matches. The agent:

1. Detects the need (e.g., "list all component owners")
2. Loads the appropriate skill (e.g., `batch-config-audit`)
3. Executes the optimized command instead of reading files one by one
4. Returns the result using a fraction of the tokens

No manual configuration is required — skills trigger based on keywords in the user's request.

## Detailed Documentation

- [fd — File Search](fd.md)
- [rg — Text Search (ripgrep)](rg.md)
- [yq — YAML / TOML Extraction](yq.md)
- [xq — XML Extraction](xq.md)
- [batch-config-audit — Batch Audit](batch-config-audit.md)
- [structural-search — Two-Dimensional Search](structural-search.md)

## Origin

This approach is inspired by the article [Les outils CLI qui ont transformé mes agents IA](https://mathieugrenier.fr/blog/coder-avec-claude-c-est-facile-et-rapide-1/les-outils-cli-qui-ont-transforme-mes-agents-ia-audit-adoption-et-synergies-27) by Mathieu Grenier, which documents the concrete impact of these tools on AI coding agent productivity.

## License

MIT — see [LICENSE](../../LICENSE) at the repository root.
