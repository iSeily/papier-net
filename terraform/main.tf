#
# ===========================================
# TERRAFORM - INFRASTRUCTURE AS CODE
# ===========================================
#
# Ce fichier décrit TOUTE l'infrastructure AWS
# Au lieu de cliquer dans la console, on écrit du code
#
# Pour lancer :
#   terraform init    → initialise le projet
#   terraform plan    → prévisualise les changements
#   terraform apply   → crée l'infrastructure
#   terraform destroy → supprime tout
#

# === PROVIDER ===
# Le provider dit à Terraform quel cloud utiliser
# Ici AWS, région Paris (eu-west-3)
provider "aws" {
  region = var.aws_region
}

# === SECURITY GROUP ===
# Règles de pare-feu pour l'instance EC2
# C'est ce qu'on avait configuré à la main dans la console !
resource "aws_security_group" "papier_net" {
  name        = "papier-net-sg"
  description = "Security group pour Papier.net"

  # Autoriser SSH (port 22) depuis n'importe où
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # Autoriser HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # Autoriser HTTPS (port 443) pour plus tard
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "papier-net-sg"
    Project = "papier-net"
  }
}

# === INSTANCE EC2 ===
# Le serveur cloud (équivalent à ce qu'on a créé à la main)
resource "aws_instance" "papier_net" {
  # AMI = Amazon Machine Image (le système d'exploitation)
  # ami-0c6ebbd55ab05f070 = Amazon Linux 2023 en eu-west-3
  ami           = var.ami_id
  instance_type = var.instance_type  # t3.micro = Free tier

  # La clé SSH pour se connecter au serveur
  key_name = var.key_name

  # Attacher le security group créé au-dessus
  vpc_security_group_ids = [aws_security_group.papier_net.id]

  # Script exécuté au démarrage du serveur
  # Installe Docker automatiquement !
  user_data = <<-EOF
    #!/bin/bash
    # Mise à jour du système
    apt-get update -y

    # Installation de Docker
    apt-get install -y docker.io git

    # Démarrage automatique de Docker
    systemctl start docker
    systemctl enable docker

    # Ajout de l'utilisateur ubuntu au groupe docker
    usermod -aG docker ubuntu

    # Installation de Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Clone et lancement automatique de l'app
    git clone https://github.com/iseily/papier-net.git /home/ubuntu/papier-net
    cd /home/ubuntu/papier-net
    docker-compose up -d --build
  EOF

  tags = {
    Name    = "papier-net"
    Project = "papier-net"
    Env     = "production"
  }
}
