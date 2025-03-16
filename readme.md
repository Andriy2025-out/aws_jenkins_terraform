# Jenkins AWS Terraform Deployment

This repository contains Terraform scripts to automate the deployment of a Jenkins server on AWS. The infrastructure includes a VPC with public and private subnets, security groups, EC2 instance, and optional Route 53 configuration.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v0.14 or later)
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- An AWS account with appropriate permissions
- SSH key pair created in AWS
- (Optional) A registered domain name for Route 53 configuration

## Project Structure

```
.
├── provider.tf      # AWS provider configuration and backend
├── variables.tf     # Input variables
├── vpc.tf           # VPC, subnets, gateways, and routing
├── security_groups.tf # Security group configuration
├── ec2.tf           # EC2 instance and related resources
├── dns.tf           # Route 53 configuration (optional)
├── secretsmanager.tf # AWS Secrets Manager configuration
├── outputs.tf       # Output values
├── terraform.tfvars # Variable values (create this file)
└── README.md        # This file
```

## Configuration

1. Create an IAM user with appropriate permissions:
   - Navigate to the AWS IAM console
   - Create a user with programmatic access
   - Attach policies for EC2, VPC, Route 53, Secrets Manager, etc.
   - Save the access key and secret key

2. Configure AWS CLI:
   ```bash
   aws configure --profile terraform-jenkins
   ```

3. Create or modify `terraform.tfvars` with your specific values:
   ```hcl
   aws_region = "us-east-1"
   aws_profile = "terraform-jenkins"
   instance_type = "t3.medium"
   domain_name = "example.com"  # Your domain name
   jenkins_subdomain = "jenkins"
   key_name = "your-key-pair-name"  # Must exist in AWS
   # For SSH access restriction (replace with your IP)
   my_ip = "my_ip"
   ```

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Once deployed, access Jenkins at:
   - If using Route 53: `https://jenkins.example.com`
   - If not using Route 53: Use the public IP from the outputs

5. Get the initial admin password:
   ```bash
   aws secretsmanager get-secret-value --secret-id jenkins-admin-password --query SecretString --output text --profile terraform-jenkins
   ```

6. To destroy the infrastructure:
   ```bash
   terraform destroy
   ```

## Security Notes

- SSH access is restricted to the IP specified in `my_ip`
- Jenkins is configured with HTTPS using Let's Encrypt
- The initial admin password is stored in AWS Secrets Manager

## Customization

- Change instance type in `terraform.tfvars` for different performance levels
- Modify the Jenkins installation script in `ec2.tf` to install additional tools
- Update security groups as needed for additional services

## Troubleshooting

- If Route 53 configuration fails, ensure your domain is properly registered and nameservers are configured
- For SSL certificate issues, check that your domain is resolving correctly
- If Jenkins doesn't start, check the EC2 system logs for errors