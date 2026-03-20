---
name: java-investigation
description: >
  Synergy skill combining fd (JAR locator), javap/jar (bytecode tools), and rg (call filter) to investigate Java
  library internals at bytecode level. Use when tracing what methods actually do vs what documentation claims:
  debugging framework behavior (Hibernate query execution, Spring transactions, JPA streaming, Blaze-Persistence
  delegation), discovering misleading APIs (getResultStream() secretly calling getResultList(), eager vs lazy loading),
  finding memory leaks in "lazy" code, locating implementations across Maven JARs, analyzing multi-class delegation
  chains, verifying performance claims, understanding unexpected framework behavior. Trigger phrases: "trace this method",
  "why is this slow", "does it really stream", "find implementation", "debug [framework] internals", "verify this claim",
  "locate this class", "check lazy loading", "is it truly lazy". Pipeline: fd finds JARs → jar tf lists classes →
  javap -c decompiles bytecode → rg filters method calls. Essential when documentation is unclear, misleading, or absent.
  Saves 93-95% of tokens vs reading source code on GitHub or Maven Central. Reveals ground truth — bytecode never lies.
---

# Java investigation — fd + javap + rg

## Core rule

**When investigating Java library behavior, use `fd` to locate JARs, `jar tf` to find classes, `javap -c` to decompile bytecode, and `rg` to filter method calls. This pipeline reveals what code actually does — not what documentation claims.**

This synergy is critical when a library has misleading APIs (e.g. a `getResultStream()` that internally calls `getResultList()` and loads everything in memory).

## Prerequisites

All tools must be available:

```bash
fd --version      # File finder
rg --version      # Ripgrep text search
javap -version    # JDK bytecode disassembler (included in any JDK)
jar --version     # JDK archive tool (included in any JDK)
```

See individual `fd`, `rg`, and `javap` skills for installation instructions.

## The investigation pipeline

```
fd (find JAR) → jar tf (list classes) → javap -c (decompile) → rg (filter calls)
```

Each step narrows the focus:
1. **fd**: Find the right JAR in Maven cache or project libs
2. **jar tf**: List classes to find the exact one you need
3. **javap -c**: Decompile to see actual bytecode instructions
4. **rg**: Filter the decompiled output to trace specific method calls

## Usage patterns

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

### Step 2: Find classes with jar + rg

```bash
# List all classes in a JAR, filter with rg
jar tf path/to/library.jar | rg "QuerySupport|ResultStream"

# Find implementation classes (not interfaces)
jar tf path/to/library.jar | rg "impl/" | rg -v "test|Test"

# Find all classes in a specific package
jar tf path/to/library.jar | rg "com/blazebit/persistence/impl/plan/"
```

```powershell
jar tf path\to\library.jar | Select-String "QuerySupport"
```

### Step 3: Decompile and filter with javap + rg

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

### Full investigation (real example)

The Blaze-Persistence fake streaming investigation — discovering that `getResultStream()` secretly calls `getResultList()`:

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

### Multi-JAR dependency tracing

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
fd "blaze-persistence" "$env:USERPROFILE\.m2" -e jar | Where-Object { $_ -notmatch "source|javadoc" } | ForEach-Object {
    $classes = jar tf $_ | Select-String "Stream|Result"
    if ($classes) { Write-Host "=== $_ ==="; $classes }
}
```

### Quick diagnostic patterns

| Question | Pipeline |
|----------|----------|
| Where is class X? | `fd "library" ~/.m2 -e jar` → `jar tf jar \| rg "ClassName"` |
| What does method X call? | `javap -c -classpath jar Class \| rg "invoke"` |
| Is streaming truly lazy? | `javap -c -classpath jar Class \| rg "scroll\|getResultList\|ArrayList"` |
| What's the delegation chain? | Repeat `javap -c` + `rg` across JARs until you reach the base impl |
| Does it use reflection? | `javap -c -classpath jar Class \| rg "java/lang/reflect"` |
| What SQL does it generate? | `javap -v -classpath jar Class \| rg "String.*SELECT\|String.*FROM"` |

## When to use this synergy

| Situation | Approach |
|-----------|----------|
| Library method behaves unexpectedly | Full pipeline: fd → jar → javap → rg |
| Need to understand an API surface | `javap` alone (no `-c` flag needed) |
| Find which JAR has a class | `fd` + `jar tf` + `rg` |
| Verify a framework's documentation | `javap -c` + `rg` on the specific method |
| Debug a delegation chain (3+ classes) | Repeat javap+rg across JARs |

