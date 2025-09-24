# 5HASH - Infrastructure-as-Code

Ce projet déploie une infrastructure complète sur Azure pour héberger une application PrestaShop avec une base de données dédiée. L'infrastructure est gérée avec **Terraform** et utilise des modules pour organiser le déploiement.

Équipe du Projet
- ** Hamza Belyahiaoui - Développeur Full Stack
- ** Saad Chabba - Développeur Full Stack
- ** Constant Alberola - Développeur Full Stack


## 📋 Architecture

L'infrastructure déployée comprend :
- **Azure Container Instances** : Hébergement de l'application PrestaShop
- **Azure Database for MySQL** : Base de données dédiée
- **Load Balancer Azure** : Répartition de charge
- **Réseau virtuel** : Isolation et sécurité réseau
- **Groupes de ressources** : Organisation logique des ressources

## 📌 Prérequis

Avant de commencer, assure-toi d'avoir :

- **Terraform** installé (version >= 1.0)
- **Compte Azure** avec les droits nécessaires (Contributor ou Owner)
- **Azure CLI** configuré et connecté (`az login`)
- **Accès au dossier du projet** avec les fichiers Terraform

### Vérification de l'installation

```bash
# Vérifier Terraform
terraform --version

# Vérifier Azure CLI
az --version

# Vérifier la connexion Azure
az account show
```

##  Déploiement

Dans le dossier racine du projet, selon l'environnement souhaité :

###  Environnement de Développement (DEV)

```bash
terraform init
terraform plan -var-file="dev/dev.tfvars"
terraform apply -var-file="dev/dev.tfvars"
```

###  Environnement de Staging (STAGING)

```bash
terraform init
terraform plan -var-file="staging/staging.tfvars"
terraform apply -var-file="staging/staging.tfvars"
```

###  Environnement de Production (PROD)

```bash
terraform init
terraform plan -var-file="prod/prod.tfvars"
terraform apply -var-file="prod/prod.tfvars"
```

> ** Conseil** : Utilise toujours `terraform plan` avant `terraform apply` pour prévisualiser les changements.

## 📁 Structure des fichiers

```
.
├── main.tf                 # Configuration principale
├── variables.tf            # Déclaration des variables
├── modules/ 
       ├── database          
       └── prestashgop                
├── dev/
    └──├── dev.tfvars
       ├── main.tf                 # Configuration principale
       ├── output.tf                 # Configuration principale
       └── variables.tf  # Variables pour l'environnement DEV
├── staging/
    └──├── staging.tfvars  
       ├── main.tf                 # Configuration principale
       ├── output.tf                 # Configuration principale
       └── variables.tf  # Variables pour l'environnement DEV
└── prod/
    └──├── prod.tfvars       # Variables pour l'environnement PROD
       ├── main.tf                 # Configuration principale
       ├── output.tf                 # Configuration principale
       └── variables.tf  # Variables pour l'environnement DEV
```

Chaque fichier `.tfvars` contient les variables spécifiques à l'environnement :
- Région Azure
- Nom du groupe de ressources
- Configuration de la base de données
- Paramètres réseau
- Tags et métadonnées

## 🔧 Configuration  back office (Page Admin)

Après le déploiement, PrestaShop nécessite une configuration manuelle pour des raisons de sécurité.

### 1. Connexion au conteneur

#### Via le Portail Azure :
1. Accède au **groupe de conteneurs** dans le portail Azure
2. Clique sur le **conteneur PrestaShop**
3. Sélectionne **"Connexion"** puis choisis **"Bash"**

#### Via Azure CLI :
```bash
az container exec --resource-group <nom-rg> --name <nom-conteneur> --exec-command "/bin/bash"
```

### 2. Suppression du dossier d'installation

```bash
rm -rf /var/www/html/install
```

### 3. Sécurisation du dossier admin

```bash
# Renommer le dossier admin avec un nom unique
mv /var/www/html/admin /var/www/html/admin13
```

### 4. Accès au back office

Une fois configuré, accède à l'interface d'administration via :

```
http://prestashop-<ton-label-dns>.azurecontainer.io/admin13
```

> **⚠️ Important** : Remplace `<ton-label-dns>` par le nom DNS configuré dans tes variables Terraform.

## 🔒 Considérations de Sécurité

### Pour la Production :
- **Volume persistant** : Monte un Azure File Share pour conserver les données
- **HTTPS** : Configure SSL/TLS avec Azure Application Gateway
- **Sauvegarde** : Active les sauvegardes automatiques de la base de données
- **Monitoring** : Configure Azure Monitor et les alertes


