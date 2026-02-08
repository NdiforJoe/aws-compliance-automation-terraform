###############################################################################
# provider.tf — Lab 2: Auto-Remediation with SSM Automation
#
# Provider configuration for automated compliance remediation
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
      Project     = "COP310-Lab2"
      Lab         = "Auto-Remediation"
      ManagedBy   = "Terraform"
      Environment = "Compliance-Demo"
    }
  }
}
