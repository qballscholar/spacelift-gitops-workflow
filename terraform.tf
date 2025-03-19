# This file is for documentation only
# Each stack (vpc, eks) has its own Terraform configuration
terraform {
  required_version = "~> 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # NOTE: Do not include backend configuration here
  # Backend is configured in each stack's directory
}

provider "aws" {
  region = "us-east-1"
}


provider "aws" {
  region = "us-east-1"
}