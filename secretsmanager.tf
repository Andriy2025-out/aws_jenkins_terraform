#Generate a unique identifier for the secret name
resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "jenkins_admin_password" {
  name = "jenkins-admin-password-${random_id.secret_suffix.hex}"
  description = "Jenkins admin password"
}

resource "null_resource" "get_jenkins_password" {
  depends_on = [aws_instance.jenkins_server]

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for Jenkins to initialize
      sleep 300
      
      # Get Jenkins admin password
      ssh -i ~/.ssh/${var.key_name}.pem -o StrictHostKeyChecking=no ubuntu@${aws_eip.jenkins_eip.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' > jenkins_password.txt
      
      # Store password in AWS Secrets Manager
      aws secretsmanager put-secret-value --secret-id ${aws_secretsmanager_secret.jenkins_admin_password.id} --secret-string file://jenkins_password.txt --region ${var.aws_region}
      
      # Cleanup
      rm jenkins_password.txt
    EOT
  }
}