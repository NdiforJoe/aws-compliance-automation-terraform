###############################################################################
# variables.tf — Lab 4: AWS Audit Manager
#
# Input variables for Audit Manager configuration
###############################################################################

variable "aws_region" {
  description = "AWS region for Audit Manager deployment"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all Audit Manager resources"
  type        = string
  default     = "cop310"
}

variable "assessment_name" {
  description = "Name of the audit assessment"
  type        = string
  default     = "COP310-Compliance-Assessment"
}

variable "assessment_description" {
  description = "Description of the audit assessment"
  type        = string
  default     = "Continuous compliance assessment for COP310 demo environment - automated evidence collection for Config rules, SSM remediation, and CloudTrail activity"
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
