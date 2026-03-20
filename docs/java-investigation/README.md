# Java Investigation — Bytecode Analysis Skills

> **Objective**: Understand what Java libraries *actually do* — not what documentation claims — using JDK built-in tools and CLI synergies.

## The Problem

Java frameworks (Hibernate, Spring, Blaze-Persistence...) sometimes have misleading APIs. A method called `getResultStream()` might secretly call `getResultList()` and load everything in memory. Documentation can be outdated, incomplete, or simply wrong.

**Bytecode never lies.** With `javap`, `jar`, and CLI tools, you can trace exactly what a method does at the JVM level — in seconds, not hours.

## Skills Overview

| Skill | Tools | Purpose | Savings |
|-------|-------|---------|---------|
| [javap](javap.md) | `javap`, `jar`, `jdeps` | Decompile bytecode, inspect JARs, analyze dependencies | 87-95% vs reading source on GitHub |
| [java-investigation](java-investigation.md) | `fd` + `javap` + `jar` + `rg` | Full investigation pipeline across multiple JARs | 93-95% vs reading source on GitHub |

## Decision Guide

```
I need to...                              → I use...
│
├── View method signatures of a class     → javap alone
├── Decompile a specific method           → javap -c alone
├── Find a JAR in Maven cache             → fd alone  (or find)
├── List classes inside a JAR             → jar tf alone
├── Trace a method across multiple JARs   → java-investigation (full pipeline)
├── Verify "does it really stream?"       → java-investigation (full pipeline)
├── Analyze module/class dependencies     → jdeps alone
└── Debug unexpected framework behavior   → java-investigation (full pipeline)
```

| Situation | Recommended Skill |
|-----------|-------------------|
| Quick API surface check | [javap](javap.md) — `javap -classpath jar Class` |
| Single method decompilation | [javap](javap.md) — `javap -c -classpath jar Class` |
| Multi-JAR delegation chain | [java-investigation](java-investigation.md) — full pipeline |
| Framework bug hunting | [java-investigation](java-investigation.md) — full pipeline |
| Library comparison (correct vs buggy) | [java-investigation](java-investigation.md) — compare bytecode |

## Prerequisites

All core tools are **included in any JDK** — no separate installation:

```bash
javap -version    # Bytecode disassembler
jar --version     # JAR archive tool
jdeps --version   # Dependency analyzer
```

The investigation synergy also requires:

```bash
fd --version      # File finder (for locating JARs)
rg --version      # Ripgrep (for filtering bytecode output)
```

### Quick Install (fd + rg)

| OS | Command |
|----|---------|
| **macOS** | `brew install fd ripgrep` |
| **Linux (apt)** | `sudo apt-get install -y fd-find ripgrep` |
| **Windows (winget)** | `winget install sharkdp.fd && winget install BurntSushi.ripgrep` |

## Real-World Example: The Blaze-Persistence Fake Streaming Bug

This is the investigation that motivated these skills — discovering that Blaze-Persistence's `getResultStream()` secretly calls `getResultList()` (loading everything in memory):

```bash
# 1. Find the JAR
fd "blaze-persistence-integration-hibernate6-base" ~/.m2 -e jar

# 2. Find the suspect class
jar tf ~/.m2/.../jar | rg "ExtendedQuerySupport"

# 3. Decompile and trace
javap -c -p -classpath ~/.m2/.../jar \
  com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport \
  | rg "getResultStream|getResultList|scroll"
# → REVEALS: getResultStream invokes getResultList (not scroll!)

# 4. Compare with Hibernate's correct implementation
javap -c -classpath ~/.m2/.../hibernate-core-6.2.2.Final.jar \
  org.hibernate.query.spi.AbstractSelectionQuery \
  | rg "getResultStream|scroll"
# → Hibernate uses scroll(FORWARD_ONLY) — true lazy streaming
```

**Result**: 5 commands, ~800 tokens. Reading source on GitHub would have been ~15,000 tokens across multiple repositories.

## Key Bytecode Opcodes

When reading `javap -c` output, these are the opcodes to watch for:

| Opcode | Meaning | What it reveals |
|--------|---------|-----------------|
| `invokevirtual` | Call a method on an object | Method delegation chains |
| `invokeinterface` | Call an interface method | Interface-based dispatching |
| `invokespecial` | Constructor, super, or private call | Internal wiring |
| `invokestatic` | Static method call | Utility/factory usage |
| `new` | Object instantiation | `new ArrayList` = loading everything in memory |
| `getfield` | Access an instance field | Internal state access |

## AI Agent Integration

These skills are designed for AI coding agents (GitHub Copilot, Claude, etc.):

- **Agent reads Javadoc** → trusts the API name → gets wrong behavior
- **Agent uses javap** → reads bytecode → discovers the truth → suggests correct fix

The investigation pipeline (`fd → jar → javap → rg`) can be run entirely from the agent's terminal, producing compact output that fits in the context window.

## Further Reading

- [javap.md](javap.md) — Complete reference for `javap`, `jar`, and `jdeps`
- [java-investigation.md](java-investigation.md) — Full investigation pipeline with `fd` + `rg` synergy
