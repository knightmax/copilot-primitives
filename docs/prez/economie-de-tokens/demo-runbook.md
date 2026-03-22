# Runbook — Démo Live "Économie de Contexte CLI"

> **Durée totale** : 30 min (25 min démo + 5 min Q&A)
> **Projet** : `demo/token-economy-demo/` (Spring Boot multi-module)
> **Prérequis** : `fd`, `rg`, `yq`, `jq` installés + Java 17 + Maven

---

## Setup avant la démo

```bash
# macOS
brew install fd ripgrep yq jq

# Windows (PowerShell admin)
winget install sharkdp.fd BurntSushi.ripgrep.MSVC MikeFarah.yq jqlang.jq
```

Se placer à la racine du projet :
```bash
cd demo/token-economy-demo
```

### Fonction `compare` — Comparaison automatique via l'historique

Le workflow : lancer la commande naïve, puis la commande skill, puis appeler `compare`.
La fonction rejoue les 2 dernières commandes de l'historique et affiche le gain.

```bash
# macOS / zsh — coller une seule fois dans le terminal
compare() {
  local cmd1=$(fc -ln -2 -2 | sed 's/^[[:space:]]*//')
  local cmd2=$(fc -ln -1 -1 | sed 's/^[[:space:]]*//')
  local out1=$(zsh -c "cd '$PWD' && $cmd1" 2>&1)
  local out2=$(zsh -c "cd '$PWD' && $cmd2" 2>&1)
  local c1=$(printf '%s' "$out1" | wc -c | tr -d ' ')
  local c2=$(printf '%s' "$out2" | wc -c | tr -d ' ')
  local t1=$((c1 / 4)); local t2=$((c2 / 4))
  local pct=0; if [ $t1 -gt 0 ]; then pct=$(( (t1 - t2) * 100 / t1 )); fi
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 Naïve :  $cmd1"
  echo "   → ≈ $t1 tokens ($c1 chars)"
  echo ""
  echo "⚡ Skill :  $cmd2"
  echo "   → ≈ $t2 tokens ($c2 chars)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Gain : -${pct}% ($t1 → $t2 tokens)"
}
```

```powershell
# Windows PowerShell — coller une seule fois
function compare {
    $h = Get-History
    $cmd1 = $h[-2].CommandLine
    $cmd2 = $h[-1].CommandLine
    $out1 = (Invoke-Expression $cmd1 | Out-String)
    $out2 = (Invoke-Expression $cmd2 | Out-String)
    $c1 = [System.Text.Encoding]::UTF8.GetByteCount($out1)
    $c2 = [System.Text.Encoding]::UTF8.GetByteCount($out2)
    $t1 = [math]::Floor($c1 / 4)
    $t2 = [math]::Floor($c2 / 4)
    $pct = if ($t1 -gt 0) { [math]::Floor(($t1 - $t2) * 100 / $t1) } else { 0 }
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "📋 Naïve :  $cmd1"
    Write-Host "   → ≈ $t1 tokens ($c1 chars)"
    Write-Host ""
    Write-Host "⚡ Skill :  $cmd2"
    Write-Host "   → ≈ $t2 tokens ($c2 chars)"
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    Write-Host "📊 Gain : -${pct}% ($t1 → $t2 tokens)"
}
```

**Usage** (même workflow sur les deux OS) :
```
1. cat fichier.json              ← commande naïve
2. jq '.[0].type' fichier.json   ← commande skill
3. compare                       ← affiche le gain
```

> **ℹ️ Comment sont comptés les tokens ?**
> Notre fonction utilise l'approximation `1 token ≈ 4 caractères`.
> En réalité, chaque provider a son propre tokenizer :
> - **OpenAI** — [tiktoken](https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them) (BPE, ~4 chars/token en anglais, variable selon la langue)
> - **Anthropic** — [tokenizer propriétaire](https://platform.claude.com/docs/en/build-with-claude/token-counting) (comptage via API)
>
> L'approximation `÷ 4` est suffisante pour comparer les **gains relatifs** entre commandes — c'est le ratio qui compte, pas la valeur absolue.

---

## Démo 0 — Introduction (3 min)

**Message clé** : Un agent IA a une fenêtre de contexte limitée. Chaque `cat`, chaque `find` avec chemins absolus, chaque lecture de fichier entier gaspille des tokens. Résultat : l'agent oublie, hallucine, ou produit des réponses dégradées.

**Le projet de démo** : Un Spring Boot multi-module réaliste.
```
token-economy-demo/
├── pom.xml                    # Parent POM
├── core/pom.xml               # Domain (0 deps framework)
├── infrastructure/pom.xml     # JPA adapters
├── api/pom.xml                # REST controllers
├── app/pom.xml                # Spring Boot app
├── 22 fichiers Java           # Models, services, ports, adapters, controllers, tests
├── 4 fichiers YAML            # application.yml, -dev, -prod, -staging
├── 4 fichiers JSON mock       # users (65KB), products (60KB), orders (215KB), events (345KB)
└── docker-compose.yml
```

**Taille totale des données** : ~696 KB soit **~174 000 tokens** si tout est lu naïvement.

---

## Démo 1 — fd : Trouver les fichiers (4 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent utiliserait find avec chemins absolus
find . -name "*.java" -type f
```

#### Windows (PowerShell)
```powershell
# L'agent utiliserait Get-ChildItem -Recurse
Get-ChildItem -Recurse -Filter "*.java" | Select-Object FullName
```

**Output** : 22 fichiers avec chemins absolus/relatifs longs.
- `find` output : **1 373 chars ≈ 343 tokens**
- `Get-ChildItem` avec FullName : **~2 500 chars ≈ 625 tokens** (chemins absolus Windows)

### AVEC skill — Extraction chirurgicale

#### macOS (zsh)
```bash
# fd : chemins relatifs, court, respecte .gitignore
fd -e java .
```

#### Windows (PowerShell)
```powershell
fd -e java .
```

**Output** : 22 fichiers, chemins relatifs courts.
- `fd` output : **~800 chars ≈ 200 tokens**

### 📊 Gain : ~50% (343 → 200 tokens)

**Bonus — autres variantes fd :**
```bash
fd -e yml .                    # Trouver tous les YAML
fd -e json . --max-depth 5     # Trouver les JSON (limiter la profondeur)
fd -g "pom.xml" .              # Trouver tous les pom.xml
fd -e java . | wc -l           # Compter les fichiers Java → 22
```

---

## Démo 2 — rg : Chercher dans le contenu (4 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent lirait le fichier entier pour chercher une info
cat app/src/main/resources/mocks/events.json
```

#### Windows (PowerShell)
```powershell
Get-Content app\src\main\resources\mocks\events.json
```

**Output** : 11 223 lignes, 344 970 chars.
- **≈ 86 243 tokens** chargés dans le contexte pour chercher quelques infos !

### AVEC skill — Extraction chirurgicale

#### macOS (zsh)
```bash
# rg : chercher "ORDER_CREATED" dans events.json
rg "ORDER_CREATED" app/src/main/resources/mocks/events.json
```

#### Windows (PowerShell)
```powershell
rg "ORDER_CREATED" app\src\main\resources\mocks\events.json
```

**Output** : Seulement les lignes contenant "ORDER_CREATED" (environ 60-80 lignes).
- **≈ 500 tokens** (seules les lignes pertinentes)

### 📊 Gain : ~99% (86 243 → 500 tokens)

**Bonus — variantes rg :**
```bash
rg -c "ORDER_CREATED" app/src/main/resources/mocks/events.json   # Compter: ~60 occurrences
rg -l "userId" app/src/main/resources/mocks/                      # Lister les fichiers contenant "userId"
rg "@RestController" -t java .                                    # Trouver les controllers
rg "spring" app/src/main/resources/ --no-heading                  # Chercher dans les configs
```

---

## Démo 3 — yq : Extraire du YAML (4 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent lirait tout le fichier YAML
cat app/src/main/resources/application.yml
```

#### Windows (PowerShell)
```powershell
Get-Content app\src\main\resources\application.yml
```

**Output** : 44 lignes, 868 chars.
- **≈ 217 tokens**

### AVEC skill — Extraction chirurgicale

#### macOS (zsh)
```bash
# yq : extraire uniquement le datasource URL
yq '.spring.datasource.url' app/src/main/resources/application.yml
```

#### Windows (PowerShell)
```powershell
yq ".spring.datasource.url" app\src\main\resources\application.yml
```

**Output** : `jdbc:h2:mem:demodb`
- **≈ 5 tokens**

### 📊 Gain : ~97% (217 → 5 tokens)

**Bonus — combo des 4 YAML :**
```bash
# Comparer les datasource.url à travers tous les profils
yq '.spring.datasource.url' app/src/main/resources/application.yml
yq '.spring.datasource.url' app/src/main/resources/application-dev.yml
yq '.spring.datasource.url' app/src/main/resources/application-prod.yml
yq '.spring.datasource.url' app/src/main/resources/application-staging.yml
```
Total : **~20 tokens** au lieu de lire 4 fichiers complets (~800 tokens).

---

## Démo 4 — xq (yq -p xml) : Extraire du XML (4 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent lirait le pom.xml entier
cat pom.xml
```

#### Windows (PowerShell)
```powershell
Get-Content pom.xml
```

**Output** : 67 lignes, 2 478 chars.
- **≈ 620 tokens**

### AVEC skill — Extraction chirurgicale

#### macOS (zsh)
```bash
# Extraire la version du projet
yq -p xml -oy '.project.version' pom.xml

# Lister les modules
yq -p xml -oy '.project.modules.module[]' pom.xml

# Voir la version de Spring Boot parent
yq -p xml -oy '.project.parent.version' pom.xml
```

#### Windows (PowerShell)
```powershell
yq -p xml -oy ".project.version" pom.xml
yq -p xml -oy ".project.modules.module[]" pom.xml
yq -p xml -oy ".project.parent.version" pom.xml
```

**Output** : 
```
1.0.0-SNAPSHOT
core
infrastructure
api
app
3.2.5
```
- **≈ 15 tokens**

### 📊 Gain : ~97% (620 → 15 tokens)

**Bonus — dépendances d'un module :**
```bash
# Lister les dépendances du module infrastructure
yq -p xml -oy '.project.dependencies.dependency[].artifactId' infrastructure/pom.xml
```
Output : `core`, `spring-boot-starter-data-jpa`, `h2`, `postgresql` → **~10 tokens**

---

## Démo 5 — jq : Extraire du JSON (4 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent lirait le fichier JSON entier
cat app/src/main/resources/mocks/events.json
```

#### Windows (PowerShell)
```powershell
Get-Content app\src\main\resources\mocks\events.json
```

**Output** : 11 223 lignes, 344 970 chars.
- **≈ 86 243 tokens**

### AVEC skill — Extraction chirurgicale

#### macOS (zsh)
```bash
# Extraire le type du premier événement
jq '.[0].type' app/src/main/resources/mocks/events.json

# Compter les événements par type
jq 'group_by(.type) | map({type: .[0].type, count: length})' app/src/main/resources/mocks/events.json

# Extraire les ordres créés avec montants
jq '[.[] | select(.type == "ORDER_CREATED") | {userId, orderId: .metadata.orderId, total: .metadata.totalAmount}] | length' app/src/main/resources/mocks/events.json
```

#### Windows (PowerShell)
```powershell
cmd /c 'jq ".[0].type" app\src\main\resources\mocks\events.json'
cmd /c 'jq "group_by(.type) | map({type: .[0].type, count: length})" app\src\main\resources\mocks\events.json'
```

**Output 1er jq** : `"USER_LOGIN"` → **1 token**
**Output group_by** : 8 lignes avec les comptages → **~40 tokens**

### 📊 Gain : ~99.9% (86 243 → 1-40 tokens)

**Bonus — extractions chirurgicales :**
```bash
# Combien d'événements ?
jq 'length' app/src/main/resources/mocks/events.json       # → 500

# Lister les sources uniques
jq '[.[].source] | unique' app/src/main/resources/mocks/events.json  # → ["api","mobile","web"]

# Premier utilisateur connecté
jq '[.[] | select(.type == "USER_LOGIN")][0].userId' app/src/main/resources/mocks/events.json
```

---

## Démo 6 — Synergie batch-config-audit : fd + xq (3 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent lirait chaque pom.xml un par un
cat pom.xml
cat core/pom.xml
cat infrastructure/pom.xml
cat api/pom.xml
cat app/pom.xml
```

#### Windows (PowerShell)
```powershell
Get-Content pom.xml
Get-Content core\pom.xml
Get-Content infrastructure\pom.xml
Get-Content api\pom.xml
Get-Content app\pom.xml
```

**Output** : 5 fichiers complets, total ~7 408 chars.
- **≈ 1 852 tokens**

### AVEC skill — Extraction chirurgicale en une commande

#### macOS (zsh)
```bash
# Auditer toutes les versions Maven en une seule commande
fd -g "pom.xml" . -x sh -c 'echo "$(yq -p xml -oy ".project.artifactId" "$1"): $(yq -p xml -oy ".project.version" "$1")"' _ {}
```

#### Windows (PowerShell)
```powershell
fd -g "pom.xml" . | ForEach-Object { 
    $art = yq -p xml -oy ".project.artifactId" $_
    $ver = yq -p xml -oy ".project.version" $_
    "$art`: $ver"
}
```

**Output** :
```
token-economy-demo: 1.0.0-SNAPSHOT
core: null
infrastructure: null
api: null
app: null
```
- **≈ 20 tokens** (les modules enfants héritent la version du parent, d'où `null`)

### 📊 Gain : ~99% (1 852 → 20 tokens)

**Bonus — auditer les dépendances de tous les modules :**
```bash
fd -g "pom.xml" . --max-depth 2 -x sh -c '
  echo "=== $(yq -p xml -oy ".project.artifactId" "$1") ==="
  yq -p xml -oy ".project.dependencies.dependency[].artifactId" "$1" 2>/dev/null
' _ {}
```

---

## Démo 7 — Synergie structural-search : fd + rg (2 min)

### SANS skill — Ce que l'agent fait naïvement

#### macOS (zsh)
```bash
# L'agent lirait TOUS les fichiers Java pour chercher les controllers
cat api/src/main/java/com/demo/api/UserController.java
cat api/src/main/java/com/demo/api/ProductController.java
cat api/src/main/java/com/demo/api/OrderController.java
# ... et potentiellement les 22 fichiers Java
```

#### Windows (PowerShell)
```powershell
Get-ChildItem -Recurse -Filter "*.java" | ForEach-Object { Get-Content $_.FullName }
```

**Output** : Tout le code Java, ~22 fichiers, ~15 000 chars.
- **≈ 3 750 tokens**

### AVEC skill — Recherche bi-dimensionnelle

#### macOS (zsh)
```bash
# fd (OÙ) + rg (QUOI) : trouver les @RestController
fd -e java . -x rg -l "@RestController" {}

# Ou directement
rg -l "@RestController" -t java .
```

#### Windows (PowerShell)
```powershell
rg -l "@RestController" -t java .
```

**Output** :
```
api/src/main/java/com/demo/api/UserController.java
api/src/main/java/com/demo/api/ProductController.java
api/src/main/java/com/demo/api/OrderController.java
```
- **≈ 30 tokens**

### 📊 Gain : ~99% (3 750 → 30 tokens)

**Bonus — trouver les ports (interfaces du domaine) :**
```bash
fd -e java . core/src/main/java -x rg -l "public interface" {}
```

---

## Démo 8 — snip : Filtrer l'output CLI (2 min)

**Message clé** : Les outils précédents ciblent les **fichiers**. `snip` cible l'**output des commandes** — il filtre le bruit de Maven, npm, dotnet via des filtres YAML.

### SANS snip — Ce que l'agent reçoit

#### macOS (zsh)
```bash
mvn clean compile
```

#### Windows (PowerShell)
```powershell
mvn clean compile
```

**Output** : ~200 lignes (Scanning, Downloading, Downloaded, Compiling, etc.)
- **~15 000 chars ≈ 3 750 tokens**

### AVEC snip — Output filtré

#### macOS (zsh)
```bash
snip mvn clean compile
```

#### Windows (PowerShell)
```powershell
snip mvn clean compile
```

**Output** : BUILD SUCCESS + erreurs/warnings seulement.
- **~750 chars ≈ 188 tokens**

### 📊 Gain : ~95% (3 750 → 188 tokens)

**Variantes snip :**
```bash
snip mvn clean test          # Garde tests results + failures + BUILD
snip mvn clean package       # Garde JAR info + BUILD
snip mvn dependency:tree     # output réduit
```

> **💡 Installation** : `brew install snip` (macOS) / `scoop install snip` (Windows)
> Les filtres YAML se trouvent dans `.github/skills/snip-jvm/filters/`

---

## Démo 9 — Récap et Conclusion (2 min)

### Tableau récapitulatif des gains

| Outil | SANS skill | AVEC skill | Gain |
|-------|-----------|------------|------|
| **fd** (fichiers Java) | ~343 tokens | ~200 tokens | **-42%** |
| **rg** (chercher dans events.json) | ~86 243 tokens | ~500 tokens | **-99.4%** |
| **yq** (extraire config YAML) | ~217 tokens | ~5 tokens | **-97.7%** |
| **xq** (extraire version pom.xml) | ~620 tokens | ~15 tokens | **-97.6%** |
| **jq** (extraire données JSON) | ~86 243 tokens | ~1-40 tokens | **-99.9%** |
| **fd + xq** (batch 5 pom.xml) | ~1 852 tokens | ~20 tokens | **-98.9%** |
| **fd + rg** (structural search) | ~3 750 tokens | ~30 tokens | **-99.2%** |
| **snip** (Maven compile) | ~3 750 tokens | ~188 tokens | **-95%** |

### Arbre de décision

```
Que cherchez-vous ?
├── Des fichiers (noms, extensions, chemins) → fd
├── Du contenu dans des fichiers → rg
├── Un champ dans un YAML → yq
├── Un champ dans un XML/pom.xml → yq -p xml
├── Un champ dans un JSON → jq
├── Le même champ dans N fichiers → fd + yq/jq/xq (batch)
├── Des fichiers + leur contenu → fd + rg (structural)
└── Output CLI trop verbeux (Maven, npm…) → snip
```

### Installation one-liner

```bash
# macOS
brew install fd ripgrep yq jq

# Windows
winget install sharkdp.fd BurntSushi.ripgrep.MSVC MikeFarah.yq jqlang.jq
```

⚠️ **Attention** : utiliser **mikefarah/yq** (Go), pas kislyuk/yq (Python).
Vérifier : `yq --version` doit afficher `yq (https://github.com/mikefarah/yq/) version v4.x`

---

## Notes pour le speaker

### Timing

| Section | Début | Fin |
|---------|-------|-----|
| Intro | 0:00 | 3:00 |
| fd | 3:00 | 7:00 |
| rg | 7:00 | 11:00 |
| yq | 11:00 | 15:00 |
| xq | 15:00 | 19:00 |
| jq | 19:00 | 23:00 |
| Synergie batch | 23:00 | 26:00 |
| Synergie structural | 26:00 | 28:00 |
| snip (Maven) | 28:00 | 30:00 |
| Conclusion | 30:00 | 32:00 |

### En cas de retard

Si en retard de > 3 min à la démo 5 (jq), **skipper snip** (démo 8) et **la synergie structural** (démo 7) et passer directement à la conclusion.

### Astuces de démo live

1. **Préparer les commandes** dans un fichier texte à copier-coller (ou utiliser les slides HTML)
2. **Agrandir le terminal** : font-size 18px minimum, fond sombre
3. **Montrer le `wc -c` avant/après** pour chaque démo — le chiffre qui chute est l'élément marquant
4. **Ne pas lire l'output long** : laisser le scroll défiler ~2 secondes, puis dire "c'est CE VOLUME que l'agent charge dans sa mémoire"
5. **Avoir une slide de backup** avec les résultats pré-calculés en cas de problème réseau/install
