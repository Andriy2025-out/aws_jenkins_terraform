resource "aws_instance" "jenkins_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  
  user_data = <<-EOF
  #!/bin/bash
  # Update system
  sudo apt-get update
  sudo apt-get upgrade -y
  
  # Install necessary dependencies
  sudo apt install -y openjdk-17-jre-headless
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  
  # Install Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker ubuntu
  
  # Install Jenkins
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y jenkins
  sudo apt install -y fontconfig openjdk-17-jre


  sudo systemctl enable jenkins
  sudo systemctl start jenkins
  
  # Install Nginx
  sudo apt-get install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
  
  # Setup Nginx for Jenkins proxy
  sudo tee /etc/nginx/conf.d/jenkins.conf > /dev/null <<'EOT'
  server {
      listen 80;
      server_name ${var.jenkins_subdomain}.${var.domain_name};
      
      location / {
          proxy_pass http://localhost:8080;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
      }
  }
  EOT
  
  # Remove default Nginx site if it exists
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo systemctl restart nginx
  
  # Install Certbot and obtain SSL certificate
  sudo apt-get install -y certbot python3-certbot-nginx
  sudo certbot --nginx -d ${var.jenkins_subdomain}.${var.domain_name} --non-interactive --agree-tos -m admin@${var.domain_name} --redirect
  
  # Get Jenkins admin password and put it in SSM
  JENKINS_PASS=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
  sudo apt-get install -y awscli
  aws ssm put-parameter --name "/jenkins/admin/password" --value "$JENKINS_PASS" --type SecureString --region ${var.aws_region}
EOF

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_server.id
  domain   = "vpc"

  tags = {
    Name = "jenkins-eip"
  }
}

