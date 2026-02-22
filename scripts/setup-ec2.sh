#!/bin/bash
#
# ===========================================
# SETUP INITIAL EC2
# ===========================================
#
# À exécuter une seule fois quand tu crées ton EC2
# Ce script installe tout ce qu'il faut sur le serveur
#
# Usage (sur ta machine locale) :
# ./scripts/setup-ec2.sh
#

EC2_HOST="${1:-}"
SSH_KEY="${2:-~/.ssh/papier-net-key.pem}"

if [ -z "$EC2_HOST" ]; then
    echo "Usage: ./setup-ec2.sh <EC2_IP> [SSH_KEY_PATH]"
    echo "Example: ./setup-ec2.sh 54.123.45.67 ~/.ssh/my-key.pem"
    exit 1
fi

echo "Configuration de l'instance EC2: $EC2_HOST"

ssh -i "$SSH_KEY" "ec2-user@$EC2_HOST" << 'ENDSSH'
    # Mise à jour système
    sudo yum update -y

    # Installation Docker
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user

    # Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Git
    sudo yum install -y git

    # Créer le dossier pour l'app
    mkdir -p /home/ec2-user/papier-net

    echo "Setup terminé ! Reconnecte-toi pour appliquer le groupe docker."
ENDSSH

echo ""
echo "EC2 configuré ! Prochaines étapes :"
echo "1. Reconnecte-toi : ssh -i $SSH_KEY ec2-user@$EC2_HOST"
echo "2. Clone ton repo et lance docker-compose up -d"
