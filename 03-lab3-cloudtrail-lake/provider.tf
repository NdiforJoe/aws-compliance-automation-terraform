###############################################################################
# provider.tf — Lab 3: CloudTrail Lake for Security Investigations
#
# Provider configuration for CloudTrail Lake deployment
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "COP310-Lab3"
      Lab         = "CloudTrail-Lake"
      ManagedBy   = "Terraform"
      Environment = "Compliance-Demo"
    }
  }
}
