# 📸 Instructions pour les Captures d'Écran

Ce document explique quelles captures d'écran prendre pour documenter votre déploiement Azure.

## 📋 Liste des Captures à Réaliser

### 1. Vue d'Ensemble des Ressources (`azure-resources-overview.png`)

**Chemin dans Azure Portal** :
- Azure Portal → Resource groups → `fabgrallRG`

**Que capturer** :
- Liste complète des 11 ressources déployées
- Colonnes visibles : Name, Type, Location, Status
- S'assurer que tous les Status affichent "Succeeded"

**Nom du fichier** : `azure-resources-overview.png`

---

### 2. Container Registry - Repositories (`acr-repositories.png`)

**Chemin dans Azure Portal** :
- Azure Portal → Container registries → `acrnyctaxiw2t94joh`
- Menu latéral → Services → Repositories

**Que capturer** :
- Repository `nyc-taxi-pipeline`
- Tag `latest`
- Digest SHA256
- Taille de l'image
- Date de dernière modification

**Nom du fichier** : `acr-repositories.png`

---

### 3. Storage Account - Fichiers Parquet (`storage-raw-container.png`)

**Chemin dans Azure Portal** :
- Azure Portal → Storage accounts → `stnyctaxiw2t94joh`
- Menu latéral → Data storage → Containers → `raw`

**Que capturer** :
- Les 3 fichiers Parquet :
  - `yellow_tripdata_2024-01.parquet` (~50 MB)
  - `yellow_tripdata_2024-02.parquet` (~50 MB)
  - `yellow_tripdata_2024-03.parquet` (~60 MB)
- Colonnes : Name, Last modified, Size

**Nom du fichier** : `storage-raw-container.png`

---

### 4. Container App - Logs d'Exécution (`container-app-logs.png`)

**Chemin dans Azure Portal** :
- Azure Portal → Container Apps → `ca-nyctaxi-pipeline-dev`
- Menu latéral → Monitoring → Log stream

**Que capturer** :
- Logs montrant l'exécution du Pipeline 1 (Download)
- Messages de succès : "Fichier téléchargé avec succès"
- Messages de succès : "Fichier uploadé vers Azure"
- Message final : "✅ Pipeline 1 (Download) terminé"

**Alternative si Log stream vide** :
- Onglet **Console logs** ou **Revisions** → Logs

**Nom du fichier** : `container-app-logs.png`

---

### 5. Cosmos DB for PostgreSQL - Vue d'Ensemble (`cosmos-db-overview.png`)

**Chemin dans Azure Portal** :
- Azure Portal → Azure Cosmos DB → `cosmos-nyctaxi-dev`
- Onglet **Overview**

**Que capturer** :
- Nom du cluster : `cosmos-nyctaxi-dev`
- Configuration :
  - Node count : 1
  - Compute : 1 vCore (Burstable)
  - Storage : configuré
- Connection string (hostname visible)
- Status : Running

**Nom du fichier** : `cosmos-db-overview.png`

---

### 6. Log Analytics Workspace - Requêtes (`log-analytics-queries.png`)

**Chemin dans Azure Portal** :
- Azure Portal → Log Analytics workspaces → `log-nyctaxi-dev`
- Menu latéral → General → Logs

**Requête KQL à exécuter** :
```kql
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(1h)
| project TimeGenerated, Log_s
| order by TimeGenerated desc
| limit 50
```

**Que capturer** :
- L'éditeur de requête avec la requête KQL
- Les résultats montrant les logs du Container App
- Au moins 10-20 lignes de résultats

**Nom du fichier** : `log-analytics-queries.png`

---

### 7. Terraform Apply - Sortie Complète (`terraform-apply-output.png`)

**Outil** : Terminal / iTerm

**Commande** :
```bash
cd terraform
terraform apply
```

**Que capturer** :
- La sortie complète du `terraform apply`
- Message : `Plan: 11 to add, 0 to change, 0 to destroy`
- Progression de création des ressources
- Message final : `Apply complete! Resources: 11 added, 0 changed, 0 destroyed.`
- Section **Outputs** avec toutes les valeurs

**Nom du fichier** : `terraform-apply-output.png`

**Alternative** : Capturer plusieurs screenshots si la sortie est longue

---

### 8. GitHub Actions Workflows (BONUS) (`github-actions-workflows.png`)

**Chemin dans GitHub** :
- GitHub Repository → Actions

**Que capturer** :
- Liste des 4 workflows :
  - CI Pipeline
  - Deploy to Azure
  - Destroy Infrastructure
  - PR Terraform Plan
- Un workflow run réussi (si Service Principal configuré)
- Status : ✅ Success

**Nom du fichier** : `github-actions-workflows.png`

**Note** : Cette capture n'est disponible que si les workflows GitHub Actions ont été configurés et exécutés avec succès (nécessite Service Principal).

---

## 🛠️ Conseils pour les Captures

### Qualité des Captures

- **Résolution** : Minimum 1920x1080 pour bonne lisibilité
- **Format** : PNG (meilleure qualité) ou JPG
- **Outil recommandé** : 
  - macOS : Cmd+Shift+4 pour sélectionner une zone
  - Windows : Outil Capture d'écran (Win+Shift+S)
  - Extension Chrome : Awesome Screenshot

### Confidentialité

⚠️ **Attention aux informations sensibles** :
- Masquer les adresses IP publiques si nécessaire
- Masquer les mots de passe visibles
- Masquer les subscription IDs si projet public

### Organisation des Fichiers

Placez tous les fichiers dans :
```
docs/screenshots/
├── azure-resources-overview.png
├── acr-repositories.png
├── storage-raw-container.png
├── container-app-logs.png
├── cosmos-db-overview.png
├── log-analytics-queries.png
├── terraform-apply-output.png
└── github-actions-workflows.png (optionnel)
```

---

## ✅ Checklist

- [ ] `azure-resources-overview.png` - Vue d'ensemble des 11 ressources
- [ ] `acr-repositories.png` - Image Docker dans ACR
- [ ] `storage-raw-container.png` - 3 fichiers Parquet
- [ ] `container-app-logs.png` - Logs du pipeline
- [ ] `cosmos-db-overview.png` - Configuration Cosmos DB
- [ ] `log-analytics-queries.png` - Requête KQL avec résultats
- [ ] `terraform-apply-output.png` - Sortie terraform apply
- [ ] `github-actions-workflows.png` (bonus) - Workflows CI/CD

---

## 🔄 Alternative : Captures Terminal

Si vous ne voulez pas faire de captures du portail Azure, vous pouvez documenter via CLI :

```bash
# Vue d'ensemble des ressources
az resource list --resource-group fabgrallRG --output table > outputs/resources-list.txt

# Liste des fichiers blob
az storage blob list \
  --container-name raw \
  --account-name stnyctaxiw2t94joh \
  --output table > outputs/storage-files.txt

# Logs du Container App
az containerapp logs show \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --tail 100 > outputs/container-logs.txt

# Repositories ACR
az acr repository list \
  --name acrnyctaxiw2t94joh \
  --output table > outputs/acr-repos.txt
```

Puis faire des captures d'écran de ces sorties terminal.

---

**Bon courage pour les captures ! 📸**
