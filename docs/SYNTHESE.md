# Synthèse – TP Qualité de code & CI/CD

## 1. Problèmes constatés (état initial)

| Domaine    | Problème                                                                                     |
| ---------- | -------------------------------------------------------------------------------------------- |
| Install    | Pas de `package-lock.json` → `npm ci` impossible (local et CI)                               |
| Lint       | `const UNUSED = 123` → warning `no-unused-vars`                                              |
| Format     | 9 fichiers non conformes à Prettier (guillemets doubles, points-virgules manquants…)         |
| Tests      | Jest plante : `Cannot use import statement outside a module` (projet en ESM)                 |
| Couverture | Seuls `GET /health` et `POST /todos` testés : `GET /todos`, 400, `DELETE` 204/404 non testés |
| Sécurité   | En-tête `X-Powered-By: Express` exposé (Security Hotspot Sonar)                              |
| Outillage  | ESLint/Prettier analysent aussi `coverage/` ; bug `"$token:"` dans `create_quality_gate.ps1` |
| CI         | Pas de pipeline GitHub Actions                                                               |

## 2. Corrections apportées

- **Install** : génération et commit de `package-lock.json`.
- **Lint / format** : suppression de `UNUSED`, `prettier --write`, ajout de `.eslintignore`,
  `.prettierignore`, `.gitignore` et `.gitattributes` (fins de ligne LF, PDF en binaire).
- **Tests** : scripts `test` / `test:cov` lancés via `node --experimental-vm-modules` (Jest en ESM,
  compatible Windows et Linux) ; 7 nouveaux tests (liste, POST sans titre / sans body, DELETE 204 et
  404, en-tête, store).
- **Sécurité** : `app.disable('x-powered-by')` + test associé ; `req.body ?? {}` pour un POST sans body.
- **Quality Gate** : correction du script PowerShell (`"${token}:"`), création du gate
  « CESI - NodeJS TP Gate » (coverage ≥ 80 %, duplication ≤ 3 %, hotspots revus 100 %, ratings A).
- **CI** : `.github/workflows/ci.yml` avec `lint` → `test` → `sonar`. SonarQube est lancé comme
  _service container_ dans la pipeline (pas besoin d'exposer le SonarQube local), le scan utilise
  `-Dsonar.qualitygate.wait=true` : un Quality Gate FAIL fait échouer la pipeline.

## 3. Résultats

| Indicateur             | Avant      | Après      |
| ---------------------- | ---------- | ---------- |
| `npm run lint`         | 1 warning  | 0          |
| `npm run format`       | 9 fichiers | OK         |
| Tests                  | 0 (crash)  | 9 / 9      |
| Couverture (lignes)    | 0 %        | 96,7 %     |
| Couverture Sonar       | –          | 92,9 %     |
| Bugs / Vulnérabilités  | –          | 0 / 0      |
| Code smells / Hotspots | –          | 0 / 0      |
| Duplication            | –          | 0 %        |
| Ratings S / R / M      | –          | A / A / A  |
| **Quality Gate**       | –          | **PASSED** |

## 4. Points d'attention rencontrés

- Sous Windows, le scanner Docker doit viser `http://host.docker.internal:9000` (pas `localhost`).
- Sous PowerShell, l'option `-Dsonar.qualitygate.wait=true` doit être entre guillemets.
- SonarQube 9.9 ajoute d'office les conditions « Clean as You Code » à un nouveau Quality Gate.
