###############################################################################
# provider.tf — Lab 1: AWS Config Foundations
#
# Provider configuration and backend setup for Config deployment
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend for single-account demo
  # For production, migrate to S3 backend with state locking
  backend "local" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "COP310-Lab1"
      Lab         = "AWS-Config-Foundations"
      ManagedBy   = "Terraform"
      Environment = "Compliance-Demo"
    }
  }
}
