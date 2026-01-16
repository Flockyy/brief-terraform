# 🚕 NYC Taxi Data Pipeline - Infrastructure as Code

[![Terraform](https://img.shields.io/badge/Terraform-1.6.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?logo=docker)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python)](https://www.python.org/)

> Infrastructure as Code pour déployer un pipeline de données automatisé sur Azure, traitant les données des taxis de New York (NYC TLC Trip Record Data)

## 📋 Vue d'Ensemble

Ce projet implémente une **infrastructure cloud complète** sur Azure pour ingérer, transformer et analyser les données historiques des taxis new-yorkais. L'infrastructure est entièrement provisionnée avec **Terraform**, permettant un déploiement reproductible et versionné.

### 🎯 Objectifs du Projet

- **Infrastructure as Code** : Provisionnement automatisé avec Terraform
- **Data Pipeline Automatisé** : Téléchargement, transformation et chargement des données
- **Architecture Cloud-Native** : Containerisation avec Docker et Azure Container Apps
- **Monitoring** : Logs centralisés avec Azure Log Analytics
- **CI/CD** : Workflows GitHub Actions pour le déploiement automatique

### 📊 Pipeline de Données

Le pipeline traite les données en 3 étapes :

1. **Download** : Télécharge les fichiers Parquet depuis NYC TLC (3 mois de données ~153 MB)
2. **Load** : Charge les données dans PostgreSQL via DuckDB avec filtres de qualité
3. **Transform** : Crée un modèle en étoile (star schema) avec tables de dimensions et de faits

## 🏗️ Architecture Déployée

```
┌──────────────────────────────────────────────────────────────────────┐
│                          AZURE CLOUD                                  │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  🔄 CONTAINER APPS ENVIRONMENT                                 │  │
│  │                                                                 │  │
│  │  ┌──────────────────────────────────────────────────────────┐ │  │
│  │  │  NYC Taxi Pipeline Container App                         │ │  │
│  │  │  ┌────────────────────────────────────────────────────┐  │ │  │
│  │  │  │  📥 Pipeline 1: Download                           │  │ │  │
│  │  │  │  → Télécharge 3 fichiers Parquet (153 MB)         │  │ │  │
│  │  │  │  → Upload vers Azure Blob Storage                 │  │ │  │
│  │  │  └────────────────────────────────────────────────────┘  │ │  │
│  │  │  ┌────────────────────────────────────────────────────┐  │ │  │
│  │  │  │  💾 Pipeline 2: Load to PostgreSQL                 │  │ │  │
│  │  │  │  → Lecture depuis Blob Storage                     │  │ │  │
│  │  │  │  → Chargement avec DuckDB                          │  │ │  │
│  │  │  └────────────────────────────────────────────────────┘  │ │  │
│  │  │  ┌────────────────────────────────────────────────────┐  │ │  │
│  │  │  │  ⚙️ Pipeline 3: Transform (Star Schema)            │  │ │  │
│  │  │  │  → Création des tables de dimensions               │  │ │  │
│  │  │  │  → Création de la table de faits                   │  │ │  │
│  │  │  └────────────────────────────────────────────────────┘  │ │  │
│  │  └──────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────┐         ┌──────────────────────────────────┐   │
│  │  📦 STORAGE     │         │  🗄️ DATA WAREHOUSE               │   │
│  │                 │         │                                   │   │
│  │  Azure Blob     │────────▶│  Cosmos DB for PostgreSQL        │   │
│  │  Storage        │         │  (Citus Distributed)              │   │
│  │                 │         │                                   │   │
│  │  ✅ raw/        │         │  📋 Tables:                       │   │
│  │  ✅ processed/  │         │   ├─ staging_taxi_trips           │   │
│  └─────────────────┘         │   ├─ dim_datetime                 │   │
│                               │   ├─ dim_location                 │   │
│  ┌─────────────────┐         │   ├─ dim_payment                  │   │
│  │  🐳 REGISTRY    │         │   ├─ dim_vendor                   │   │
│  │                 │         │   └─ fact_trips                   │   │
│  │  Azure Container│         └──────────────────────────────────┘   │
│  │  Registry       │                                                 │
│  │                 │         ┌──────────────────────────────────┐   │
│  │  📦 Image:      │         │  📊 MONITORING                    │   │
│  │  nyc-taxi-      │         │                                   │   │
│  │  pipeline:      │         │  Log Analytics Workspace          │   │
│  │  latest         │         │  ✅ Application logs               │   │
│  └─────────────────┘         │  ✅ System metrics                 │   │
│                               └──────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

### 📦 Ressources Azure Déployées

| Ressource | Type | Description | Coût estimé |
|-----------|------|-------------|-------------|
| **Storage Account** | Standard LRS | Stockage des fichiers Parquet | ~0.02€/mois |
| **Container Registry** | Basic | Registry privé pour l'image Docker | ~5€/mois |
| **Container Apps** | 0.5 vCPU, 1Gi | Exécution du pipeline (min=0, max=1) | ~0.01€/seconde active |
| **Cosmos DB PostgreSQL** | 1 vCore Burstable | Data warehouse distribué | ~50-70€/mois |
| **Log Analytics** | PerGB2018 | Monitoring et logs (<5GB) | Gratuit |
| **Container Apps Env** | - | Environnement pour Container Apps | Inclus |

**💰 Coût total estimé** : ~60-80€/mois si actif 24/7  
**⚡ Optimisation** : Utilisez `terraform destroy` quotidiennement pour économiser ~70%
│  │  Image:      │        │                                 │  │
│  │  nyc-taxi-   │        │  Log Analytics Workspace        │  │
│  │  pipeline    │        │  - Application logs             │  │
│  └──────────────┘        │  - System metrics               │  │
│                          └─────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

## 🗂️ Structure du Projet

```
brief-terraform/
├── .github/                       # CI/CD Workflows
│   ├── workflows/
│   │   ├── ci.yml                # Validation Terraform + Docker build
│   │   ├── deploy.yml            # Déploiement automatique
│   │   ├── destroy.yml           # Destruction infrastructure
│   │   ├── pr-comment.yml        # Terraform plan sur PR
│   │   └── README.md             # Documentation workflows
│   └── PULL_REQUEST_TEMPLATE.md
│
├── terraform/                     # 🏗️ Infrastructure as Code
│   ├── main.tf                   # Resource Group, random suffix
│   ├── providers.tf              # Configuration Azure Provider
│   ├── variables.tf              # Définition des variables
│   ├── outputs.tf                # Outputs (URLs, noms, etc.)
│   ├── terraform.tfvars          # ⚠️ Vos valeurs (non committé)
│   ├── terraform.tfvars.example  # Template de configuration
│   ├── storage.tf                # Storage Account + containers
│   ├── acr.tf                    # Azure Container Registry
│   ├── cosmosdb.tf               # Cosmos DB for PostgreSQL
│   ├── log_analytics.tf          # Log Analytics Workspace
│   └── container_apps.tf         # Container Apps Environment + App
│
├── pipelines/                     # 🐍 Application Python (fournie)
│   ├── __init__.py
│   ├── ingestion/
│   │   └── download.py           # Pipeline 1: Download NYC data
│   ├── staging/
│   │   └── load_duckdb.py        # Pipeline 2: Load to PostgreSQL
│   └── transformation/
│       └── transform.py          # Pipeline 3: Star Schema
│
├── utils/                        # 🛠️ Utilitaires (fournis)
│   ├── __init__.py
│   ├── database.py              # Connexions PostgreSQL/DuckDB
│   ├── download_helper.py       # Helper téléchargement + Azure
│   └── parquet_utils.py         # Gestion fichiers Parquet
│
├── sql/                          # 📝 Scripts SQL (fournis)
│   ├── init.sql                 # Initialisation
│   ├── create_staging_table.sql # Table staging
│   ├── truncate.sql             # Nettoyage
│   ├── transformations.sql      # Création DIM/FACT
│   └── insert_to.sql            # Insertion données
│
├── Dockerfile                    # 🐳 Multi-stage build (fourni)
├── docker-compose.yml            # Dev local (fourni)
├── main.py                       # Point d'entrée (fourni)
├── pyproject.toml                # Dépendances Python
├── Makefile                      # Commandes utiles
├── .gitignore                    # Fichiers exclus de Git
├── BRIEF.md                      # Cahier des charges
├── SERVICE_PRINCIPAL_REQUEST.md  # Demande SP pour formateur
└── README.md                     # 📖 Ce fichier
```

## 🚀 Prérequis

### 🔧 Outils Requis

Avant de commencer, assurez-vous d'avoir installé :

#### 1. **Azure CLI** (v2.50+)
```bash
# macOS
brew install azure-cli

# Vérification
az --version

# Connexion à Azure
az login

# Vérifier la souscription active
az account show
```

#### 2. **Terraform** (v1.6.0+)
```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Vérification
terraform --version
```

#### 3. **Docker Desktop** (pour build d'image)
```bash
# macOS : https://www.docker.com/products/docker-desktop/

# Vérification
docker --version
docker ps  # Doit retourner une liste vide (pas d'erreur)
```

#### 4. **Git** (pour versionning)
```bash
# macOS (pré-installé)
git --version
```

### 📋 Comptes Requis

1. **Compte Azure**
   - Azure for Students (crédit gratuit) ou souscription valide
   - Droits **Contributor** sur un Resource Group

2. **Compte GitHub** (pour CI/CD - optionnel)
   - Repository public ou privé
   - Secrets configurés pour GitHub Actions

### ✅ Vérification Rapide

```bash
# Test que tous les outils sont installés
az --version && terraform --version && docker --version && git --version
```

Si toutes les commandes réussissent, vous êtes prêt ! 🎉
## ⚙️ Configuration

### 1️⃣ Cloner le Repository

```bash
git clone https://github.com/Flockyy/brief-terraform.git
cd brief-terraform
```

### 2️⃣ Configurer les Variables Terraform

Créez votre fichier de configuration à partir du template :

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Éditez `terraform/terraform.tfvars` avec vos valeurs :

```hcl
# Azure subscription ID (obtenir avec : az account show --query id -o tsv)
azure_subscription_id = "votre-subscription-id"

# Configuration projet
project_name = "nyctaxi"
environment  = "dev"
location     = "francecentral"  # ⚠️ Obligatoire pour le brief

# Configuration PostgreSQL
postgres_admin_username = "citus"
postgres_admin_password = "VotreMotDePasseSecurise123!"  # ⚠️ Min 8 caractères, pas de @

# Configuration ingestion données
start_date = "2024-01"  # Format YYYY-MM
end_date   = "2024-03"  # 3 mois de données recommandé

# Votre IP publique (optionnel, pour accès PostgreSQL)
# Obtenir avec : curl -4 ifconfig.me
allowed_ip_address = ""  # Ex: "45.81.84.9"
```

### 3️⃣ Initialiser Terraform

```bash
cd terraform
terraform init
```

**Sortie attendue** :
```
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/azurerm v4.57.0...
- Installing hashicorp/random v3.8.0...

Terraform has been successfully initialized!
```

### 4️⃣ Valider la Configuration

```bash
terraform validate
terraform fmt -check
```

Si tout est correct, passez au déploiement ! 🚀
# Nom du projet
project_name = "nyctaxi"

# Environnement
environment = "dev"

# Région Azure (obligatoire: francecentral)
location = "francecentral"

# Tags
tags = {
  Project     = "NYC Taxi Pipeline"
  ManagedBy   = "Terraform"
  Environment = "dev"
  Owner       = "VotreNom"
}

# Configuration des pipelines
start_date = "2025-01"  # Date de début (YYYY-MM)
end_date   = "2025-02"  # Date de fin (YYYY-MM)

# Cosmos DB
cosmos_db_admin_username = "taxiadmin"
# cosmos_db_admin_password = null  # Généré automatiquement si null

# Container Apps
container_apps_cpu         = 0.5
container_apps_memory      = "1Gi"
container_apps_min_replicas = 0
container_apps_max_replicas = 1
```

### 2. Initialiser Terraform

```bash
cd terraform
terraform init
```

### 3. Valider la configuration

```bash
terraform validate
terraform plan
```

## 📦 Déploiement

### Étape 1 : Planifier le Déploiement

Vérifiez les ressources qui seront créées :

```bash
cd terraform
terraform plan
```

**💡 Conseil** : Examinez attentivement le plan pour comprendre ce qui va être créé.

Vous devriez voir **11 ressources** à créer :
- 1x random_string (suffixe unique)
- 1x storage_account + 2x storage_container
- 1x container_registry
- 1x cosmosdb_postgresql_cluster + 2x firewall_rule
- 1x log_analytics_workspace
- 1x container_app_environment
- 1x container_app

### Étape 2 : Construire l'Image Docker

Avant de déployer, construisez l'image Docker **pour AMD64** (pas ARM64) :

```bash
# Retour à la racine du projet
cd ..

# Build multi-platform pour Azure (AMD64)
docker buildx build --platform linux/amd64 -t nyc-taxi-pipeline:latest --load .
```

**⏱️ Durée** : ~1-2 minutes

**Sortie attendue** :
```
[+] Building 12.9s (23/23) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 797B
 => [internal] load .dockerignore
 ...
 => => naming to docker.io/library/nyc-taxi-pipeline:latest
```

### Étape 3 : Déployer l'Infrastructure

Déployez toutes les ressources Azure :

```bash
cd terraform
terraform apply
```

Tapez `yes` quand demandé.

**⏱️ Durée** : ~12-15 minutes (Cosmos DB prend ~11 minutes)

**📊 Progression** :
```
Terraform will perform the following actions:
  + create 11 resources

azurerm_log_analytics_workspace.main: Creating... [44s]
azurerm_container_registry.main: Creating... [23s]
azurerm_storage_account.main: Creating... [1m3s]
azurerm_cosmosdb_postgresql_cluster.main: Creating... [10m50s] ⏳ Long!
azurerm_container_app_environment.main: Creating... [48s]
azurerm_container_app.pipeline: Creating... [17s]

Apply complete! Resources: 11 added, 0 changed, 0 destroyed.
```

### Étape 4 : Récupérer les Informations de Déploiement

```bash
# Afficher tous les outputs
terraform output

# Récupérer l'URL ACR
terraform output -raw container_registry_login_server

# Récupérer le nom du Container App
terraform output -raw container_app_name
```

**Exemple d'outputs** :
```
container_registry_login_server = "acrnyctaxiw2t94joh.azurecr.io"
## 🔍 Utilisation

### Consulter les Logs du Pipeline

Le Container App s'exécute automatiquement au démarrage. Consultez les logs :

```bash
# Obtenir le nom du Container App
CONTAINER_APP_NAME=$(cd terraform && terraform output -raw container_app_name)
RESOURCE_GROUP="fabgrallRG"

# Afficher les logs en temps réel
az containerapp logs show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --follow

# Afficher les 50 dernières lignes
az containerapp logs show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --tail 50
```

**📊 Logs attendus** :
```
10:38:10 | INFO | 3 fichiers à télécharger
10:38:10 | INFO | Mode Azure activé
10:38:10 | INFO | Téléchargement de yellow_tripdata_2024-01.parquet...
10:38:12 | SUCCESS | Fichier téléchargé avec succès (47.65 MB)
10:38:14 | SUCCESS | Fichier uploadé vers Azure : raw/yellow_tripdata_2024-01.parquet
10:38:14 | INFO | Téléchargement de yellow_tripdata_2024-02.parquet...
10:38:16 | SUCCESS | Fichier téléchargé avec succès (48.02 MB)
10:38:18 | SUCCESS | Fichier uploadé vers Azure : raw/yellow_tripdata_2024-02.parquet
10:38:18 | INFO | Téléchargement de yellow_tripdata_2024-03.parquet...
10:38:20 | SUCCESS | Fichier téléchargé avec succès (57.30 MB)
10:38:23 | SUCCESS | Fichier uploadé vers Azure : raw/yellow_tripdata_2024-03.parquet
✅ Pipeline 1 (Download) terminé
```

### Vérifier les Fichiers dans le Storage

```bash
STORAGE_ACCOUNT=$(cd terraform && terraform output -raw storage_account_name)

# Lister les fichiers dans le container raw
az storage blob list \
  --container-name raw \
  --account-name $STORAGE_ACCOUNT \
  --output table \
  --auth-mode key \
  --account-key $(cd terraform && terraform output -raw storage_account_key)
```

**Sortie attendue** :
```
Name                             Blob Type    Length    Last Modified
yellow_tripdata_2024-01.parquet  BlockBlob    49961641  2026-01-16T10:38:31+00:00
yellow_tripdata_2024-02.parquet  BlockBlob    50349284  2026-01-16T10:38:33+00:00
yellow_tripdata_2024-03.parquet  BlockBlob    60078280  2026-01-16T10:38:36+00:00
```

### Se Connecter à PostgreSQL

```bash
POSTGRES_HOST=$(cd terraform && terraform output -raw postgres_host)
POSTGRES_PASSWORD="VotreMotDePasseSecurise123!"  # Votre mot de passe

# Connexion avec psql
psql "postgresql://citus:$POSTGRES_PASSWORD@$POSTGRES_HOST:5432/citus?sslmode=require"

# Si psql n'est pas installé, installez-le :
# brew install libpq
# brew link --force libpq
```

**Requêtes SQL utiles** :
```sql
-- Lister les tables
\dt

-- Compter les enregistrements dans staging
SELECT COUNT(*) FROM staging_taxi_trips;

-- Vérifier les dimensions
SELECT COUNT(*) FROM dim_datetime;
SELECT COUNT(*) FROM dim_location;
SELECT COUNT(*) FROM dim_payment;
SELECT COUNT(*) FROM dim_vendor;

-- Requête sur la table de faits
SELECT 
    COUNT(*) as total_trips,
    SUM(trip_distance) as total_distance,
    AVG(fare_amount) as avg_fare
FROM fact_trips;
```

### Redémarrer le Pipeline

Si vous souhaitez réexécuter le pipeline :

```bash
# Via Azure CLI
az containerapp revision restart \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP
```
storage_account_name = "stnyctaxiw2t94joh"
container_app_name = "ca-nyctaxi-pipeline-dev"
```

### Étape 5 : Pousser l'Image Docker vers ACR

Maintenant que l'ACR est créé, poussez votre image :

```bash
# Retour à la racine
cd ..

# Se connecter à ACR
ACR_NAME=$(cd terraform && terraform output -raw container_registry_name)
az acr login --name $ACR_NAME

# Récupérer l'URL ACR
ACR_URL=$(cd terraform && terraform output -raw container_registry_login_server)

# Taguer l'image
docker tag nyc-taxi-pipeline:latest $ACR_URL/nyc-taxi-pipeline:latest

# Pousser vers ACR
docker push $ACR_URL/nyc-taxi-pipeline:latest
```

**Sortie attendue** :
```
Login Succeeded
The push refers to repository [acrnyctaxiw2t94joh.azurecr.io/nyc-taxi-pipeline]
...
latest: digest: sha256:fed289d61de5db3b... size: 2618
```

### Étape 6 : Vérifier le Déploiement

Vérifiez que toutes les ressources sont déployées :

```bash
# Lister toutes les ressources
az resource list --resource-group fabgrallRG --output table

# Vérifier l'image dans ACR
az acr repository list --name $ACR_NAME

# Vérifier le Container App
az containerapp list --resource-group fabgrallRG --output table
```

✅ **Déploiement complet !** L'infrastructure est maintenant opérationnelle.

### Étape 2 : Build et Push de l'image Docker

```bash
# Récupérer le nom de l'ACR
ACR_NAME=$(terraform output -raw acr_name)
ACR_URL=$(terraform output -raw acr_login_server)

# Se connecter à ACR
az acr login --name $ACR_NAME

# Revenir à la racine du projet
cd ..

# Builder l'image Docker
docker build -t nyc-taxi-pipeline:latest .

# Tagger l'image pour ACR
docker tag nyc-taxi-pipeline:latest $ACR_URL/nyc-taxi-pipeline:latest

# Pousser vers ACR
docker push $ACR_URL/nyc-taxi-pipeline:latest

# Vérifier que l'image est bien dans ACR
az acr repository show-tags --name $ACR_NAME --repository nyc-taxi-pipeline
```

### Étape 3 : Déployer l'infrastructure complète

```bash
# Revenir dans terraform/
cd terraform

# Déployer toute l'infrastructure
terraform apply
```

**⏱️ Durée estimée** : 5-10 minutes (Cosmos DB prend du temps à provisionner)

### Étape 4 : Vérifier le déploiement

```bash
# Lister toutes les ressources créées
az resource list --resource-group rg-nyctaxi-dev --output table

# Vérifier le Container App
az containerapp list --resource-group rg-nyctaxi-dev --output table
```

## 📊 Utilisation

### Voir les logs du pipeline

```bash
# Suivre les logs en temps réel
az containerapp logs show \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group rg-nyctaxi-dev \
  --follow

# Voir les derniers logs
az containerapp logs show \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group rg-nyctaxi-dev \
  --tail 100
```

### Se connecter à la base de données

```bash
# Récupérer la connection string
terraform output cosmos_db_connection_string

# Se connecter avec psql (si votre IP est autorisée)
psql "postgresql://taxiadmin:PASSWORD@cosmos-nyctaxi-dev-XXXXX.postgres.cosmos.azure.com:5432/citus?sslmode=require"
```

### Requêtes SQL pour vérifier les données

```sql
-- Vérifier la table staging
SELECT COUNT(*) FROM staging_taxi_trips;

-- Vérifier les tables de dimensions
SELECT COUNT(*) FROM dim_datetime;
SELECT COUNT(*) FROM dim_location;
SELECT COUNT(*) FROM dim_payment;
SELECT COUNT(*) FROM dim_vendor;

-- Vérifier la table de faits
SELECT COUNT(*) FROM fact_trips;

-- Exemple : Revenus par jour de la semaine
SELECT
    d.jour_semaine_nom,
    COUNT(*) as nombre_courses,
    AVG(f.montant_total) as revenu_moyen
FROM fact_trips f
JOIN dim_datetime d ON f.pickup_datetime_key = d.datetime_key
GROUP BY d.jour_semaine_nom
ORDER BY nombre_courses DESC;
```

## 🔧 Troubleshooting

Ce projet étant réalisé dans un environnement de formation, plusieurs problèmes ont été rencontrés. Voici les solutions documentées :

### 1. ❌ Erreur : Service Principal Permissions Insuffisantes

**Problème** :
```
AuthorizationFailed: The client 'xxx@domain.com' with object id 'xxx' does not have 
authorization to perform action 'Microsoft.Authorization/roleAssignments/write' over scope 
'/subscriptions/5e2150ec-ee17-4fa2-8714-825c2fb7d22a'
```

**Contexte** : Tentative de création automatique d'un Service Principal pour GitHub Actions dans un environnement de formation.

**Solution** :
1. **Option A** : Demander au formateur de créer le Service Principal
   ```bash
   az ad sp create-for-rbac \
     --name "sp-nyctaxi-cicd" \
     --role contributor \
     --scopes /subscriptions/5e2150ec-ee17-4fa2-8714-825c2fb7d22a \
     --sdk-auth
   ```
   
2. **Option B** : Utiliser les workflows CI/CD avec des secrets manuels (voir `.github/workflows/README.md`)

3. **Option C** : Déployer manuellement avec Terraform (ce qui a été fait pour ce projet)

**Leçon** : Les environnements de formation ont souvent des restrictions IAM. Toujours vérifier les permissions avant d'implémenter des pipelines automatisés.

---

### 2. ❌ Erreur : Architecture Docker Incompatible

**Problème** :
```
Error: creating Container App: containerappsjob.ContainerAppsAPIClient#CreateOrUpdate: 
Failure responding to request: StatusCode=400
Code="InvalidTemplateDeployment"
Message="The image OS/Arch must be 'linux/amd64' but found 'linux/arm64'"
```

**Contexte** : Build Docker sur MacBook avec processeur Apple Silicon (ARM64), mais Azure Container Apps nécessite AMD64.

**Solution** :
```bash
# Build multi-plateforme avec BuildX
docker buildx build \
  --platform linux/amd64 \
  --tag ${ACR_NAME}.azurecr.io/nyc-taxi-pipeline:latest \
  --load \
  .

# Pousser vers ACR
docker push ${ACR_NAME}.azurecr.io/nyc-taxi-pipeline:latest
```

**Vérification** :
```bash
# Inspecter l'image
docker inspect ${ACR_NAME}.azurecr.io/nyc-taxi-pipeline:latest | grep -i arch
# Doit afficher: "Architecture": "amd64"
```

**Leçon** : Toujours builder les images Docker pour l'architecture de destination. Azure Container Apps requiert `linux/amd64`.

---

### 3. ❌ Erreur : PostgreSQL Connection String Parsing

**Problème** :
```
ERROR | 10:38:40 | Erreur Pipeline 2: Connection string is invalid or not a URI
could not translate host name "ss@c-cosmos-nyctaxi-dev.j3gmskci73hpbt.postgres.cosmos.azure.com" 
to address: nodename nor servname provided, or not known
```

**Contexte** : Le mot de passe PostgreSQL contient le caractère `@` qui casse le parsing de l'URL de connexion.

**Mot de passe problématique** : `NycTaxi2026!SecureP@ss`

**Solution 1 - URL Encoding** (recommandé) :
```python
# Dans utils/database.py
from urllib.parse import quote_plus

password_encoded = quote_plus(os.getenv("POSTGRES_PASSWORD"))
connection_string = (
    f"postgresql://citus:{password_encoded}@"
    f"{os.getenv('POSTGRES_HOST')}:5432/citus?sslmode=require"
)
```

**Solution 2 - Changer le mot de passe** (éviter les caractères spéciaux) :
```hcl
# Dans terraform/terraform.tfvars
postgres_admin_password = "NycTaxi2026SecurePass"  # Sans @
```

**Solution 3 - Utiliser psycopg2 directement** :
```python
import psycopg2
conn = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST"),
    port=5432,
    user="citus",
    password=os.getenv("POSTGRES_PASSWORD"),  # Pas de parsing URL
    dbname="citus",
    sslmode="require"
)
```

**Leçon** : Éviter les caractères spéciaux (`@`, `:`, `/`, `?`) dans les mots de passe utilisés dans des URIs de connexion, ou utiliser l'URL encoding.

---

### 4. ❌ Erreur : Container App Already Exists

**Problème** :
```
Error: A resource with the ID "/subscriptions/.../resourceGroups/fabgrallRG/providers/
Microsoft.App/containerApps/ca-nyctaxi-pipeline-dev" already exists
```

**Contexte** : Après un déploiement échoué, le Container App existe dans Azure mais pas dans le state Terraform.

**Solution** :
```bash
# Option A : Importer la ressource existante
cd terraform
terraform import azurerm_container_app.pipeline \
  /subscriptions/5e2150ec-ee17-4fa2-8714-825c2fb7d22a/resourceGroups/fabgrallRG/providers/Microsoft.App/containerApps/ca-nyctaxi-pipeline-dev

# Option B : Supprimer et recréer
az containerapp delete \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --yes

terraform apply
```

**Leçon** : En cas d'échec de déploiement Terraform, vérifier l'état réel des ressources Azure avant de réessayer. Préférer l'import Terraform à la suppression manuelle.

---

### 5. ⚠️ Warning : Microsoft.App Provider Non Enregistré

**Problème** :
```
Error: checking for presence of existing Container Apps Managed Environment: 
the Resource Provider "Microsoft.App" is not registered in Subscription "5e2150ec..."
```

**Solution** :
```bash
# Enregistrer le provider
az provider register --namespace Microsoft.App

# Vérifier l'enregistrement (peut prendre 2-5 minutes)
az provider show --namespace Microsoft.App --query "registrationState"
# Doit retourner: "Registered"

# Attendre que le statut soit "Registered"
az provider show --namespace Microsoft.App --query "registrationState" --output tsv
```

**Puis décommenter dans `terraform/container_apps.tf`** :
```bash
# Relancer le plan Terraform
cd terraform
terraform plan
terraform apply
```

**Leçon** : Toujours vérifier que les Resource Providers Azure nécessaires sont enregistrés avant de déployer des ressources.

---

### 6. 🐛 Diagnostic : Logs Vides ou Incomplets

**Problème** : Le Container App tourne mais aucun log n'apparaît.

**Solution** :
```bash
# Vérifier le statut du Container App
az containerapp show \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --query "properties.runningStatus"

# Vérifier les revisions
az containerapp revision list \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --output table

# Consulter Log Analytics directement
az monitor log-analytics query \
  --workspace $(cd terraform && terraform output -raw log_analytics_workspace_id) \
  --analytics-query "ContainerAppConsoleLogs_CL | order by TimeGenerated desc | limit 100"
```

---

### 7. ❌ Erreur : "MANIFEST_UNKNOWN" dans ACR

**Problème** :
```
Error: MANIFEST_UNKNOWN: manifest tagged by 'latest' is not found
```

**Cause** : L'image Docker n'a pas été poussée vers ACR avant `terraform apply`.

**Solution** :
```bash
# Vérifier les images dans ACR
az acr repository list --name $ACR_NAME

# Pusher l'image si manquante
docker push ${ACR_URL}/nyc-taxi-pipeline:latest

# Réessayer le déploiement
terraform apply
```

---

### 8. 💰 Coûts Inattendus

**Problème** : Les ressources Azure génèrent des coûts même quand inutilisées.

**Solution** :
```bash
# Arrêter le Container App (min_replicas=0)
az containerapp update \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --min-replicas 0 \
  --max-replicas 0

# Ou détruire complètement l'infrastructure
cd terraform
terraform destroy --auto-approve
```

**Configuration optimale** (déjà dans `container_apps.tf`) :
```hcl
scale {
  min_replicas = 0  # Pas de coût quand inactif
  max_replicas = 1
}
```

**Leçon** : Utiliser `min_replicas=0` pour les workloads job-like qui s'exécutent ponctuellement. Toujours détruire les ressources de dev/test après utilisation.

---

### 📚 Ressources Utiles pour le Troubleshooting

- [Azure Container Apps Documentation](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Terraform Azure Provider Issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)
- [DuckDB PostgreSQL Extension](https://duckdb.org/docs/extensions/postgres)
- [Azure Cosmos DB for PostgreSQL Docs](https://learn.microsoft.com/en-us/azure/cosmos-db/postgresql/)

## 💰 Gestion des Coûts

### 💸 Estimation des Coûts Mensuels

| Service | Configuration | Coût mensuel estimé | Notes |
|---------|--------------|---------------------|-------|
| **Storage Account** | LRS, <1GB de données | ~0.02€/mois | Négligeable |
| **Container Registry** | Basic tier | ~5€/mois | Fixe |
| **Container Apps** | 0.5 vCPU, 1Gi RAM, min_replicas=0 | ~0.01€/s actif | Facturé à la seconde |
| **Cosmos DB for PostgreSQL** | 1 vCore Burstable | ~50-70€/mois | Coût principal |
| **Log Analytics** | <5GB/mois | Gratuit | Inclus dans l'offre |
| **Réseau** | Transfert de données | <1€/mois | Minimal pour ce projet |

**💡 Total estimé** : **~60-80€/mois** si actif 24/7

**⚠️ Attention** : Le coût principal provient du **Cosmos DB for PostgreSQL** qui est facturé à l'heure, même quand la base est inactive.

### 🎯 Stratégies d'Optimisation des Coûts

#### Stratégie 1 : Destruction Quotidienne (Recommandée pour Dev)

```bash
# En fin de journée
cd terraform
terraform destroy --auto-approve

# Le lendemain matin
terraform apply --auto-approve
```

**✅ Économie** : ~70% des coûts (Cosmos DB facturé uniquement durant les heures actives)  
**⏱️ Temps** : 10-12 minutes pour `terraform apply`

#### Stratégie 2 : Weekend Automation avec Cron

```bash
# Ajouter dans crontab (crontab -e)
# Détruire le vendredi soir à 20h
0 20 * * 5 cd /chemin/vers/brief-terraform/terraform && terraform destroy --auto-approve

# Recréer le lundi matin à 8h
0 8 * * 1 cd /chemin/vers/brief-terraform/terraform && terraform apply --auto-approve
```

**✅ Économie** : ~30% des coûts (pas de facturation durant les weekends)

#### Stratégie 3 : Alertes Budget Azure

```bash
# Créer une alerte budget via Azure CLI
az consumption budget create \
  --resource-group fabgrallRG \
  --budget-name "brief-terraform-budget" \
  --amount 50 \
  --time-grain Monthly \
  --time-period "$(date +%Y-%m-01)" to "$(date -d '+1 month' +%Y-%m-01)"
```

Ou via le portail Azure :
1. **Azure Portal** → **Cost Management + Billing**
2. **Budgets** → **+ Add**
3. Définir limite : **50€/mois**
4. Configurer alerte email à **80%** et **100%**

### 📊 Monitoring des Coûts en Temps Réel

```bash
# Voir les coûts actuels du Resource Group
az consumption usage list \
  --start-date $(date -d '30 days ago' +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d) \
  | jq '[.[] | select(.name.value | contains("fabgrallRG"))] | map(.usageEnd + " - " + .name.value + ": " + (.pretaxCost | tostring))'

# Ou via le portail Azure
# Azure Portal → Cost Management → Cost Analysis → Filter: fabgrallRG
```

### 🛑 Arrêt d'Urgence (Sans Destruction)

Si vous voulez garder les données mais arrêter la facturation :

```bash
# Arrêter le Container App (ne facture plus)
az containerapp update \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --min-replicas 0 \
  --max-replicas 0

# Note : Cosmos DB continue de facturer même arrêté
# Seule solution : terraform destroy
```

---

## 🧹 Nettoyage de l'Infrastructure

### Option 1 : Destruction Complète (Recommandée)

```bash
cd terraform

# Détruire toutes les ressources
terraform destroy

# Confirmer avec 'yes' quand demandé
```

**⏱️ Durée** : ~5-7 minutes

**📋 Sortie attendue** :
```
Plan: 0 to add, 0 to change, 11 to destroy.

azurerm_container_app.pipeline: Destroying... [5s]
azurerm_container_app_environment.main: Destroying... [45s]
azurerm_cosmosdb_postgresql_cluster.main: Destroying... [3m12s] ⏳
azurerm_container_registry.main: Destroying... [18s]
azurerm_storage_account.main: Destroying... [21s]
azurerm_log_analytics_workspace.main: Destroying... [9s]

Destroy complete! Resources: 11 destroyed.
```

### Option 2 : Destruction Ciblée (Garder Certaines Ressources)

Si vous voulez garder le Storage Account avec les données :

```bash
# Retirer le Storage Account du state Terraform (ne sera plus géré)
terraform state rm azurerm_storage_account.main

# Puis détruire le reste
terraform destroy
```

### Option 3 : Destruction Auto-Approuvée (Sans Confirmation)

```bash
# Utile pour scripts/automation
terraform destroy --auto-approve
```

⚠️ **Attention** : Cette commande ne demande pas de confirmation !

### Vérification Post-Destruction

```bash
# Vérifier qu'il ne reste aucune ressource
az resource list --resource-group fabgrallRG --output table

# Si la commande retourne des ressources, les supprimer manuellement
az group delete --name fabgrallRG --yes --no-wait
```

**Sortie attendue** (aucune ressource) :
```
Name    ResourceGroup    Location    Type    Status
------  ---------------  ----------  ------  --------
(vide)
```

### Nettoyage Local

```bash
# Supprimer le state Terraform local (si backend non distant)
cd terraform
rm -f terraform.tfstate terraform.tfstate.backup

# Supprimer les fichiers de lock
rm -f .terraform.lock.hcl

# Supprimer les providers téléchargés
rm -rf .terraform/

# Supprimer les images Docker locales
docker rmi nyc-taxi-pipeline:latest
docker rmi acrnyctaxiw2t94joh.azurecr.io/nyc-taxi-pipeline:latest

# Nettoyer les images Docker inutilisées
docker system prune -a
```

### Vérification de la Reproductibilité

Pour s'assurer que le projet est bien reproductible :

```bash
# 1. Détruire complètement
terraform destroy --auto-approve

# 2. Nettoyer l'état local
rm -f terraform.tfstate* .terraform.lock.hcl
rm -rf .terraform/

# 3. Réinitialiser Terraform
terraform init

# 4. Recréer l'infrastructure
terraform apply --auto-approve

# 5. Vérifier que tout fonctionne
az containerapp logs show \
  --name ca-nyctaxi-pipeline-dev \
  --resource-group fabgrallRG \
  --tail 100
```

**✅ Succès** si vous voyez les logs du pipeline s'exécuter correctement après la recréation.

---

## 📸 Captures d'Écran

> **Note** : Ajoutez ici des captures d'écran de votre déploiement Azure pour documentation

### Vue d'Ensemble des Ressources

![Azure Resources Overview](docs/screenshots/azure-resources-overview.png)

**À capturer** :
- Azure Portal → Resource Group `fabgrallRG`
- Liste des 11 ressources déployées avec leur statut

### Container Registry

![Azure Container Registry](docs/screenshots/acr-repositories.png)

**À capturer** :
- Azure Portal → Container Registry `acrnyctaxiw2t94joh`
- Onglet **Repositories** montrant l'image `nyc-taxi-pipeline:latest`
- Tag et digest de l'image

### Storage Account - Fichiers Parquet

![Azure Storage Blobs](docs/screenshots/storage-raw-container.png)

**À capturer** :
- Azure Portal → Storage Account → Containers → `raw`
- Les 3 fichiers Parquet téléchargés :
  - `yellow_tripdata_2024-01.parquet` (~50MB)
  - `yellow_tripdata_2024-02.parquet` (~50MB)
  - `yellow_tripdata_2024-03.parquet` (~60MB)

### Container App - Logs d'Exécution

![Container App Logs](docs/screenshots/container-app-logs.png)

**À capturer** :
- Azure Portal → Container Apps → `ca-nyctaxi-pipeline-dev`
- Onglet **Log stream** ou **Console logs**
- Logs montrant l'exécution du Pipeline 1 (Download) avec succès

### Cosmos DB for PostgreSQL

![Cosmos DB Cluster](docs/screenshots/cosmos-db-overview.png)

**À capturer** :
- Azure Portal → Cosmos DB for PostgreSQL → `cosmos-nyctaxi-dev`
- Configuration : 1 vCore, BurstableMemoryOptimized
- Connection string hostname

### Log Analytics Workspace

![Log Analytics Queries](docs/screenshots/log-analytics-queries.png)

**À capturer** :
- Azure Portal → Log Analytics → Logs
- Requête KQL sur `ContainerAppConsoleLogs_CL`
- Résultats montrant les logs du pipeline

### Terraform Apply - Sortie Complète

![Terraform Apply Output](docs/screenshots/terraform-apply-output.png)

**À capturer** :
- Terminal montrant la sortie de `terraform apply`
- Message final : `Apply complete! Resources: 11 added, 0 changed, 0 destroyed.`
- Liste des outputs Terraform

### CI/CD GitHub Actions (Bonus)

![GitHub Actions Workflows](docs/screenshots/github-actions-workflows.png)

**À capturer** :
- GitHub Repository → Actions
- Les 4 workflows créés : CI, Deploy, Destroy, PR Comment
- Statut d'une exécution réussie (si Service Principal configuré)

---

## 🎥 Démonstration Vidéo (Bonus)

Si vous réalisez une vidéo de démonstration, incluez :

1. **Introduction** (30s)
   - Présentation du projet et objectifs
   - Architecture déployée

2. **Configuration Terraform** (1-2 min)
   - Parcourir les fichiers `.tf`
   - Expliquer les variables et outputs

3. **Déploiement** (2-3 min)
   - Exécuter `terraform init`
   - Exécuter `terraform plan`
   - Exécuter `terraform apply`
   - Montrer la création des ressources dans Azure Portal

4. **Vérification** (2-3 min)
   - Voir les logs du Container App
   - Afficher les fichiers dans le Storage Account
   - Se connecter à PostgreSQL (si Load réussi)
   - Requêter les données

5. **Troubleshooting** (1-2 min)
   - Montrer une erreur rencontrée
   - Expliquer la solution appliquée

6. **Nettoyage** (1 min)
   - Exécuter `terraform destroy`
   - Vérifier la suppression des ressources

**🎬 Total** : 8-12 minutes

---

## � Ressources et Documentation

### 📖 Documentation Officielle

#### Terraform
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) - Documentation complète du provider
- [Terraform Language](https://www.terraform.io/language) - Syntaxe HCL et concepts
- [Terraform Best Practices](https://www.terraform-best-practices.com/) - Bonnes pratiques

#### Azure Services
- [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/) - Service de conteneurs serverless
- [Cosmos DB for PostgreSQL](https://learn.microsoft.com/azure/cosmos-db/postgresql/) - Base de données distribuée
- [Azure Container Registry](https://learn.microsoft.com/azure/container-registry/) - Registry privé Docker
- [Azure Storage](https://learn.microsoft.com/azure/storage/) - Blob storage et data lake
- [Log Analytics](https://learn.microsoft.com/azure/azure-monitor/logs/) - Monitoring et logs

#### Outils de Développement
- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/) - Commandes Azure CLI
- [Docker Documentation](https://docs.docker.com/) - Build et déploiement
- [DuckDB](https://duckdb.org/docs/) - Base de données analytique

### 🎓 Tutoriels et Guides

- [Getting Started with Terraform on Azure](https://learn.microsoft.com/azure/developer/terraform/get-started-cloud-shell)
- [Deploy Container Apps with Terraform](https://learn.microsoft.com/azure/container-apps/terraform-deploy)
- [Terraform State Management](https://www.terraform.io/language/state)

### 🐛 Ressources pour le Troubleshooting

- [Azure Status](https://status.azure.com/) - Statut des services Azure
- [Terraform Azure Provider Issues](https://github.com/hashicorp/terraform-provider-azurerm/issues)
- [Stack Overflow - Azure Tag](https://stackoverflow.com/questions/tagged/azure)
- [Reddit r/Terraform](https://www.reddit.com/r/Terraform/)

### 📊 Données NYC Taxi

- [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) - Source officielle
- [Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf) - Description des colonnes

---

## 🎓 Concepts Clés Appris

### Infrastructure as Code (IaC)
✅ Définir l'infrastructure en code déclaratif  
✅ Versioning et collaboration via Git  
✅ Reproductibilité des déploiements  
✅ Gestion du state Terraform

### Azure Cloud Services
✅ Provisionnement de ressources Azure  
✅ Container Apps pour workloads serverless  
✅ Azure Container Registry pour images privées  
✅ Cosmos DB for PostgreSQL distribué  
✅ Monitoring avec Log Analytics

### DevOps & CI/CD
✅ Workflows GitHub Actions  
✅ Automatisation des déploiements  
✅ Service Principal pour authentification  
✅ Secrets management

### Data Engineering
✅ ETL Pipeline (Extract, Transform, Load)  
✅ Modélisation en étoile (Star Schema)  
✅ Optimisation des requêtes analytiques  
✅ DuckDB pour traitement de données

### Docker & Conteneurisation
✅ Multi-stage builds pour optimisation  
✅ Multi-platform builds (ARM64 vs AMD64)  
✅ Registry privé et versioning d'images  
✅ Configuration via variables d'environnement

---

## 🎯 Améliorations Possibles

### Niveau 1 : Fondamentaux
- [ ] **Backend Terraform distant** : Stocker le state dans Azure Storage avec locking
- [ ] **Environnements multiples** : Dev, Staging, Production avec workspaces
- [ ] **Variables validation** : Ajouter des contraintes de validation Terraform
- [ ] **Pre-commit hooks** : Valider le code Terraform avant commit

### Niveau 2 : Sécurité & Qualité
- [ ] **Azure Key Vault** : Stocker les secrets (passwords, connection strings)
- [ ] **Managed Identity** : Remplacer les credentials par identités gérées
- [ ] **Network Security** : VNet, Private Endpoints, NSG
- [ ] **Terraform modules** : Créer des modules réutilisables
- [ ] **Terratest** : Tests d'infrastructure automatisés
- [ ] **tflint** : Linting du code Terraform

### Niveau 3 : Production Ready
- [ ] **High Availability** : Multi-region deployment
- [ ] **Disaster Recovery** : Backup automatique et restauration
- [ ] **Monitoring avancé** : Application Insights, alertes proactives
- [ ] **Cost Management** : Tags, budgets, auto-scaling optimisé
- [ ] **GitOps** : ArgoCD ou Flux pour déploiement continu
- [ ] **Infrastructure Testing** : Tests de bout en bout dans pipeline

### Niveau 4 : Data Engineering
- [ ] **Apache Airflow** : Orchestration des pipelines
- [ ] **Data Quality** : Great Expectations pour validation
- [ ] **Incremental Loads** : Charger uniquement les nouvelles données
- [ ] **dbt (Data Build Tool)** : Transformations SQL versionnées
- [ ] **Data Catalog** : Documentation automatique du schéma
- [ ] **BI Dashboard** : Power BI ou Looker pour visualisation

---

## 📝 Notes Techniques

### Choix Architecturaux

#### Pourquoi Container Apps ?
- **Serverless** : Facturation à la seconde, pas de gestion de cluster
- **Scale to Zero** : `min_replicas=0` pour optimiser les coûts
- **Intégration native** : Log Analytics, ACR, secrets management
- **Job-like workload** : Parfait pour pipelines ponctuels

#### Pourquoi Cosmos DB for PostgreSQL ?
- **Compatible PostgreSQL** : Code SQL standard, extensions disponibles
- **Distribué** : Préparé pour scale horizontal si besoin
- **Managed** : Backup, HA, patching automatiques
- **Burstable tier** : Coût optimisé pour dev/test

#### Pourquoi DuckDB ?
- **Analytique** : Optimisé pour OLAP, pas OLTP
- **Parquet natif** : Lecture performante des fichiers columnar
- **In-memory** : Traitement rapide pour volumes modérés
- **Léger** : Pas de serveur séparé à gérer

### Tables Créées dans PostgreSQL

#### Tables de Staging
```sql
CREATE TABLE staging_taxi_trips (
    id SERIAL PRIMARY KEY,
    vendorid INTEGER,
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    passenger_count INTEGER,
    trip_distance FLOAT,
    ratecodeid INTEGER,
    store_and_fwd_flag VARCHAR(1),
    pulocationid INTEGER,
    dolocationid INTEGER,
    payment_type INTEGER,
    fare_amount FLOAT,
    extra FLOAT,
    mta_tax FLOAT,
    tip_amount FLOAT,
    tolls_amount FLOAT,
    improvement_surcharge FLOAT,
    total_amount FLOAT,
    congestion_surcharge FLOAT,
    airport_fee FLOAT
);
```

#### Tables de Dimensions
```sql
-- Dimension temporelle
CREATE TABLE dim_datetime (
    datetime_key INTEGER PRIMARY KEY,
    date_complete TIMESTAMP,
    annee INTEGER,
    mois INTEGER,
    jour INTEGER,
    heure INTEGER,
    jour_semaine INTEGER,
    jour_semaine_nom VARCHAR(20),
    mois_nom VARCHAR(20),
    trimestre INTEGER
);

-- Dimension géographique
CREATE TABLE dim_location (
    location_key INTEGER PRIMARY KEY,
    location_id INTEGER,
    zone_name VARCHAR(255)
);

-- Dimension paiement
CREATE TABLE dim_payment (
    payment_key INTEGER PRIMARY KEY,
    payment_type_id INTEGER,
    payment_type_name VARCHAR(50)
);

-- Dimension fournisseur
CREATE TABLE dim_vendor (
    vendor_key INTEGER PRIMARY KEY,
    vendor_id INTEGER,
    vendor_name VARCHAR(100)
);
```

#### Table de Faits
```sql
CREATE TABLE fact_trips (
    trip_key SERIAL PRIMARY KEY,
    pickup_datetime_key INTEGER REFERENCES dim_datetime(datetime_key),
    dropoff_datetime_key INTEGER REFERENCES dim_datetime(datetime_key),
    pickup_location_key INTEGER REFERENCES dim_location(location_key),
    dropoff_location_key INTEGER REFERENCES dim_location(location_key),
    payment_key INTEGER REFERENCES dim_payment(payment_key),
    vendor_key INTEGER REFERENCES dim_vendor(vendor_key),
    nombre_passagers INTEGER,
    distance_trajet FLOAT,
    duree_trajet_minutes FLOAT,
    montant_course FLOAT,
    montant_extra FLOAT,
    montant_pourboire FLOAT,
    montant_peage FLOAT,
    montant_total FLOAT
);
```

### Requêtes Analytiques Exemples

```sql
-- Top 10 des zones les plus lucratives
SELECT 
    l.zone_name,
    COUNT(*) as nb_courses,
    ROUND(AVG(f.montant_total)::numeric, 2) as revenu_moyen,
    ROUND(SUM(f.montant_total)::numeric, 2) as revenu_total
FROM fact_trips f
JOIN dim_location l ON f.pickup_location_key = l.location_key
GROUP BY l.zone_name
ORDER BY revenu_total DESC
LIMIT 10;

-- Évolution des revenus par jour de la semaine
SELECT 
    d.jour_semaine_nom,
    COUNT(*) as nb_courses,
    ROUND(AVG(f.montant_total)::numeric, 2) as revenu_moyen
FROM fact_trips f
JOIN dim_datetime d ON f.pickup_datetime_key = d.datetime_key
GROUP BY d.jour_semaine, d.jour_semaine_nom
ORDER BY d.jour_semaine;

-- Analyse des pourboires par type de paiement
SELECT 
    p.payment_type_name,
    COUNT(*) as nb_courses,
    ROUND(AVG(f.montant_pourboire)::numeric, 2) as pourboire_moyen,
    ROUND((AVG(f.montant_pourboire) / NULLIF(AVG(f.montant_course), 0) * 100)::numeric, 2) as pourcentage_pourboire
FROM fact_trips f
JOIN dim_payment p ON f.payment_key = p.payment_key
WHERE f.montant_course > 0
GROUP BY p.payment_type_name
ORDER BY pourboire_moyen DESC;
```

---

## ✅ Checklist Finale

### Avant de Soumettre le Projet

- [ ] **Code Terraform valide** : `terraform validate` passe
- [ ] **Déploiement testé** : `terraform apply` réussit sans erreurs
- [ ] **Logs vérifiés** : Pipeline Download s'exécute correctement
- [ ] **README complet** : Documentation claire et détaillée
- [ ] **Captures d'écran** : Au moins 5 screenshots Azure Portal
- [ ] **Troubleshooting documenté** : Erreurs + solutions expliquées
- [ ] **Reproductibilité** : `terraform destroy` puis `apply` fonctionne
- [ ] **Code commenté** : Fichiers `.tf` ont des commentaires explicatifs
- [ ] **Git propre** : Commits atomiques avec messages clairs
- [ ] **Secrets supprimés** : Pas de mots de passe dans Git
- [ ] **Coûts maîtrisés** : Infrastructure détruite après tests

### Bonus CI/CD (Optionnel)

- [ ] **Workflows créés** : 4 workflows GitHub Actions
- [ ] **Documentation workflows** : `.github/workflows/README.md` complet
- [ ] **Service Principal** : Demande formateur documentée
- [ ] **Secrets configurés** : GitHub secrets expliqués dans doc

### Bonus Vidéo (Optionnel)

- [ ] **Script préparé** : Plan de la démo
- [ ] **Enregistrement** : 8-12 minutes, qualité audio/vidéo correcte
- [ ] **Upload** : YouTube, Loom, ou partage OneDrive
- [ ] **Lien dans README** : Section démo avec lien vidéo

---

## 📄 Licence & Auteur

**Projet** : Brief Terraform - NYC Taxi Data Pipeline  
**Contexte** : Formation DevOps - Infrastructure as Code  
**Technologies** : Terraform, Azure, Docker, Python, PostgreSQL, DuckDB

**Source des données** : [NYC Taxi & Limousine Commission (TLC)](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page)

---

## 🆘 Support & Contact

Pour toute question sur ce projet :

1. **Documentation** : Consultez d'abord ce README et les commentaires dans le code
2. **Troubleshooting** : Voir la section dédiée pour les erreurs courantes
3. **Issues GitHub** : Ouvrir une issue sur le repository
4. **Formateur** : Contacter pour questions Azure/Service Principal

---

**🎉 Merci d'avoir consulté ce projet !**

Si vous avez trouvé ce README utile, n'hésitez pas à ⭐ star le repository !
