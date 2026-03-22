# Investigation Java — Demo Runbook (Windows / PowerShell)

> Présentation interne. Utilise le projet Spring Boot `demo/token-economy-demo/` comme terrain d'investigation.

## Prérequis

| Outil     | Version   | Installation                              |
| --------- | --------- | ----------------------------------------- |
| Java      | 17+       | `winget install Microsoft.OpenJDK.17`     |
| Maven     | 3.9+      | `winget install Apache.Maven`             |
| fd        | latest    | `winget install sharkdp.fd`               |
| ripgrep   | latest    | `winget install BurntSushi.ripgrep.MSVC`  |

Vérifier :
```powershell
java -version && mvn -version && fd --version && rg --version
```

---

## Phase 0 — Setup (slide 14)

```powershell
cd demo\token-economy-demo
mvn compile
```

> ✅ BUILD SUCCESS → les dépendances sont dans `$env:USERPROFILE\.m2`

---

## Phase 1 — fd : Localiser les JARs (slide 15)

```powershell
# Trouver Hibernate Core
fd "hibernate-core" "$env:USERPROFILE\.m2" -e jar

# Trouver Spring Data JPA
fd "spring-data-jpa" "$env:USERPROFILE\.m2" -e jar

# Filtrer sources/javadocs
fd "hibernate" "$env:USERPROFILE\.m2" -e jar | rg -v "source|javadoc"
```

**Point clé** : `fd` est 5x plus rapide que `Get-ChildItem -Recurse` et retourne des chemins propres.

---

## Phase 2 — jar tf + rg : Trouver les classes (slide 16)

```powershell
# Stocker le chemin du JAR
$jar = fd "hibernate-core-6" "$env:USERPROFILE\.m2" -e jar | Select-Object -First 1

# Lister les classes liées au streaming
jar tf $jar | rg "Stream|TypedQuery|AbstractQuery"

# Chercher les implémentations
jar tf $jar | rg "impl/" | rg -v "test|Test"
```

**Point clé** : `Select-Object -First 1` remplace `head -1` en PowerShell.

---

## Phase 3 — javap -c + rg : Tracer le comportement (slide 17)

```powershell
# Décompiler et tracer getResultStream
javap -c -p -classpath $jar org.hibernate.query.spi.AbstractQuery | rg "getResultStream|getResultList|scroll"

# Chercher des instanciations mémoire
javap -c -p -classpath $jar org.hibernate.query.spi.AbstractQuery | rg "new.*ArrayList|new.*HashSet|getResultList"

# Voir toutes les invocations de méthode
javap -c -p -classpath $jar org.hibernate.query.spi.AbstractQuery | rg "invoke(virtual|interface|special|static)"
```

**Point clé** : `-p` affiche les méthodes privées. `-c` décompile le bytecode.

---

## Aparté — Cas Blaze-Persistence (slides 10-11)

> 🎤 **DÉMO LIVE** — Lancer les commandes suivantes sur un vrai projet avec Blaze-Persistence.

```powershell
# 1. Trouver le JAR d'intégration
fd "blaze-persistence-integration-hibernate6-base" "$env:USERPROFILE\.m2" -e jar

# 2. Trouver la classe suspecte
$bp = fd "blaze-persistence-integration-hibernate6-base" "$env:USERPROFILE\.m2" -e jar | Select-Object -First 1
jar tf $bp | rg "ExtendedQuerySupport"

# 3. Décompiler et tracer
javap -c -p -classpath $bp com.blazebit.persistence.integration.hibernate.base.HibernateExtendedQuerySupport | rg "getResultStream|getResultList|scroll"
```

**Résultat attendu** : `getResultStream()` appelle `getResultList()` → charge **tout** en mémoire. Pas de vrai streaming.

---

## Récap — Le Pipeline Complet

```
fd (localiser) → jar tf (lister) → javap -c (décompiler) → rg (filtrer)
```

| Étape | Commande | Objectif |
| ----- | -------- | -------- |
| 1     | `fd "lib" .m2 -e jar` | Trouver le JAR |
| 2     | `jar tf <jar> \| rg "Class"` | Trouver la classe |
| 3     | `javap -c -classpath <jar> pkg.Class` | Décompiler le bytecode |
| 4     | `\| rg "pattern"` | Filtrer les instructions |

---

## Troubleshooting

| Problème | Solution |
| -------- | -------- |
| `mvn compile` échoue | Vérifier `JAVA_HOME`, proxy Maven |
| `fd` ne trouve rien | Vérifier le chemin `.m2` : `ls $env:USERPROFILE\.m2\repository` |
| `javap` erreur classpath | Utiliser le chemin complet du JAR (pas de wildcards) |
| `rg` pas installé | `winget install BurntSushi.ripgrep.MSVC` |
