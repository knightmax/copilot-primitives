---
name: snip-auto
description: "Use when running ANY terminal command. Always prefix commands with snip for automatic token reduction. Applies universally to ALL CLI tools: mvn, mvnd, npm, dotnet, git, go, cargo, docker, kubectl, and any other command. Load this skill before running any command in the terminal."
argument-hint: "Prefix every command with snip."
compatibility: copilot
user-invocable: true
disable-model-invocation: false
---

# snip Auto — Universal Command Proxy

## Rule

**Always run `snip <command> [args...]` instead of `<command> [args...]`.**

This applies to **every** terminal command — no exceptions, no allow-list.

- If a filter matches → output is compressed (80-99% fewer tokens)
- If no filter matches → output passes through unchanged (zero cost)

## Guard

If the command already starts with `snip`, do **not** re-prefix.

```
✅  snip mvn clean test
❌  snip snip mvn clean test
```

## Execution Pattern

snip **buffers output** — the terminal shows nothing until the command finishes.

1. Launch with `isBackground=true`
2. Poll with `get_terminal_output(id)`
3. Empty output = still running → poll again
4. Output appears = done → read results

**NEVER** interpret empty output as failure.
**NEVER** fall back to the bare command because output was empty.
**NEVER** retry without snip.
