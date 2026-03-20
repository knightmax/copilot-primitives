# javap — Java Bytecode Analysis

> **Role**: Decompile Java bytecode, inspect library internals without source code, and trace actual method behavior.
> **Tools**: `javap` (disassembler), `jar` (archive tool), `jdeps` (dependency analyzer) — all included in any JDK.
> **Savings**: 87-95% of tokens vs reading source on GitHub or guessing from Javadoc.

## Why javap for AI Agents

When an agent needs to understand what a Java library method does, it has three options:

| Approach | Tokens | Accuracy |
|----------|--------|----------|
| Read source on GitHub (multiple files) | ~15,000 | Medium (version mismatch risk) |
| Trust Javadoc / method name | ~50 | **Low** (names can be misleading) |
| **Decompile with javap** | **~800** | **High** (bytecode = ground truth) |

A method called `getResultStream()` might secretly call `getResultList()` and load everything in memory. **Bytecode never lies.**

## Prerequisites

All three tools are **included in any JDK** — no installation needed:

```bash
javap -version   # Bytecode disassembler
jar --version    # JAR archive tool
jdeps --version  # Dependency analyzer
```

If none are available, install a JDK:

| OS | Command |
|----|---------|
| **macOS** | `brew install openjdk@25` |
| **Linux (apt)** | `sudo apt-get install -y openjdk-25-jdk` |
| **Windows (winget)** | `winget install EclipseAdoptium.Temurin.25.JDK` |

## The Three Tools

| Tool | Purpose | Key Flags |
|------|---------|-----------|
| **`jar`** | List/extract contents of a JAR | `jar tf file.jar` |
| **`javap`** | Disassemble class files → signatures or bytecode | `-p` (private), `-c` (bytecode), `-v` (verbose) |
| **`jdeps`** | Analyze class/module dependencies | `--class-path`, `-verbose:class` |

## Use Cases

### Locate a Class in Maven Cache

```bash
find ~/.m2 -name "hibernate-core*.jar" 2>/dev/null | head -5

# Or by partial name
find ~/.m2 -name "blaze-persistence-core-impl-jakarta-1.6.17.jar" 2>/dev/null
```

```powershell
Get-ChildItem -Path "$env:USERPROFILE\.m2" -Recurse -Filter "hibernate-core*.jar"
```

### List Classes in a JAR

```bash
jar tf path/to/library.jar | grep ClassName
jar tf path/to/library.jar | grep "com/blazebit/persistence/impl/plan/"
```

### View Method Signatures (No Bytecode)

```bash
javap -classpath path/to/library.jar com.package.ClassName
```

Output shows the public API surface:

```
public class com.blazebit.persistence.impl.query.CustomSQLTypedQuery<X> {
  public java.util.List<X> getResultList();
  public java.util.stream.Stream<X> getResultStream();
  public X getSingleResult();
  ...
}
```

### View Private Members Too

```bash
javap -p -classpath path/to/library.jar com.package.ClassName
```

The `-p` flag reveals private methods and fields — essential for understanding internal delegation.

### Decompile Bytecode (The Power Move)

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

### Trace a Specific Method Call Chain

Pipe `javap -c` through `grep` to filter relevant calls:

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

### Analyze a Specific Method Only

```bash
# javap outputs all methods — pipe through grep to isolate one
javap -c -classpath lib.jar com.pkg.Class | grep -A 30 "public.*getResultStream"
```

### Analyze Dependencies with jdeps

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

### Extract Constant Pool (String Literals, Class Refs)

```bash
javap -v -classpath lib.jar com.pkg.Class | grep -E "String|Class|Methodref" | head -20
```

Useful to find hardcoded SQL, configuration keys, or error messages in compiled code.

## Full Investigation Workflow (Real Example)

**Discovering the Blaze-Persistence fake streaming bug:**

```bash
# Step 1: Locate the JAR
find ~/.m2 -name "blaze-persistence-integration-hibernate6-base-1.6.17.jar" 2>/dev/null

# Step 2: Find the suspect class
jar tf ~/.m2/.../jar | grep ExtendedQuerySupport

# Step 3: Check public API
javap -classpath ~/.m2/.../jar \
  com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport

# Step 4: Decompile and trace the call chain
javap -c -p -classpath ~/.m2/.../jar \
  com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport \
  | grep -A5 "getResultStream"
# DISCOVERY: getResultStream() calls getResultList() internally!

# Step 5: Compare with Hibernate's correct implementation
javap -c -classpath ~/.m2/.../hibernate-core-6.2.2.Final.jar \
  org.hibernate.query.spi.AbstractSelectionQuery \
  | grep -A5 "getResultStream"
# PROOF: Hibernate uses scroll(FORWARD_ONLY) — true lazy streaming
```

**Result**: Bytecode revealed the truth in ~10 commands. Reading source on GitHub would have required hundreds of file reads across multiple repositories.

## Common Investigation Patterns

| Question | Command |
|----------|---------|
| Does method X call method Y? | `javap -c -classpath jar Class \| grep "methodY"` |
| Does this class create an ArrayList? | `javap -c -classpath jar Class \| grep "java/util/ArrayList"` |
| What interfaces does it implement? | `javap -classpath jar Class \| head -5` |
| What fields does it have? | `javap -p -classpath jar Class \| grep -E "field\|Field"` |
| Is there a real DB cursor? | `javap -c -classpath jar Class \| grep -E "scroll\|Scrollable\|cursor"` |
| What exceptions can it throw? | `javap -classpath jar Class` (shown in signatures) |

## Shell Compatibility

```bash
# Bash — standard pipes
javap -c -classpath lib.jar com.pkg.Class | grep "getResultStream"
```

```powershell
# PowerShell — Select-String instead of grep
javap -c -classpath lib.jar com.pkg.Class | Select-String "getResultStream"

# Classpath separator is ; on Windows
javap -c -classpath "lib1.jar;lib2.jar" com.pkg.Class
```

## Combinations with Other Tools

| Combination | Usage | See |
|-------------|-------|-----|
| `fd` + `jar` + `javap` + `rg` | Full investigation pipeline | [java-investigation](java-investigation.md) |
| `javap -c` + `grep` | Trace specific method calls | This document |
| `jdeps -R` | Recursive dependency analysis | This document |

← [Back to README](README.md)
