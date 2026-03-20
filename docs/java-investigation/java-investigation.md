# java-investigation — Full Pipeline (fd + javap + jar + rg)

> **Role**: Investigate Java library internals at bytecode level by combining file search, archive inspection, bytecode decompilation, and text filtering.
> **Pipeline**: `fd` (find JARs) → `jar tf` (list classes) → `javap -c` (decompile) → `rg` (filter calls).
> **Savings**: 93-95% of tokens vs reading source code on GitHub or Maven Central.

## Why This Synergy

Each tool alone covers one step. Combined, they create a complete investigation pipeline:

| Step | Tool | Question Answered |
|------|------|-------------------|
| 1 | `fd` | "Where is the JAR?" |
| 2 | `jar tf` | "Which class contains the code?" |
| 3 | `javap -c` | "What does the bytecode actually do?" |
| 4 | `rg` | "Does it call method X or method Y?" |

This is essential when documentation is unclear, misleading, or absent. Bytecode reveals ground truth — a method called `getResultStream()` might secretly call `getResultList()` and load everything in memory.

## Prerequisites

```bash
fd --version      # File finder
rg --version      # Ripgrep text search
javap -version    # JDK bytecode disassembler (included in any JDK)
jar --version     # JDK archive tool (included in any JDK)
```

See [javap.md](javap.md) for JDK installation. See the [token-saving-skills](../token-saving-skills/fd.md) docs for fd and rg installation.

## The Investigation Pipeline

```
fd (find JAR) → jar tf (list classes) → javap -c (decompile) → rg (filter calls)
```

Each step narrows the focus:
1. **fd**: Find the right JAR in Maven cache or project libs
2. **jar tf**: List classes to find the exact one you need
3. **javap -c**: Decompile to see actual bytecode instructions
4. **rg**: Filter the decompiled output to trace specific method calls

## Step-by-Step Usage

### Step 1: Locate JARs with fd

```bash
# Find a specific library version
fd "blaze-persistence-core-impl-jakarta-1.6.17.jar" ~/.m2

# Find all versions of a library
fd "hibernate-core" ~/.m2 -e jar

# Find JARs containing a keyword
fd "spring-security" ~/.m2 -e jar | head -10
```

```powershell
fd "hibernate-core" "$env:USERPROFILE\.m2" -e jar
```

### Step 2: Find Classes with jar + rg

```bash
# List all classes in a JAR, filter with rg
jar tf path/to/library.jar | rg "QuerySupport|ResultStream"

# Find implementation classes (not interfaces)
jar tf path/to/library.jar | rg "impl/" | rg -v "test|Test"

# Find all classes in a specific package
jar tf path/to/library.jar | rg "com/blazebit/persistence/impl/plan/"
```

### Step 3: Decompile and Filter with javap + rg

```bash
# Decompile a class and find what methods it calls
javap -c -classpath lib.jar com.pkg.ClassName | rg "invoke(virtual|interface|special|static)"

# Trace a specific method's behavior
javap -c -classpath lib.jar com.pkg.ClassName | rg -A 5 "getResultStream"

# Find if a method creates collections (= loads everything in memory)
javap -c -classpath lib.jar com.pkg.ClassName | rg "new.*ArrayList|new.*HashSet|getResultList"

# Find all field accesses
javap -c -p -classpath lib.jar com.pkg.ClassName | rg "getfield|putfield"
```

```powershell
javap -c -classpath lib.jar com.pkg.ClassName | Select-String "getResultStream|getResultList"
```

## Full Investigation (Real Example)

**Discovering the Blaze-Persistence fake streaming bug** — `getResultStream()` secretly calls `getResultList()`:

```bash
# 1. Find the integration JAR
fd "blaze-persistence-integration-hibernate6-base" ~/.m2 -e jar
# → ~/.m2/repository/com/blazebit/.../blaze-persistence-integration-hibernate6-base-1.6.17.jar

# 2. Find the class responsible for query execution
jar tf ~/.m2/.../blaze-persistence-integration-hibernate6-base-1.6.17.jar \
  | rg "ExtendedQuerySupport"
# → com/blazebit/persistence/integration/hibernate/base/HibernateExtendedQuerySupport.class

# 3. Check what getResultStream actually calls
javap -c -p -classpath ~/.m2/.../jar \
  com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport \
  | rg "getResultStream|getResultList|scroll"
# → REVEALS: getResultStream invokes getResultList (not scroll!)

# 4. Compare with standard Hibernate (the correct implementation)
fd "hibernate-core-6" ~/.m2 -e jar | head -1
javap -c -classpath ~/.m2/.../hibernate-core-6.2.2.Final.jar \
  org.hibernate.query.spi.AbstractSelectionQuery \
  | rg "getResultStream|scroll"
# → Hibernate uses scroll(FORWARD_ONLY) — true lazy streaming

# 5. Verify the call chain depth
javap -c -classpath ~/.m2/.../jar \
  com.blazebit.persistence.impl.query.CustomSQLTypedQuery \
  | rg -A 3 "getResultStream"
# → Confirms delegation: CustomSQLTypedQuery.getResultStream() → HibernateExtendedQuerySupport
```

**Result**: 5 commands, ~800 tokens. Reading source on GitHub would have been ~15,000 tokens across multiple repositories.

## Multi-JAR Dependency Tracing

When an implementation spans multiple JARs (common with frameworks):

```bash
# Find all JARs involved in a feature
fd "blaze-persistence" ~/.m2 -e jar | rg -v "source|javadoc"

# Trace a method across multiple JARs
for jar in $(fd "blaze-persistence" ~/.m2 -e jar | rg -v "source|javadoc"); do
    echo "=== $jar ==="
    jar tf "$jar" | rg "Stream|Result" | head -5
done

# Find which JAR actually contains the implementation
fd "blaze-persistence" ~/.m2 -e jar | while read jar; do
    jar tf "$jar" | rg -q "HibernateExtendedQuerySupport" && echo "FOUND IN: $jar"
done
```

```powershell
fd "blaze-persistence" "$env:USERPROFILE\.m2" -e jar |
  Where-Object { $_ -notmatch "source|javadoc" } |
  ForEach-Object {
    $classes = jar tf $_ | Select-String "Stream|Result"
    if ($classes) { Write-Host "=== $_ ==="; $classes }
  }
```

## Quick Diagnostic Patterns

| Question | Pipeline |
|----------|----------|
| Where is class X? | `fd "library" ~/.m2 -e jar` → `jar tf jar \| rg "ClassName"` |
| What does method X call? | `javap -c -classpath jar Class \| rg "invoke"` |
| Is streaming truly lazy? | `javap -c -classpath jar Class \| rg "scroll\|getResultList\|ArrayList"` |
| What's the delegation chain? | Repeat `javap -c` + `rg` across JARs until you reach the base impl |
| Does it use reflection? | `javap -c -classpath jar Class \| rg "java/lang/reflect"` |
| What SQL does it generate? | `javap -v -classpath jar Class \| rg "String.*SELECT\|String.*FROM"` |

## When to Use This Synergy

| Situation | Approach |
|-----------|----------|
| Library method behaves unexpectedly | Full pipeline: fd → jar → javap → rg |
| Need to understand an API surface | `javap` alone (no `-c` flag needed) — see [javap.md](javap.md) |
| Find which JAR has a class | `fd` + `jar tf` + `rg` |
| Verify a framework's documentation | `javap -c` + `rg` on the specific method |
| Debug a delegation chain (3+ classes) | Repeat javap + rg across JARs |
| Single method signature check | `javap` alone — see [javap.md](javap.md) |

## Comparison with Other Approaches

### Investigate "Does getResultStream() truly stream?"

| Approach | Steps | Tokens |
|----------|-------|--------|
| Read source on GitHub | Navigate repos, find files, read 5+ classes | ~15,000 |
| Guess from Javadoc | Read API docs, hope they're accurate | ~500 (unreliable) |
| **This pipeline** | 5 commands in terminal | **~800** |
| **Reduction** | | **-95%** |

### Find which JAR contains a class

| Approach | Steps | Tokens |
|----------|-------|--------|
| Search Maven Central website | Browse, download, inspect | ~5,000 |
| **fd + jar tf + rg** | 2 commands | **~200** |
| **Reduction** | | **-96%** |

← [Back to README](README.md)
