# Snip Plugin

## Installation

### 1. Install snip CLI (if not installed)

**macOS:**
```bash
brew install snip
```

**Windows (PowerShell):**
```powershell
scoop install snip
```

**Other platforms:** See [snip releases](https://github.com/edouard-claude/snip/releases)

### 2. Install Filters

In chat, trigger the **snip-install** skill:

**macOS/Linux:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/snip-install/scripts/install.sh"
```

**Windows (PowerShell):**
```powershell
& "${env:CLAUDE_PLUGIN_ROOT}\skills\snip-install\scripts\install.ps1"
```

## Verify Plugin is Active

### In VS Code Extensions

1. Open Extensions view (`Ctrl+Shift+X`)
2. Search for **"Agent Plugins - Installed"** or use `@agentPlugins @installed`
3. You should see **"snip"** listed with status **enabled**

### In Chat Customizations

1. Open Chat Customizations (`Cmd+Shift+P` → "Chat: Open Customizations")
2. Go to **"Plugins"** tab
3. Verify **snip** has toggle **ON** (enabled)

### Verify Skills Are Available

In chat, run:
```
/help skills
```

You should see:
- ✅ **snip-auto** — Universal Command Proxy
- ✅ **snip-install** — CLI + All Filters

### Verify Filters Installed

Check that filters were installed correctly:

**Linux/macOS:**
```bash
ls ~/.config/snip/filters/
```

**Windows:**
```powershell
Get-ChildItem $env:APPDATA\snip\filters\
```

View token savings:
```bash
snip gain --daily
```
