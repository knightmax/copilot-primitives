# Token Economy Demo — Projet Spring Boot

Projet multi-module Spring Boot conçu comme **jeu de données** pour la démonstration live de l'économie de tokens avec les CLI (`fd`, `rg`, `yq`, `xq`, `jq`).

## Structure

```
token-economy-demo/
├── pom.xml                          # Parent POM (Spring Boot 4.0.4)
├── core/                            # Domain — modèles, ports, services (0 dépendance framework)
├── infrastructure/                  # Adapters — JPA, entités, repositories
├── api/                             # Controllers REST
├── app/                             # Spring Boot, config, YAML, tests
│   └── src/main/resources/
│       ├── application.yml          # Config principale
│       ├── application-dev.yml      # Profil dev (H2)
│       ├── application-prod.yml     # Profil prod (PostgreSQL)
│       ├── application-staging.yml  # Profil staging
│       └── mocks/
│           ├── users.json           # ~200 entrées (65 KB)
│           ├── products.json        # ~150 entrées (60 KB)
│           ├── orders.json          # ~300 entrées (215 KB)
│           └── events.json          # ~500 entrées (345 KB) ← le gros fichier
└── docker-compose.yml               # PostgreSQL + pgAdmin
```

## Prérequis

- Java 25+
- Maven 3.9+

## Compilation

```bash
mvn compile
```

## Lancement (profil dev avec H2)

```bash
cd app && mvn spring-boot:run
```

## Ce que ce projet permet de démontrer

| CLI | Démo | Fichiers ciblés |
|-----|------|-----------------|
| `fd` | Trouver les fichiers Java, YAML, JSON | Tous |
| `rg` | Chercher dans events.json (345 KB) | `mocks/events.json` |
| `yq` | Extraire config YAML | `application*.yml` |
| `xq` | Extraire versions/deps Maven | `pom.xml` × 5 |
| `jq` | Extraire données JSON | `mocks/*.json` |
| `fd + xq` | Batch audit des versions Maven | Tous les `pom.xml` |
| `fd + rg` | Trouver les `@RestController` | `**/*.java` |
