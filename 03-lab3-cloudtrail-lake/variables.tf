###############################################################################
# variables.tf — Lab 3: CloudTrail Lake for Security Investigations
#
# Input variables for CloudTrail Lake configuration
###############################################################################

variable "aws_region" {
  description = "AWS region for CloudTrail Lake deployment"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all CloudTrail Lake resources"
  type        = string
  default     = "cop310"
}

variable "retention_days" {
  description = "Number of days to retain CloudTrail Lake events (7-2557 days, or 0 for indefinite)"
  type        = number
  default     = 90

  validation {
    condition     = var.retention_days == 0 || (var.retention_days >= 7 && var.retention_days <= 2557)
    error_message = "Retention days must be 0 (indefinite) or between 7 and 2557 days."
  }
}

variable "enable_termination_protection" {
  description = "Enable termination protection on event data store"
  type        = bool
  default     = false
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
