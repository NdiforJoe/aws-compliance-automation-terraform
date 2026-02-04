###############################################################################
# variables.tf — Lab 1: AWS Config Foundations
#
# Input variables for AWS Config deployment
###############################################################################

variable "aws_region" {
  description = "AWS region for Config deployment"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all Config resources"
  type        = string
  default     = "cop310"
}

variable "config_snapshot_frequency" {
  description = "How often Config takes configuration snapshots (One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours)"
  type        = string
  default     = "TwentyFour_Hours"
}

variable "enable_config_recorder" {
  description = "Enable the Config recorder after creation"
  type        = bool
  default     = true
}

variable "config_bucket_retention_days" {
  description = "Number of days to retain Config snapshots in S3"
  type        = number
  default     = 90
}

variable "enable_conformance_pack" {
  description = "Deploy CIS AWS Foundations Benchmark conformance pack"
  type        = bool
  default     = true
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current AWS partition
data "aws_partition" "current" {}
