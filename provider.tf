provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    bucket = "jenkins-terraform-outpost-state"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
    profile = "default"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}