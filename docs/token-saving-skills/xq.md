# xq — XML Extraction (yq -p xml)

> **Role**: Extract, filter, and transform XML data from the command line.
> **Replaces**: Full reads of `pom.xml`, `.csproj`, `web.xml`, etc.
> **Savings**: 90-99% of tokens — targeted XML field extraction.
> **Tool**: This is `yq` with the `-p xml` flag — no separate installation needed.

## Why xq for AI Agents

A Maven `pom.xml` with 50+ dependencies can reach 500+ lines (~3,000 tokens). If the agent needs the project version, it needs 1 line (~10 tokens). With `yq -p xml`, it gets it directly:

```bash
yq -p xml -oy '.project.version' pom.xml
# → 3.2.1
```

Same jq syntax as for YAML — one tool to learn for YAML, TOML, JSON, and XML.

## Prerequisites

`xq` = `yq` with `-p xml`. If `yq` is installed (see [yq.md](yq.md)), `xq` is available.

```bash
yq --version
# Must show: yq (https://github.com/mikefarah/yq/) version v4.x
```

> **Warning**: only **mikefarah/yq** (Go) supports `-p xml`. The Python version (`kislyuk/yq`) does not work.

## Basic Syntax

```
yq -p xml -oy 'expression' file.xml
```

- `-p xml` — parses the file as XML
- `-oy` — YAML output (readable), `-o json` for JSON
- The expression uses standard jq syntax

## Use Cases: Maven (pom.xml)

### Extract version

```bash
yq -p xml -oy '.project.version' pom.xml
# → 3.2.1
```

### Extract project coordinates

```bash
yq -p xml -oy '.project.groupId' pom.xml
# → com.axa.france

yq -p xml -oy '.project.artifactId' pom.xml
# → osmose-api
```

### List dependencies

```bash
yq -p xml -oy '.project.dependencies.dependency[].artifactId' pom.xml
# → spring-boot-starter-web
# → spring-boot-starter-data-jpa
# → postgresql
# → lombok
```

### Count dependencies

```bash
yq -p xml -oy '.project.dependencies.dependency | length' pom.xml
# → 5
```

### Filter test dependencies

```bash
yq -p xml -oy '.project.dependencies.dependency[] | select(.scope == "test") | .artifactId' pom.xml
# → spring-boot-starter-test
```

### Extract properties

```bash
yq -p xml -oy '.project.properties' pom.xml
# → java.version: "17"
# → spring-boot.version: 3.2.0
# → maven.compiler.source: "17"
```

## Use Cases: .NET (.csproj)

```bash
yq -p xml -oy '.Project.PropertyGroup.TargetFramework' MyApp.csproj
# → net8.0

yq -p xml -oy '.Project.ItemGroup.PackageReference[].+@Include' MyApp.csproj
# → Microsoft.AspNetCore.App
# → Newtonsoft.Json
```

## Use Cases: Java Configuration

### web.xml

```bash
yq -p xml -oy '.web-app.servlet[].servlet-name' web.xml
```

### Spring (applicationContext.xml)

```bash
yq -p xml -oy '.beans.bean[].+@class' applicationContext.xml
```

### Logback

```bash
yq -p xml -oy '.configuration.appender[].+@name' logback.xml
```

## Accessing XML Attributes

In yq, XML attributes are represented with the `+@` prefix:

```xml
<dependency type="jar">...</dependency>
<element id="123">...</element>
```

```bash
yq -p xml -oy '.project.dependencies.dependency[0].+@type' pom.xml
# → jar

yq -p xml -oy '.root.element.+@id' config.xml
# → 123
```

## In-Place Modification

```bash
yq -i -p xml -o xml '.project.version = "4.0.0"' pom.xml
yq -i -p xml -o xml '.project.properties.java-version = "21"' pom.xml
```

## Format Conversion

```bash
# XML → JSON
yq -p xml -o json '.project.properties' pom.xml

# XML → YAML
yq -p xml -o yaml pom.xml

# Full conversion to file
yq -p xml -o json pom.xml > pom.json
```

## Batch Processing

Combined with `fd`, batch extraction from all `pom.xml` in a multi-module project:

```bash
# Version of each module
fd -g "pom.xml" . -x yq -p xml -oy '.project.version' {}

# ArtifactId + version
fd -g "pom.xml" . -x sh -c '
  aid=$(yq -p xml -oy ".project.artifactId" "$1")
  ver=$(yq -p xml -oy ".project.version" "$1")
  echo "$aid → $ver"
' _ {}

# Find pom.xml files using Spring Boot
fd -g "pom.xml" . -x sh -c '
  deps=$(yq -p xml -oy ".project.dependencies.dependency[].artifactId" "$1" 2>/dev/null)
  echo "$deps" | grep -q "spring-boot" && echo "$1"
' _ {}
```

> See [batch-config-audit](batch-config-audit.md) for more patterns.

## Shell Compatibility

```bash
# Bash — single quotes
yq -p xml -oy '.project.version' pom.xml
```

```powershell
# PowerShell — double quotes for simple filters
yq -p xml -oy ".project.version" pom.xml

# Filters with | → wrap in cmd /c
cmd /c 'yq -p xml -oy ".project.dependencies.dependency[] | select(.scope == \"test\")" pom.xml'
```

## Common XML File Types Reference

| File | Typical Content | Example Extraction |
|------|----------------|-------------------|
| `pom.xml` | Maven project | `.project.version`, `.project.dependencies.dependency[]` |
| `*.csproj` | C# project | `.Project.PropertyGroup.TargetFramework` |
| `web.xml` | Servlet config | `.web-app.servlet[].servlet-name` |
| `*.config` | .NET config | `.configuration.appSettings.add[].+@value` |
| `persistence.xml` | JPA config | `.persistence.persistence-unit.properties.property[]` |
| `logback.xml` | Logging config | `.configuration.appender[].+@name` |

## Most Useful Options

| Option | Effect |
|--------|--------|
| `-p xml` | XML input parser |
| `-oy` | YAML output |
| `-o json` | JSON output |
| `-o xml` | XML output (for modification) |
| `-i` | In-place modification |
| `+@attribute` | Access XML attributes |

← [Back to README](README.md)
