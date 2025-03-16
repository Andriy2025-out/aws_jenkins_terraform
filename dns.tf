# Create the Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  tags = {
    Name = "Jenkins domain zone"
  }
}

# Create DNS record for Jenkins
resource "aws_route53_record" "jenkins" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "${var.jenkins_subdomain}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.jenkins_eip.public_ip]
}

# Output the name servers for the zone
output "nameservers" {
  value = aws_route53_zone.main.name_servers
  description = "Nameservers for the Route 53 zone"
}