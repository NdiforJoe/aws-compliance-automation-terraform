###############################################################################
# provider.tf — COP310 Pre-Setup: Provider & Backend Configuration
#
# Portfolio note: Pinning provider versions is a production best-practice.
# Using a local backend here for simplicity; swap to S3 backend when you
# integrate this with the multi-account lab (Lab 5).
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state for single-account portfolio demo.
  # For Lab 5 (multi-account), migrate to:
  #   backend "s3" {
  #     bucket         = "your-tf-state-bucket"
  #     key            = "cop310/00-presetup/terraform.tfstate"
  #     region         = "us-east-1"
  #     dynamodb_table = "your-tf-lock-table"
  #     encrypt        = true
  #   }
  backend "local" {}
}

provider "aws" {
  region = var.aws_region

  # Default tags applied to every resource Terraform creates.
  # Missing or incorrect tags are one of the compliance violations
  # we will detect in Lab 1 — these tags mark resources as
  # INTENTIONALLY non-compliant demo infrastructure.
  default_tags {
    tags = {
      Project     = "COP310-Demo"
      Environment = "NonCompliant-Demo"
      ManagedBy   = "Terraform"
    }
  }
}
