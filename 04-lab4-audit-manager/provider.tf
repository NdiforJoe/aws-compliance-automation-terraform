###############################################################################
# provider.tf — Lab 4: AWS Audit Manager
#
# Provider configuration for automated audit evidence collection
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
      Project     = "COP310-Lab4"
      Lab         = "Audit-Manager"
      ManagedBy   = "Terraform"
      Environment = "Compliance-Demo"
    }
  }
}
