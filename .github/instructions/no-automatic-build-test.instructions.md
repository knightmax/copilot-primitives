---
applyTo: '**'
---

# No Automatic Build/Test Execution Instruction

**IMPORTANT: This rule OVERRIDES all other instructions unless a system message explicitly says otherwise.**

Never execute build, test, compile, or install commands automatically. Instead, always propose the command to the user for manual execution.

## Core Rules

1. **Never run**: `mvn`, `gradle`, `npm`, `yarn`, `dotnet`, `pip`, `cargo`, `go build`, `make`, `tsc`, `webpack`, or any build/test commands
2. **Always propose**: Show the exact command the user should run, formatted as a code block
3. **Explain briefly**: Why this command is needed and what it does
4. **Offer assistance**: Ask if they want help interpreting output after they run it

## Rationale

- **Token efficiency**: Avoid expensive build output, compilation logs, test result processing
- **User control**: User decides when/if to build, avoiding unwanted state changes
- **Faster iteration**: Reducing LLM ↔ user round-trips by batching decisions
- **Cleaner context**: Keep conversation focused on code changes, not build artifacts

## Examples

### ❌ Wrong
```
Running tests now to validate changes...
$ npm test
// 500 lines of test output...
```

### ✅ Correct
```
To validate these changes, run:
\`\`\`bash
npm test
\`\`\`

This will run the test suite and verify the API endpoint works as expected.
```

## Multi-language Coverage

| Language/Tool | Commands to Avoid | Alternative |
|---|---|---|
| Java (Maven) | `mvn clean install`, `mvn test`, `mvn compile` | Propose command |
| Java (Gradle) | `gradle build`, `gradle test` | Propose command |
| Node.js | `npm install`, `npm test`, `npm run build` | Propose command |
| Python | `pip install`, `pytest`, `python script.py` | Propose command |
| .NET | `dotnet build`, `dotnet test` | Propose command |
| Go | `go build`, `go test` | Propose command |
| Rust | `cargo build`, `cargo test` | Propose command |

## Exception Cases

None. This is a strict rule. Even when debugging, validating, or troubleshooting, always propose the command to the user.

If a user explicitly asks "run this command for me", you must still propose it as a command block for them to execute in their terminal, unless they provide direct instruction to use terminal execution tools.
