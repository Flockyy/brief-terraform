# Pull Request

## 📝 Description

<!-- Décrivez vos changements en quelques phrases -->

## 🎯 Type de Changement

<!-- Cochez les cases appropriées -->

- [ ] 🐛 Bug fix (correction d'un problème)
- [ ] ✨ Nouvelle fonctionnalité
- [ ] 🔧 Modification de configuration
- [ ] 📚 Documentation
- [ ] 🏗️ Changement d'infrastructure (Terraform)
- [ ] 🐳 Modification Docker
- [ ] ⚡ Amélioration des performances

## 🔍 Changements Proposés

<!-- Listez les changements principaux -->

- 
- 
- 

## 🏗️ Impact Infrastructure

<!-- Si applicable, décrivez l'impact sur l'infrastructure Azure -->

- [ ] Pas d'impact sur l'infrastructure
- [ ] Ajout de nouvelles ressources Azure
- [ ] Modification de ressources existantes
- [ ] Suppression de ressources
- [ ] Changement de configuration

**Ressources affectées** :
<!-- Listez les ressources Azure impactées -->

## ✅ Checklist

<!-- Cochez toutes les cases avant de soumettre la PR -->

- [ ] J'ai testé localement ces changements
- [ ] Les workflows CI passent
- [ ] Le code Terraform est formaté (`terraform fmt`)
- [ ] Le code Python respecte le style (Black/Ruff)
- [ ] J'ai mis à jour la documentation si nécessaire
- [ ] J'ai ajouté des commentaires pour le code complexe
- [ ] Les variables sensibles ne sont pas commitées

## 🧪 Tests Effectués

<!-- Décrivez comment vous avez testé vos changements -->

```bash
# Commandes exécutées pour tester
```

**Résultats** :
<!-- Décrivez les résultats des tests -->

## 📸 Captures d'Écran

<!-- Si applicable, ajoutez des captures d'écran -->

## 🔗 Liens Connexes

<!-- Issues, documentation, ou PRs liées -->

- Issue: #
- Documentation: 

## 💬 Notes pour les Reviewers

<!-- Informations supplémentaires pour faciliter la review -->

---

## 🤖 CI/CD

Le workflow CI va automatiquement :
- ✅ Valider le code Terraform
- ✅ Builder l'image Docker
- ✅ Linter le code Python

Le workflow PR Comment va :
- 📝 Générer et poster le Terraform plan

Après merge vers `main`, le workflow CD va :
- 🚀 Déployer automatiquement l'infrastructure
