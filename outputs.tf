output "jenkins_url" {
  value = "https://${var.jenkins_subdomain}.${var.domain_name}"
}

output "jenkins_public_ip" {
  value = aws_eip.jenkins_eip.public_ip
}

output "jenkins_password_secret_arn" {
  value = aws_secretsmanager_secret.jenkins_admin_password.arn
}