###############################################################################
# variables.tf — COP310 Pre-Setup: Input Variables
#
# Every tuneable value lives here. Defaults are chosen to create the
# specific non-compliant states that Labs 1–4 will detect & remediate.
###############################################################################

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region for all resources. us-east-1 gives the widest service coverage."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = <<-EOT
    Short prefix applied to every resource name.
    Change this if you run multiple instances of the demo to avoid collisions.
  EOT
  type        = string
  default     = "cop310"
}

# ---------------------------------------------------------------------------
# VPC / Networking
# ---------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the demo VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the single public subnet (intentionally no private subnet)."
  type        = string
  default     = "10.0.1.0/24"
}

# ---------------------------------------------------------------------------
# EC2 — Intentional Non-Compliance Flags
# ---------------------------------------------------------------------------
# ⚠️  COMPLIANCE VIOLATION: instance_open_to_world = true creates a 0.0.0.0/0
#     security group rule.  Lab 1 detects this; Lab 2 auto-remediates it.
variable "instance_open_to_world" {
  description = "When true, the EC2 security group allows SSH from 0.0.0.0/0 (non-compliant)."
  type        = bool
  default     = true
}

# ⚠️  COMPLIANCE VIOLATION: instance_encrypted = false means the root EBS
#     volume is NOT encrypted.  Detected by Config rule "ebs-encrypted".
variable "instance_encrypted" {
  description = "When true, the EC2 root volume is encrypted. Set false for non-compliant demo."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro keeps costs minimal."
  type        = string
  default     = "t3.micro"
}

# ---------------------------------------------------------------------------
# S3 — Intentional Non-Compliance Flags
# ---------------------------------------------------------------------------
# ⚠️  COMPLIANCE VIOLATION: s3_block_public_access = false leaves the bucket
#     without a Public Access Block — detected by "s3-bucket-public-access-blocked".
variable "s3_block_public_access" {
  description = "When true, attaches a PublicAccessBlock. Set false for non-compliant demo."
  type        = bool
  default     = false
}

# ⚠️  COMPLIANCE VIOLATION: s3_encryption_enabled = false means no default
#     server-side encryption rule — detected by "s3-bucket-server-side-encryption-enabled".
variable "s3_encryption_enabled" {
  description = "When true, enables SSE-S3 default encryption. Set false for non-compliant demo."
  type        = bool
  default     = false
}

# ⚠️  COMPLIANCE VIOLATION: s3_versioning_enabled = false — detected by
#     "s3-bucket-versioning-enabled".
variable "s3_versioning_enabled" {
  description = "When true, enables versioning. Set false for non-compliant demo."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# IAM — Intentional Non-Compliance Flags
# ---------------------------------------------------------------------------
# ⚠️  COMPLIANCE VIOLATION: iam_policy_overly_broad = true attaches a policy
#     with Action: "*" and Resource: "*" — the classic "admin everywhere" mistake.
#     Detected by "iam-policy-analysis" and custom Config rules.
variable "iam_policy_overly_broad" {
  description = "When true, attaches a wildcard admin policy to the demo IAM user."
  type        = bool
  default     = true
}

# ⚠️  COMPLIANCE VIOLATION: iam_user_has_access_key = true creates a
#     programmatic access key — detected by "iam-user-unused-credentials-check"
#     and flags in Audit Manager.
variable "iam_user_has_access_key" {
  description = "When true, creates an access key for the demo IAM user (non-compliant)."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# CloudWatch Log Group — for SSM + future labs
# ---------------------------------------------------------------------------
variable "log_group_retention_days" {
  description = "CloudWatch Log Group retention in days. 0 = never expire (non-compliant in some frameworks)."
  type        = number
  default     = 0
}
