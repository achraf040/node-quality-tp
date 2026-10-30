# TP – Qualité de code & CI/CD (Node.js + SonarQube + GitLab)

## Prérequis

- Node.js 20+, npm
- Docker Desktop (port 9000 libre)
- Compte GitLab
- VS Code (+ ESLint, Prettier)

## Démarrage

```bash
npm ci
npm run dev      # http://localhost:3000/health
npm run test     # tests
npm run test:cov # génère coverage/lcov.info
npm run lint
npm run format   # vérifie formatage Prettier
```

## SonarQube (local)

1. Lancez SonarQube (voir `docs/sonar-docker-compose.yml`) puis : http://localhost:9000 (admin/admin → changer mdp)
2. Créez un projet `node-quality-tp` + générez un **token**
3. Exportez les variables :

```bash
export SONAR_HOST_URL="http://localhost:9000"
export SONAR_TOKEN="<votre_token>"
```

4. Lancez un scan depuis la racine du projet :

```bash
docker run --rm -e SONAR_HOST_URL -e SONAR_TOKEN -v "$PWD":/usr/src sonarsource/sonar-scanner-cli
```

## CI GitLab

- Ajoutez dans **Settings → CI/CD → Variables** : `SONAR_HOST_URL`, `SONAR_TOKEN`
- Pipeline `.gitlab-ci.yml` : stages `install` → `lint` → `test` → `sonar`
- Le job `sonar` attend le Quality Gate : `-Dsonar.qualitygate.wait=true`

## 🔒 Template de Quality Gate (recommandé)

Vous pouvez créer/importer automatiquement un **Quality Gate** “CESI – NodeJS TP Gate” et l’assigner à votre projet SonarQube.

### Bash (macOS/Linux)

```bash
export SONAR_HOST_URL="http://localhost:9000"
export SONAR_TOKEN="<admin_ou_qa_token>"
./scripts/create_quality_gate.sh node-quality-tp "CESI - NodeJS TP Gate"
```

### PowerShell (Windows)

```powershell
$env:SONAR_HOST_URL = "http://localhost:9000"
$env:SONAR_TOKEN    = "<admin_or_qa_token>"
.\scripts\create_quality_gate.ps1 -ProjectKey "node-quality-tp" -GateName "CESI - NodeJS TP Gate"
```

**Conditions appliquées (New Code)** : Couverture ≥ 80 %, Duplication ≤ 3 %, Hotspots revus = 100 %, Ratings Sécurité/Reliabilité/Maintenabilité = A.  
Si le **Quality Gate** est **FAIL**, le job `sonar` échoue dans la CI (bloquant).
