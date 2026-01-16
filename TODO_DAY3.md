# 📝 Tâches Restantes - Jour 3

Ce document liste les tâches restantes pour finaliser le projet Brief Terraform.

## ✅ Complété

- [x] **README.md Complet** (1599 lignes)
  - [x] Vue d'ensemble et architecture
  - [x] Prérequis et configuration détaillée
  - [x] Instructions de déploiement pas à pas
  - [x] Section Utilisation avec exemples
  - [x] Troubleshooting avec 8 erreurs documentées
  - [x] Gestion des coûts et optimisation
  - [x] Section nettoyage et reproductibilité
  - [x] Ressources et documentation
  - [x] Concepts clés et améliorations possibles
  - [x] Checklist finale

- [x] **CI/CD Workflows** (Bonus)
  - [x] 4 workflows GitHub Actions créés
  - [x] Documentation workflows (.github/workflows/README.md)
  - [x] Service Principal request documentation
  - [x] Workflows poussés vers GitHub

- [x] **Structure de Documentation**
  - [x] Dossier docs/screenshots/ créé
  - [x] Instructions détaillées pour captures (INSTRUCTIONS.md)

## 🔄 En Cours / À Faire

### 1. 📸 Captures d'Écran

**Priorité** : Haute  
**Temps estimé** : 30-45 minutes

#### Captures Obligatoires (7)
- [ ] `azure-resources-overview.png` - Vue d'ensemble des 11 ressources Azure
- [ ] `acr-repositories.png` - Image Docker dans Azure Container Registry
- [ ] `storage-raw-container.png` - 3 fichiers Parquet dans blob storage
- [ ] `container-app-logs.png` - Logs d'exécution du pipeline
- [ ] `cosmos-db-overview.png` - Configuration Cosmos DB for PostgreSQL
- [ ] `log-analytics-queries.png` - Requête KQL avec résultats
- [ ] `terraform-apply-output.png` - Sortie complète de terraform apply

#### Capture Bonus (1)
- [ ] `github-actions-workflows.png` - Workflows CI/CD (si Service Principal configuré)

**Instructions** : Voir `docs/screenshots/INSTRUCTIONS.md`

---

### 2. 🧹 Nettoyage du Code (Code Cleanup)

**Priorité** : Moyenne  
**Temps estimé** : 45-60 minutes

#### 2.1 Terraform Files - Ajouter des Commentaires

**Fichiers à enrichir** :

##### `terraform/main.tf`
- [ ] Commenter la déclaration du resource group
- [ ] Expliquer les tags et leur utilité
- [ ] Documenter la stratégie de naming

##### `terraform/providers.tf`
- [ ] Expliquer le choix de la version du provider
- [ ] Documenter les features requises

##### `terraform/variables.tf`
- [ ] Ajouter des descriptions complètes à chaque variable
- [ ] Documenter les valeurs par défaut et leur raison
- [ ] Ajouter des exemples de valeurs valides

##### `terraform/storage.tf`
- [ ] Commenter la configuration du Storage Account (LRS, Hot tier)
- [ ] Expliquer les 2 containers (raw, processed)
- [ ] Documenter les paramètres de sécurité (HTTPS, TLS 1.2)

##### `terraform/acr.tf`
- [ ] Expliquer le SKU Basic vs Standard/Premium
- [ ] Documenter admin_enabled = true (avec warning sécurité)

##### `terraform/cosmosdb.tf`
- [ ] Détailler la configuration 1 vCore Burstable
- [ ] Expliquer coordinator_storage_quota_in_mb
- [ ] Commenter la firewall rule (Azure services)
- [ ] Documenter le choix de ha_enabled = false

##### `terraform/log_analytics.tf`
- [ ] Expliquer retention_in_days = 30
- [ ] Commenter le SKU PerGB2018

##### `terraform/container_apps.tf`
- [ ] Documenter la configuration CPU (0.5) et Memory (1Gi)
- [ ] Expliquer min_replicas = 0 pour optimisation coûts
- [ ] Commenter chaque variable d'environnement
- [ ] Documenter la configuration registry

##### `terraform/outputs.tf`
- [ ] Ajouter des descriptions à chaque output
- [ ] Expliquer l'utilité de chaque output exporté

#### 2.2 Python Code - Ajouter des Docstrings

**Fichiers à documenter** :

##### `pipelines/ingestion/download.py`
```python
"""
Pipeline 1 : Téléchargement des données NYC Taxi

Ce module télécharge les fichiers Parquet depuis NYC TLC et les upload
vers Azure Blob Storage dans le container 'raw'.

Fonctionnalités:
- Téléchargement parallèle des fichiers
- Upload vers Azure Storage
- Gestion des erreurs réseau
- Logging détaillé

Auteur: [Votre Nom]
Date: Janvier 2026
"""
```

- [ ] Ajouter docstring au module
- [ ] Documenter la fonction principale
- [ ] Commenter la logique de retry
- [ ] Expliquer le chunking pour upload

##### `pipelines/staging/load_duckdb.py`
- [ ] Ajouter docstring au module (Pipeline 2 : Load)
- [ ] Documenter la connexion DuckDB → PostgreSQL
- [ ] Commenter les filtres de qualité des données
- [ ] Expliquer la logique de truncate/insert

##### `pipelines/transformation/transform.py`
- [ ] Ajouter docstring au module (Pipeline 3 : Transform)
- [ ] Documenter la création du modèle en étoile
- [ ] Commenter chaque dimension (datetime, location, payment, vendor)
- [ ] Expliquer les clés de jointure

##### `utils/database.py`
- [ ] Documenter les fonctions de connexion
- [ ] Commenter la gestion du connection pooling
- [ ] Expliquer les paramètres SSL

##### `utils/download_helper.py`
- [ ] Documenter les fonctions utilitaires
- [ ] Commenter la gestion des retries
- [ ] Expliquer les validations

##### `utils/parquet_utils.py`
- [ ] Documenter les fonctions de lecture Parquet
- [ ] Commenter les optimisations mémoire

##### `main.py`
- [ ] Ajouter docstring principal
- [ ] Documenter la séquence d'exécution
- [ ] Commenter la gestion des erreurs

#### 2.3 SQL Files - Commenter les Requêtes

##### `sql/create_staging_table.sql`
- [ ] Commenter chaque colonne et son type
- [ ] Expliquer les contraintes

##### `sql/transformations.sql`
- [ ] Documenter chaque CREATE TABLE
- [ ] Commenter les INSERT SELECT
- [ ] Expliquer les JOIN conditions

##### `sql/init.sql`, `sql/insert_to.sql`, `sql/truncate.sql`
- [ ] Ajouter des headers explicatifs
- [ ] Commenter les étapes

---

### 3. ✅ Vérifier la Reproductibilité

**Priorité** : Haute  
**Temps estimé** : 15-20 minutes

**Procédure** :

```bash
# 1. Détruire l'infrastructure actuelle
cd terraform
terraform destroy --auto-approve

# 2. Nettoyer l'état local
rm -f terraform.tfstate terraform.tfstate.backup
rm -f .terraform.lock.hcl
rm -rf .terraform/

# 3. Réinitialiser
terraform init

# 4. Recréer tout
terraform plan
terraform apply --auto-approve

# 5. Vérifier que le pipeline s'exécute
az containerapp logs show \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --tail 100
```

**Critères de succès** :
- [ ] `terraform destroy` réussit sans erreurs
- [ ] `terraform init` télécharge les providers
- [ ] `terraform plan` affiche 11 ressources à créer
- [ ] `terraform apply` crée les 11 ressources en ~12 minutes
- [ ] Container App démarre et exécute le pipeline
- [ ] Pipeline 1 (Download) réussit (3 fichiers uploadés)
- [ ] Logs visibles dans Azure Portal

**Documenter** :
- [ ] Prendre une capture du `terraform plan` (11 ressources)
- [ ] Prendre une capture du `terraform apply` (Apply complete!)
- [ ] Noter le temps total de déploiement
- [ ] Vérifier les coûts projetés dans Azure Portal

---

### 4. 🎥 Vidéo de Démonstration (Bonus - Optionnel)

**Priorité** : Basse  
**Temps estimé** : 60-90 minutes (préparation + enregistrement + édition)

**Plan de la vidéo (8-12 minutes)** :

1. **Introduction** (30 secondes)
   - Présentation du projet Brief Terraform
   - Objectifs : IaC, Azure, Data Pipeline

2. **Architecture** (1-2 minutes)
   - Montrer le diagramme architecture
   - Expliquer les 11 ressources Azure
   - Présenter le flux : Download → Load → Transform

3. **Configuration Terraform** (2-3 minutes)
   - Parcourir les fichiers .tf
   - Expliquer les variables terraform.tfvars
   - Montrer les outputs

4. **Déploiement Live** (3-4 minutes)
   - Lancer `terraform init`
   - Exécuter `terraform plan` (expliquer le plan)
   - Lancer `terraform apply` (accéléré si trop long)
   - Montrer la création dans Azure Portal en temps réel

5. **Vérification** (2-3 minutes)
   - Azure Portal : montrer les ressources
   - Container App logs : voir l'exécution
   - Storage Account : afficher les fichiers Parquet
   - Connexion PostgreSQL : requête simple

6. **Troubleshooting** (1-2 minutes)
   - Montrer une erreur (ex: ARM64/AMD64)
   - Expliquer la solution appliquée

7. **Nettoyage** (1 minute)
   - `terraform destroy`
   - Vérifier la suppression

8. **Conclusion** (30 secondes)
   - Récapitulatif : IaC, reproductibilité, best practices
   - Remerciements

**Outils recommandés** :
- **macOS** : QuickTime Screen Recording (gratuit)
- **Windows** : OBS Studio (gratuit)
- **Cloud** : Loom (gratuit pour 5 minutes)
- **Édition** : iMovie, DaVinci Resolve (gratuit)

**Checklist enregistrement** :
- [ ] Script préparé (bullet points)
- [ ] Environnement propre (détruire puis recréer)
- [ ] Microphone testé (voix claire)
- [ ] Taille d'écran : 1920x1080 minimum
- [ ] Pas de notifications durant enregistrement
- [ ] Fenêtres en plein écran (Terminal, Azure Portal)

**Checklist post-production** :
- [ ] Couper les temps morts (attentes)
- [ ] Ajouter des titres pour chaque section
- [ ] Ajouter des flèches/highlights si besoin
- [ ] Exporter en 1080p
- [ ] Upload sur YouTube/Loom/OneDrive
- [ ] Ajouter le lien dans README section "Démonstration"

---

## 📊 Temps Estimé Total

| Tâche | Priorité | Temps estimé | Statut |
|-------|----------|--------------|--------|
| Captures d'écran | 🔴 Haute | 30-45 min | ⏳ À faire |
| Code cleanup (Terraform) | 🟡 Moyenne | 30 min | ⏳ À faire |
| Code cleanup (Python) | 🟡 Moyenne | 30 min | ⏳ À faire |
| Vérifier reproductibilité | 🔴 Haute | 15-20 min | ⏳ À faire |
| Vidéo démo (optionnel) | 🟢 Basse | 60-90 min | ⏸️ Bonus |

**Total minimum** : **1h45 - 2h15**  
**Total avec vidéo** : **2h45 - 3h45**

---

## 🎯 Priorités Recommandées

### Ordre d'exécution suggéré :

1. **Captures d'écran** (30-45 min)
   - ✅ Infrastructure déjà déployée
   - ✅ Permet de documenter l'état actuel
   - ⚠️ À faire AVANT terraform destroy

2. **Vérifier reproductibilité** (15-20 min)
   - 🔄 Détruire et recréer pour tester
   - 📸 Capturer le nouveau déploiement si nécessaire
   - ✅ Valide que tout fonctionne de A à Z

3. **Code cleanup** (1h)
   - 📝 Améliore la qualité du code
   - 📚 Facilite la compréhension
   - ⭐ Démontre les bonnes pratiques

4. **Vidéo démo** (optionnel, 1-1.5h)
   - 🎥 Bonus pour impressionner
   - 🏆 Différenciant pour évaluation
   - 💡 Utile pour portfolio personnel

---

## ✅ Validation Finale

Avant de soumettre le projet, vérifier :

### Documentation
- [x] README.md complet et détaillé (1599 lignes)
- [ ] Captures d'écran ajoutées (7 obligatoires + 1 bonus)
- [ ] BRIEF.md lu et toutes les tâches accomplies

### Code
- [x] Terraform valide (`terraform validate`)
- [ ] Commentaires ajoutés dans tous les .tf
- [ ] Docstrings ajoutés dans tous les .py
- [ ] SQL commentés

### Infrastructure
- [x] Déploiement réussi (11 ressources)
- [ ] Reproductibilité testée (destroy + apply)
- [ ] Pipeline 1 (Download) fonctionne
- ⚠️ Pipeline 2 (Load) échoue (password @ character - documenté)
- ❌ Pipeline 3 (Transform) non exécuté (dépend de Load)

### Git
- [x] Commits atomiques avec messages clairs
- [x] Pas de secrets/credentials dans Git
- [x] .gitignore configuré correctement
- [x] README poussé vers GitHub

### Bonus
- [x] CI/CD workflows créés
- [x] Documentation workflows
- [ ] Service Principal configuré (dépend formateur)
- [ ] Vidéo démo (optionnel)

---

## 🆘 Aide et Ressources

### En cas de blocage

1. **Captures d'écran** : Voir `docs/screenshots/INSTRUCTIONS.md`
2. **Code cleanup** : Exemples de docstrings dans ce document
3. **Reproductibilité** : Commandes détaillées ci-dessus
4. **Vidéo** : Plan détaillé fourni

### Contact

- **Formateur** : Pour questions Azure/Service Principal
- **GitHub Issues** : Pour problèmes techniques
- **README.md** : Section Troubleshooting pour erreurs communes

---

**Bon courage pour finaliser le projet ! 🚀**

_Document créé le : $(date)_  
_Dernière mise à jour : $(date)_
