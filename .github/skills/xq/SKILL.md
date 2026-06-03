---
name: xq
description: "⚡ IMPORTANT: Auto-trigger for XML operations. Use when: extract Maven dependencies, check POM version, list artifacts, find Spring beans, audit XML configs. Surgical extraction 90-99% token savings. Essential for pom.xml, .csproj, app.config, web.xml files."
---

# XML manipulation with yq -p xml

## Core rule

**When you need to read, extract, filter or transform data from an XML file, use `yq -p xml` on the command line instead of reading the entire file.**

`yq` natively parses XML with the `-p xml` flag, using the same jq-like filter syntax as for YAML. No additional tool is needed — if yq is installed, XML support is included.

## Prerequisites: check/install yq

*IMPORTANT*: Same tool as YAML — check availability first:

```bash
yq --version
# Must show: yq (https://github.com/mikefarah/yq/) version v4.x
```

If `yq` is not installed:

| OS | Installation command |
|----|---------------------|
| **Windows (winget)** | `winget install MikeFarah.yq` |
| **Windows (manual)** | Download `yq_windows_amd64.exe` from https://github.com/mikefarah/yq/releases, rename to `yq.exe`, place in PATH |
| **Linux** | `sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq` |
| **macOS** | `brew install yq` |

> **Warning**: use **mikefarah/yq** (Go), NOT `kislyuk/yq` (Python). Only the Go version supports `-p xml`.

## Shell compatibility

`yq` works natively in both Bash and PowerShell. For filters containing `|` (pipe), use `cmd /c` in PowerShell:

```bash
# Bash — single quotes work
yq -p xml -oy '.project.version' pom.xml
yq -p xml -oy '.project.dependencies.dependency[] | select(.scope == "test")' pom.xml
```

```powershell
# PowerShell — simple filters work directly
yq -p xml -oy ".project.version" pom.xml

# Filters with | need cmd /c wrapping
cmd /c 'yq -p xml -oy ".project.dependencies.dependency[] | select(.scope == \"test\")" pom.xml'
```

## Usage patterns

### Extract a value from pom.xml

```bash
yq -p xml -oy '.project.version' pom.xml
# → 3.2.1

yq -p xml -oy '.project.groupId' pom.xml
# → com.axa.france

yq -p xml -oy '.project.artifactId' pom.xml
# → osmose-api
```

### Extract properties / configuration block

```bash
yq -p xml -oy '.project.properties' pom.xml
# → java.version: "17"
#   spring-boot.version: 3.2.0
#   maven.compiler.source: "17"
```

### List dependencies

```bash
yq -p xml -oy '.project.dependencies.dependency[].artifactId' pom.xml
# → spring-boot-starter-web
#   spring-boot-starter-data-jpa
#   postgresql
#   lombok
```

### Count elements

```bash
yq -p xml -oy '.project.dependencies.dependency | length' pom.xml
# → 5
```

### Filter with select

```bash
# Find test-scoped dependencies
yq -p xml -oy '.project.dependencies.dependency[] | select(.scope == "test") | .artifactId' pom.xml
# → spring-boot-starter-test
```

```powershell
cmd /c 'yq -p xml -oy ".project.dependencies.dependency[] | select(.scope == \"test\") | .artifactId" pom.xml'
```

### Extract from .csproj (C# projects)

```bash
yq -p xml -oy '.Project.PropertyGroup.TargetFramework' MyApp.csproj
yq -p xml -oy '.Project.ItemGroup.PackageReference[].+@Include' MyApp.csproj
```

### Extract from Spring / web.xml

```bash
yq -p xml -oy '.web-app.servlet[].servlet-name' web.xml
yq -p xml -oy '.beans.bean[].+@class' applicationContext.xml
```

### Access XML attributes

In yq, XML attributes are represented with `+@` prefix:

```bash
yq -p xml -oy '.project.dependencies.dependency[0].+@type' pom.xml
# For: <dependency type="jar">

yq -p xml -oy '.root.element.+@id' config.xml
# For: <element id="123">
```

### Modify XML in-place

```bash
yq -i -p xml -o xml '.project.version = "4.0.0"' pom.xml
yq -i -p xml -o xml '.project.properties.java-version = "21"' pom.xml
```

### Convert XML to JSON or YAML

```bash
# XML → JSON
yq -p xml -o json '.project.properties' pom.xml
# → {"java.version": "17", "spring-boot.version": "3.2.0", ...}

# XML → YAML
yq -p xml -o yaml pom.xml

# Full conversion to file
yq -p xml -o json pom.xml > pom.json
```

```powershell
yq -p xml -o json ".project.properties" pom.xml
```

## Common XML file types

| File | Typical content | Example extraction |
|------|----------------|-------------------|
| `pom.xml` | Maven project | `.project.version`, `.project.dependencies.dependency[]` |
| `*.csproj` | C# project | `.Project.PropertyGroup.TargetFramework` |
| `web.xml` | Servlet config | `.web-app.servlet[].servlet-name` |
| `*.config` | .NET config | `.configuration.appSettings.add[].+@value` |
| `persistence.xml` | JPA config | `.persistence.persistence-unit.properties.property[]` |
| `logback.xml` | Logging config | `.configuration.appender[].+@name` |

