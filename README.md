# Papier.net - Projet DevOps

> Tous vos papiers administratifs au même endroit

Ce projet est conçu pour apprendre le DevOps rapidement.

## Parcours DevOps

| Jour | Thème | Outils | Statut |
|------|-------|--------|--------|
| 1 | Conteneurisation | Docker, Docker Compose | ✅ Fait |
| 2 | CI/CD | GitHub Actions | ✅ Fait |
| 3 | Cloud + Monitoring | AWS EC2, Prometheus, Grafana | ✅ Fait |
| 4 | Infrastructure as Code | Terraform | ⏳ À faire |
| 5 | Configuration Management | Ansible | ⏳ À faire |
| 6 | CI/CD Avancé | Jenkins | ⏳ À faire |
| 7 | Orchestration | Kubernetes (K8s) | ⏳ À faire |
| 8 | Logging centralisé | ELK Stack (Elasticsearch, Logstash, Kibana) | ⏳ À faire |
| 9 | Sécurité DevSecOps | Vault, Trivy, OWASP | ⏳ À faire |
| 10 | Projet final | Tout assembler | ⏳ À faire |

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

---

## Jour 4 : Terraform (Infrastructure as Code)

### Objectif
Créer et gérer l'infrastructure AWS avec du code au lieu de cliquer dans la console.

### Ce que tu vas apprendre
- Déclarer des ressources cloud en code (EC2, VPC, Security Groups)
- Versionner ton infrastructure avec Git
- Détruire et recréer l'infra en une commande

### Concepts clés
| Concept | Description |
|---------|-------------|
| `provider` | Le cloud cible (AWS, GCP, Azure) |
| `resource` | Une ressource à créer (EC2, S3, etc.) |
| `terraform plan` | Prévisualiser les changements |
| `terraform apply` | Appliquer les changements |
| `terraform destroy` | Tout supprimer |
| `state` | Fichier qui stocke l'état actuel |

### Commandes principales
```bash
# Initialiser Terraform
terraform init

# Voir ce qui va être créé
terraform plan

# Créer l'infrastructure
terraform apply

# Détruire l'infrastructure
terraform destroy
```

---

## Jour 5 : Ansible (Configuration Management)

### Objectif
Configurer automatiquement des serveurs (installer Docker, déployer l'app, etc.)

### Ce que tu vas apprendre
- Écrire des playbooks (scripts de configuration)
- Configurer plusieurs serveurs en parallèle
- Idempotence : relancer sans casser

### Concepts clés
| Concept | Description |
|---------|-------------|
| `inventory` | Liste des serveurs à configurer |
| `playbook` | Script de configuration (YAML) |
| `task` | Une action à effectuer |
| `role` | Groupe de tasks réutilisables |
| `handler` | Action déclenchée par un changement |

### Commandes principales
```bash
# Tester la connexion aux serveurs
ansible all -m ping -i inventory.ini

# Lancer un playbook
ansible-playbook -i inventory.ini playbook.yml

# Mode dry-run (sans appliquer)
ansible-playbook -i inventory.ini playbook.yml --check
```

### Exemple de playbook
```yaml
- name: Configurer le serveur Papier.net
  hosts: webservers
  become: yes
  tasks:
    - name: Installer Docker
      yum:
        name: docker
        state: present

    - name: Démarrer Docker
      service:
        name: docker
        state: started
        enabled: yes
```

---

## Jour 6 : Jenkins (CI/CD Avancé)

### Objectif
Installer et configurer Jenkins, l'outil CI/CD le plus utilisé en entreprise.

### Ce que tu vas apprendre
- Installer Jenkins avec Docker
- Créer des pipelines (Jenkinsfile)
- Intégrer avec GitHub et Docker

### Concepts clés
| Concept | Description |
|---------|-------------|
| `Jenkinsfile` | Pipeline as Code |
| `agent` | Où exécuter le pipeline |
| `stage` | Étape du pipeline |
| `step` | Action dans une étape |
| `Blue Ocean` | Interface moderne de Jenkins |

### Lancer Jenkins
```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

### Exemple de Jenkinsfile
```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t papier-api .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker-compose up -d'
            }
        }
    }
}
```

---

## Jour 7 : Kubernetes (Orchestration)

### Objectif
Déployer l'app sur Kubernetes pour la scalabilité et la haute disponibilité.

### Ce que tu vas apprendre
- Pods, Deployments, Services
- Scaling automatique
- Rolling updates (zero downtime)

### Concepts clés
| Concept | Description |
|---------|-------------|
| `Pod` | Plus petite unité (1+ conteneurs) |
| `Deployment` | Gère les replicas de Pods |
| `Service` | Expose les Pods (load balancing) |
| `Ingress` | Routage HTTP externe |
| `ConfigMap` | Configuration externe |
| `Secret` | Données sensibles |

### Commandes principales
```bash
# Installer minikube (Kubernetes local)
brew install minikube
minikube start

# Commandes kubectl
kubectl get pods                    # Lister les pods
kubectl get services                # Lister les services
kubectl apply -f deployment.yml     # Déployer
kubectl logs <pod-name>             # Voir les logs
kubectl scale deployment api --replicas=3  # Scaler
```

### Exemple de Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: papier-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: papier-api
  template:
    metadata:
      labels:
        app: papier-api
    spec:
      containers:
      - name: api
        image: papier-api:latest
        ports:
        - containerPort: 3000
```

---

## Jour 8 : ELK Stack (Logging centralisé)

### Objectif
Centraliser et analyser les logs de tous les services.

### Ce que tu vas apprendre
- Collecter les logs avec Logstash/Filebeat
- Stocker dans Elasticsearch
- Visualiser avec Kibana

### Concepts clés
| Outil | Rôle |
|-------|------|
| Elasticsearch | Base de données de logs |
| Logstash | Collecte et transforme les logs |
| Kibana | Interface de visualisation |
| Filebeat | Agent léger de collecte |

### Lancer ELK
```bash
# docker-compose.elk.yml à créer
docker-compose -f docker-compose.elk.yml up -d

# Accès
# Kibana : http://localhost:5601
# Elasticsearch : http://localhost:9200
```

---

## Jour 9 : DevSecOps (Sécurité)

### Objectif
Intégrer la sécurité dans le pipeline CI/CD.

### Ce que tu vas apprendre
- Scanner les vulnérabilités des images Docker
- Gérer les secrets avec Vault
- Audit des dépendances

### Outils
| Outil | Rôle |
|-------|------|
| Trivy | Scan de vulnérabilités Docker |
| Vault | Gestion des secrets |
| Snyk | Scan des dépendances |
| OWASP ZAP | Scan de sécurité web |

### Commandes
```bash
# Scanner une image Docker
trivy image papier-api:latest

# Audit npm
npm audit

# Lancer Vault
docker run -d --name vault -p 8200:8200 vault
```

---

## Jour 10 : Projet Final

### Objectif
Assembler tout ce qu'on a appris dans une architecture complète.

### Architecture cible
```
GitHub Push
    ↓
Jenkins/GitHub Actions (CI/CD)
    ↓
Build Docker → Scan Trivy → Tests
    ↓
Terraform (provision infra)
    ↓
Ansible (configure serveurs)
    ↓
Kubernetes (déploie l'app)
    ↓
Prometheus + Grafana (monitoring)
    ↓
ELK Stack (logging)
    ↓
Vault (secrets)
```

### Checklist DevOps
- [ ] Code versionné (Git)
- [ ] Tests automatisés
- [ ] CI/CD pipeline
- [ ] Infrastructure as Code (Terraform)
- [ ] Configuration as Code (Ansible)
- [ ] Conteneurisation (Docker)
- [ ] Orchestration (Kubernetes)
- [ ] Monitoring (Prometheus/Grafana)
- [ ] Logging (ELK)
- [ ] Sécurité (Trivy, Vault)

---

## Ressources pour aller plus loin

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [Terraform](https://developer.hashicorp.com/terraform/docs)
- [Ansible](https://docs.ansible.com/)
- [Jenkins](https://www.jenkins.io/doc/)
- [Kubernetes](https://kubernetes.io/docs/)
- [HashiCorp Vault](https://developer.hashicorp.com/vault/docs)
