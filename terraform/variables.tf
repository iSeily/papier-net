#
# ===========================================
# VARIABLES TERRAFORM
# ===========================================
#
# Les variables permettent de rendre le code réutilisable
# Au lieu de hardcoder les valeurs dans main.tf,
# on les déclare ici et on les passe au moment du apply
#
# Equivalent des variables d'environnement en DevOps
#

variable "aws_region" {
  description = "La région AWS à utiliser"
  type        = string
  default     = "eu-west-3"  # Paris
}

variable "instance_type" {
  description = "Le type d'instance EC2"
  type        = string
  default     = "t3.micro"  # Free tier
}

variable "ami_id" {
  description = "L'AMI Ubuntu 22.04 pour eu-west-3"
  type        = string
  default     = "ami-0c6ebbd55ab05f070"  # Ubuntu 22.04, Paris
}

variable "key_name" {
  description = "Le nom de ta clé SSH dans AWS"
  type        = string
  default     = "papier-net-key2"  # Clé importée depuis notre Mac
}
