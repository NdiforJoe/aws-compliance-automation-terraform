###############################################################################
# variables.tf — Lab 2: Auto-Remediation with SSM Automation
#
# Input variables for remediation configuration
###############################################################################

variable "aws_region" {
  description = "AWS region for remediation deployment"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all remediation resources"
  type        = string
  default     = "cop310"
}

variable "enable_automatic_remediation" {
  description = "Enable automatic remediation (true) or manual-only (false)"
  type        = bool
  default     = true
}

variable "max_remediation_attempts" {
  description = "Maximum number of times to attempt automatic remediation"
  type        = number
  default     = 5
}

variable "remediation_retry_seconds" {
  description = "Seconds to wait before retrying failed remediation"
  type        = number
  default     = 60
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
