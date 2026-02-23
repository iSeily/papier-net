#
# ===========================================
# OUTPUTS TERRAFORM
# ===========================================
#
# Les outputs affichent des infos utiles après le apply
# Ex: l'IP de l'instance créée, l'URL du site, etc.
# Très utile pour récupérer des valeurs automatiquement
#

output "instance_ip" {
  description = "L'IP publique de l'instance EC2"
  value       = aws_instance.papier_net.public_ip
}

output "instance_id" {
  description = "L'ID de l'instance EC2"
  value       = aws_instance.papier_net.id
}

output "site_url" {
  description = "L'URL du site"
  value       = "http://${aws_instance.papier_net.public_ip}"
}

output "ssh_command" {
  description = "La commande pour se connecter en SSH"
  value       = "ssh -i ~/.ssh/papier-net-key2 ubuntu@${aws_instance.papier_net.public_ip}"
}
