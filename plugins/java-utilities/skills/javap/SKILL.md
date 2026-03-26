---
name: javap
description: >
  Use javap, jar, and jdeps (all JDK built-in tools) to analyze Java bytecode, inspect library internals without
  source code, and trace actual method behavior. Load this skill when debugging framework behavior (Hibernate, Spring,
  JPA, Blaze-Persistence), verifying library claims ("does this really stream or does it load everything?"), tracing
  delegation chains across JARs, finding where methods are actually implemented, locating classes in Maven cache,
  discovering misleading APIs (methods that internally do the opposite of their name), analyzing dependencies, checking
  for memory leaks (ArrayList instantiation in "streaming" code), or understanding why a library behaves unexpectedly.
  Use even when the user doesn't say "javap" — phrases like "trace what this method does", "find this class in Maven",
  "why is this slow", "does it really stream", "verify the implementation", "debug Hibernate internals", "check the
  delegation chain" all trigger this skill. Critical when documentation is unclear, misleading, or absent. Bytecode
  reveals truth — getResultStream() might secretly call getResultList(). Saves 87-95% of tokens vs reading source
  on GitHub or guessing from Javadoc. All three tools (javap, jar, jdeps) included in any JDK — no installation needed.
---

# Java bytecode analysis with javap, jar, jdeps

## Core rule

**When you need to understand what a Java library method actually does — not what Javadoc claims — use `javap -c` to decompile bytecode instead of guessing. Bytecode reveals the ground truth: misleading APIs (e.g., `getResultStream()` secretly calling `getResultList()`), hidden implementations, framework magic (proxies, decorators), and outdated docs.**

## Prerequisites

All three tools are **included in any JDK** (no installation needed):

```bash
javap -version   # Bytecode disassembler
jar --version    # JAR archive tool
jdeps --version  # Dependency analyzer
```

If none are available, install a JDK:

| OS | Installation command |
|----|---------------------|
| **Windows (winget)** | `winget install EclipseAdoptium.Temurin.25.JDK` |
| **Linux (apt)** | `sudo apt-get install -y openjdk-25-jdk` |
| **macOS** | `brew install openjdk@25` |

## The three tools

| Tool | Purpose | Key flags |
|------|---------|-----------|
| **`jar`** | List/extract contents of a JAR | `jar tf file.jar` |
| **`javap`** | Disassemble class files → signatures or bytecode | `-p` (private), `-c` (bytecode), `-v` (verbose) |
| **`jdeps`** | Analyze class/module dependencies | `--class-path`, `-verbose:class` |

## Usage patterns

### Locate a class in Maven cache

Find the JAR in your local Maven cache:

```bash
find ~/.m2 -name "blaze-persistence-core-impl-jakarta-1.6.17.jar" 2>/dev/null
# → ~/.m2/repository/com/blazebit/blaze-persistence-core-impl-jakarta/1.6.17/...

# Or find by partial name
find ~/.m2 -name "hibernate-core*.jar" 2>/dev/null | head -5
```

```powershell
Get-ChildItem -Path "$env:USERPROFILE\.m2" -Recurse -Filter "blaze-persistence-core-impl-jakarta-1.6.17.jar"
```

### List classes in a JAR

```bash
jar tf path/to/library.jar | grep ClassName
jar tf path/to/library.jar | grep "com/blazebit/persistence/impl/plan/"
```

```powershell
jar tf path\to\library.jar | Select-String "ClassName"
```

### View method signatures (no bytecode)

```bash
javap -classpath path/to/library.jar com.package.ClassName
```

Shows public method signatures — useful to understand the API surface:

```
public class com.blazebit.persistence.impl.query.CustomSQLTypedQuery<X> {
  public java.util.List<X> getResultList();
  public java.util.stream.Stream<X> getResultStream();
  public X getSingleResult();
  ...
}
```

### View private members too

```bash
javap -p -classpath path/to/library.jar com.package.ClassName
```

The `-p` flag reveals private methods and fields — essential for understanding internal delegation.

### Decompile bytecode (the power move)

```bash
javap -c -classpath path/to/library.jar com.package.ClassName
```

This shows JVM instructions. Key opcodes to look for:

| Opcode | Meaning |
|--------|---------|
| `invokevirtual` | Call a method on an object |
| `invokeinterface` | Call an interface method |
| `invokespecial` | Call constructor, super, or private method |
| `invokestatic` | Call a static method |
| `new` | Object instantiation (look for `ArrayList`, `HashSet`) |
| `getfield` | Access an instance field |
| `ldc` / `ldc_w` | Load a constant (string, class reference) |

### Trace a specific method call chain

Pipe `javap -c` through `grep` / `Select-String` to filter relevant calls:

```bash
# Find what getResultStream() actually calls
javap -c -classpath lib.jar com.pkg.Class | grep -E "getResultStream|getResultList|scroll"

# Find all method invocations in a class
javap -c -classpath lib.jar com.pkg.Class | grep -E "invoke(virtual|interface|special|static)"

# Find object instantiations (ArrayList = probably loading everything)
javap -c -classpath lib.jar com.pkg.Class | grep -E "new #|// class java/util"
```

```powershell
javap -c -classpath lib.jar com.pkg.Class | Select-String "getResultStream|getResultList"
```

### Analyze a specific method only

```bash
# javap outputs all methods — pipe through grep to isolate one
javap -c -classpath lib.jar com.pkg.Class | grep -A 30 "public.*getResultStream"
```

### Analyze dependencies with jdeps

```bash
# What does this class depend on?
jdeps --class-path path/to/library.jar -verbose:class -filter:none \
  com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport

# Module-level dependency summary
jdeps -s path/to/library.jar

# Recursive dependency analysis
jdeps -R --class-path "lib1.jar:lib2.jar" path/to/main.jar
```

```powershell
# PowerShell — use semicolon for classpath on Windows
jdeps --class-path "lib1.jar;lib2.jar" -verbose:class path\to\library.jar
```

### Full investigation workflow (real example)

**Example: Discover the Blaze-Persistence fake streaming bug**

- Input: Blaze-Persistence library in Maven cache (need to verify if `getResultStream()` truly streams)
- Task: Trace what `getResultStream()` actually calls in bytecode
- Output: Discovery that it calls `getResultList()` internally (loads everything in memory)
- Token saving: **-95%** vs reading source code on GitHub (~15k tokens → ~800 tokens for full investigation)

This is the actual workflow used to discover the Blaze-Persistence fake streaming bug:

```bash
# Step 1: Locate the JAR
find ~/.m2 -name "blaze-persistence-integration-hibernate6-base-1.6.17.jar" 2>/dev/null

# Step 2: Find the suspect class
jar tf ~/.m2/.../blaze-persistence-integration-hibernate6-base-1.6.17.jar \
  | grep ExtendedQuerySupport

# Step 3: Check public API
javap -classpath ~/.m2/.../jar com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport

# Step 4: Decompile and trace the call chain
javap -c -p -classpath ~/.m2/.../jar \
  com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport \
  | grep -A5 "getResultStream"
# ✅ DISCOVERY: getResultStream() calls getResultList() internally (not a real stream!)

# Step 5: Compare with the standard Hibernate implementation
javap -c -classpath ~/.m2/.../hibernate-core-6.2.2.Final.jar \
  org.hibernate.query.spi.AbstractSelectionQuery \
  | grep -A5 "getResultStream"
# ✅ PROOF: Hibernate uses scroll(FORWARD_ONLY) — true lazy streaming
```

**Result**: Bytecode revealed the truth in ~10 commands. Reading source code on GitHub would have taken hundreds of file reads across multiple repositories.

### Extract constant pool (string literals, class refs)

```bash
javap -v -classpath lib.jar com.pkg.Class | grep -E "String|Class|Methodref" | head -20
```

Useful to find hardcoded SQL, configuration keys, or error messages in compiled code.

## Common investigation patterns

| Question | Command |
|----------|---------|
| Does method X call method Y? | `javap -c -classpath jar Class \| grep "methodY"` |
| Does this class create an ArrayList? | `javap -c -classpath jar Class \| grep "java/util/ArrayList"` |
| What interfaces does it implement? | `javap -classpath jar Class \| head -5` |
| What fields does it have? | `javap -p -classpath jar Class \| grep -E "field\|Field"` |
| Is there a real DB cursor? | `javap -c -classpath jar Class \| grep -E "scroll\|Scrollable\|cursor"` |
| What exceptions can it throw? | `javap -classpath jar Class` (shown in signatures) |
