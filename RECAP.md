# Récap DevOps - Papier.net

## Structure du projet
```
papier-net/
├── app/
│   ├── api/server.js      # Backend Node.js
│   ├── api/test.js        # Tests
│   ├── index.html         # Frontend
│   └── nginx.conf         # Reverse proxy
├── docker/
│   ├── Dockerfile.api     # Image backend
│   └── Dockerfile.nginx   # Image frontend
├── .github/workflows/
│   ├── ci.yml             # Pipeline CI/CD
│   └── security.yml       # Scan sécurité
├── monitoring/
│   ├── docker-compose.monitoring.yml
│   └── prometheus.yml
└── docker-compose.yml     # Orchestration
```

---

## Jour 1 : Docker

```bash
# Lancer l'application
docker-compose up --build

# Lancer en arrière-plan
docker-compose up -d

# Voir les conteneurs
docker-compose ps

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down

# Reconstruire sans cache
docker-compose build --no-cache
```

---

## Jour 2 : CI/CD GitHub

```bash
# Initialiser git
git init
git add .
git commit -m "Initial commit"

# Créer le repo GitHub
gh repo create papier-net --public --source=. --push

# Pousser des modifications
git add .
git commit -m "Message"
git push
```

**Pipeline automatique :**
- Push → Tests → Build Docker → Deploy AWS

---

## Jour 3 : AWS EC2

**Créer l'instance :**
- AMI : Amazon Linux 2023
- Type : t3.micro (Free Tier)
- Key pair : RSA, format .pem
- Security Group : SSH (22) + HTTP (80)

```bash
# Sécuriser la clé SSH
chmod 400 ~/.ssh/papier-net-key.pem

# Se connecter à EC2
ssh -i ~/.ssh/papier-net-key.pem ec2-user@13.38.103.222

# Installer Docker sur EC2
sudo yum update -y
sudo yum install -y docker git
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Cloner et lancer
git clone https://github.com/TON_USERNAME/papier-net.git
cd papier-net
sudo docker-compose up -d --build
```

**Secrets GitHub (Settings → Secrets → Actions) :**
- `EC2_HOST` : IP de l'instance
- `EC2_SSH_KEY` : contenu du fichier .pem
- `AWS_ACCESS_KEY_ID` : depuis IAM
- `AWS_SECRET_ACCESS_KEY` : depuis IAM

---

## Monitoring : Prometheus + Grafana

```bash
# Lancer le monitoring
cd monitoring
docker-compose -f docker-compose.monitoring.yml up -d

# Accès
# Prometheus : http://localhost:9090
# Grafana : http://localhost:3001 (admin / papier123)

# Arrêter le monitoring
docker-compose -f docker-compose.monitoring.yml down
```

**Configurer Grafana :**
1. Connections → Data sources → Add Prometheus
2. URL : `http://prometheus:9090`
3. Save & Test
4. Dashboards → Import → ID `1860` → Load → Import

---

## Commandes utiles

```bash
# Reprendre la conversation Claude
cd /Users/seily/Documents/papier-net
claude --continue

# Tester l'API
curl http://localhost/health
curl http://localhost/api/papiers

# Quitter git diff ou logs
q

# Voir les images Docker
docker images

# Nettoyer Docker
docker system prune -a
```

---

## URLs

- **Local** : http://localhost
- **Production** : http://13.38.103.222
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3001

---

## Concepts appris

| Concept | Outil |
|---------|-------|
| Conteneurisation | Docker |
| Orchestration | Docker Compose |
| CI/CD | GitHub Actions |
| Cloud | AWS EC2 |
| Reverse Proxy | Nginx |
| Monitoring | Prometheus + Grafana |
| Secrets | GitHub Secrets, IAM |
