# Papier.net - Projet DevOps

> Tous vos papiers administratifs au même endroit

Ce projet est conçu pour apprendre le DevOps en 3 jours.

---

## Structure du projet

```
papier-net/
├── app/
│   ├── api/
│   │   ├── server.js        # Backend Node.js
│   │   ├── test.js          # Tests
│   │   └── package.json
│   ├── index.html           # Frontend
│   └── nginx.conf           # Config reverse proxy
├── docker/
│   ├── Dockerfile.api       # Image backend
│   └── Dockerfile.nginx     # Image frontend
├── .github/workflows/
│   ├── ci.yml               # Pipeline CI/CD
│   └── security.yml         # Scan sécurité
├── monitoring/
│   ├── docker-compose.monitoring.yml
│   └── prometheus.yml
├── scripts/
│   ├── deploy-aws.sh
│   └── setup-ec2.sh
└── docker-compose.yml       # Orchestration locale
```

---

## Jour 1 : Docker

### Objectif
Comprendre la conteneurisation et lancer l'app en local.

### Commandes à apprendre

```bash
# Aller dans le projet
cd papier-net

# Construire les images Docker
docker-compose build

# Lancer l'application
docker-compose up

# Lancer en arrière-plan (détaché)
docker-compose up -d

# Voir les conteneurs qui tournent
docker-compose ps

# Voir les logs
docker-compose logs -f

# Arrêter l'application
docker-compose down

# Reconstruire sans cache (après modification)
docker-compose build --no-cache
```

### Vérifier que ça marche

1. Ouvre http://localhost dans ton navigateur
2. Tu dois voir l'interface Papier.net
3. L'indicateur "API connectée" doit être vert

### Exercices Jour 1

1. Modifie le message de bienvenue dans `app/index.html`
2. Rebuild et relance : `docker-compose up --build`
3. Ajoute un papier via l'interface
4. Regarde les logs : `docker-compose logs api`

---

## Jour 2 : CI/CD

### Objectif
Automatiser les tests et le déploiement avec GitHub Actions.

### Étapes

1. **Créer le repo GitHub**
```bash
cd papier-net
git init
git add .
git commit -m "Initial commit"
gh repo create papier-net --public --source=. --push
```

2. **Voir le pipeline s'exécuter**
   - Va sur GitHub > ton repo > Actions
   - Tu verras le pipeline se lancer automatiquement

3. **Faire un changement et observer**
```bash
# Modifie quelque chose
echo "// test" >> app/api/server.js

# Commit et push
git add .
git commit -m "Test CI/CD"
git push
```
   - Regarde le pipeline se relancer

### Comprendre le fichier ci.yml

| Section | Rôle |
|---------|------|
| `on:` | Quand le pipeline se lance |
| `jobs:` | Les tâches à exécuter |
| `test:` | Lance les tests Node.js |
| `build:` | Construit les images Docker |
| `deploy:` | Déploie sur AWS (après config) |

---

## Jour 3 : AWS + Monitoring

### Partie 1 : Créer l'instance EC2

1. **Connecte-toi à AWS Console**
   - https://console.aws.amazon.com

2. **Créer une instance EC2**
   - Service : EC2
   - Launch Instance
   - Nom : `papier-net`
   - AMI : Amazon Linux 2023 (Free tier)
   - Type : t2.micro (Free tier)
   - Key pair : Créer une nouvelle clé, télécharge le .pem
   - Security Group : autoriser ports 22 (SSH), 80 (HTTP)

3. **Configurer les secrets GitHub**
   - GitHub > Repo > Settings > Secrets > Actions
   - Ajouter :
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`
     - `EC2_HOST` (IP de ton EC2)
     - `EC2_SSH_KEY` (contenu du fichier .pem)

4. **Premier déploiement manuel**
```bash
# Rendre le script exécutable
chmod +x scripts/setup-ec2.sh

# Configurer EC2 (remplace par ton IP)
./scripts/setup-ec2.sh 54.123.45.67 ~/.ssh/papier-net-key.pem
```

### Partie 2 : Monitoring

```bash
# Lancer le stack monitoring
cd monitoring
docker-compose -f docker-compose.monitoring.yml up -d

# Accéder aux interfaces
# Prometheus : http://localhost:9090
# Grafana : http://localhost:3001 (admin / papier123)
```

### Configurer Grafana

1. Connexion : admin / papier123
2. Configuration > Data Sources > Add Prometheus
3. URL : `http://prometheus:9090`
4. Save & Test
5. Dashboards > Import > ID `1860` (Node Exporter dashboard)

---

## Commandes utiles

### Docker
```bash
docker ps                    # Conteneurs actifs
docker images                # Images locales
docker logs <container>      # Logs d'un conteneur
docker exec -it <container> sh  # Shell dans un conteneur
docker system prune -a       # Nettoyer tout
```

### Git
```bash
git status                   # État actuel
git log --oneline           # Historique
git diff                    # Voir les changements
```

### AWS CLI (optionnel)
```bash
aws configure               # Setup credentials
aws ec2 describe-instances  # Lister les EC2
```

---

## Dépannage

### L'API ne répond pas
```bash
docker-compose logs api     # Voir les erreurs
docker-compose restart api  # Redémarrer
```

### Port 80 déjà utilisé
```bash
# Sur Mac, désactiver AirPlay Receiver
# Ou changer le port dans docker-compose.yml : "8080:80"
```

### Permission denied (Docker)
```bash
sudo chmod 666 /var/run/docker.sock  # Linux
# Ou relancer Docker Desktop
```

---

## Ressources pour aller plus loin

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
