#!/bin/bash
#
# ===========================================
# SCRIPT DE DÉPLOIEMENT AWS EC2
# ===========================================
#
# Ce script :
# 1. Se connecte à ton instance EC2
# 2. Clone/met à jour le repo
# 3. Lance l'application avec Docker
#
# Usage : ./scripts/deploy-aws.sh
#
# Prérequis :
# - Avoir une instance EC2 lancée
# - Avoir la clé SSH (.pem)
# - Avoir configuré les variables ci-dessous
#

# === CONFIGURATION ===
# À modifier avec tes valeurs !
EC2_HOST="ton-ip-ec2.amazonaws.com"  # IP ou DNS de ton EC2
EC2_USER="ec2-user"                   # Utilisateur (ec2-user pour Amazon Linux)
SSH_KEY="~/.ssh/papier-net-key.pem"   # Chemin vers ta clé SSH
REPO_URL="https://github.com/ton-username/papier-net.git"

# === COULEURS POUR LE TERMINAL ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Déploiement Papier.net sur AWS ===${NC}"

# Vérifier que la clé SSH existe
if [ ! -f "$SSH_KEY" ]; then
    echo -e "${RED}Erreur: Clé SSH non trouvée: $SSH_KEY${NC}"
    exit 1
fi

echo -e "${GREEN}Connexion à $EC2_HOST...${NC}"

# Commandes à exécuter sur le serveur
ssh -i "$SSH_KEY" "$EC2_USER@$EC2_HOST" << 'ENDSSH'
    echo "=== Mise à jour du système ==="
    sudo yum update -y

    echo "=== Installation de Docker ==="
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    echo "=== Installation de Docker Compose ==="
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "=== Installation de Git ==="
    sudo yum install -y git

    echo "=== Clone/Update du repo ==="
    if [ -d "/home/ec2-user/papier-net" ]; then
        cd /home/ec2-user/papier-net
        git pull origin main
    else
        git clone $REPO_URL /home/ec2-user/papier-net
        cd /home/ec2-user/papier-net
    fi

    echo "=== Lancement de l'application ==="
    docker-compose down 2>/dev/null || true
    docker-compose build --no-cache
    docker-compose up -d

    echo "=== Vérification ==="
    docker-compose ps
    curl -s http://localhost/health

    echo "=== Déploiement terminé ! ==="
ENDSSH

echo -e "${GREEN}Déploiement terminé !${NC}"
echo -e "Accède à ton app : http://$EC2_HOST"
