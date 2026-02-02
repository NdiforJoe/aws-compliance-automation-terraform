###############################################################################
# outputs.tf — COP310 Pre-Setup: Outputs
#
# These outputs serve two purposes:
#   1. Feed resource IDs into later labs (Config rules reference these)
#   2. Provide a quick "compliance snapshot" for the portfolio README
###############################################################################

# ---------------------------------------------------------------------------
# VPC & Networking
# ---------------------------------------------------------------------------
output "vpc_id" {
  description = "Demo VPC ID"
  value       = aws_vpc.demo.id
}

output "public_subnet_id" {
  description = "Public subnet ID (EC2 is deployed here)"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "EC2 security group ID (contains the open SSH rule)"
  value       = aws_security_group.demo_ec2.id
}

# ---------------------------------------------------------------------------
# EC2
# ---------------------------------------------------------------------------
output "ec2_instance_id" {
  description = "Demo EC2 instance ID — used in Lab 1 Config rules & Lab 2 SSM targets"
  value       = aws_instance.demo.id
}

output "ec2_public_ip" {
  description = "Public IP of the demo EC2 instance"
  value       = aws_instance.demo.public_ip
}

output "ec2_instance_profile_name" {
  description = "Instance profile name (SSM agent needs this to be attached)"
  value       = aws_iam_instance_profile.ec2.name
}

# ---------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------
output "s3_bucket_name" {
  description = "Non-compliant S3 bucket name — used in Lab 1 Config rules"
  value       = aws_s3_bucket.demo.id
}

output "s3_bucket_arn" {
  description = "Non-compliant S3 bucket ARN"
  value       = aws_s3_bucket.demo.arn
}

# ---------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------
output "iam_user_name" {
  description = "Demo IAM user name — has overly broad policy attached"
  value       = aws_iam_user.demo.name
}

output "iam_access_key_id" {
  description = "Access key ID for the demo IAM user (non-compliant credential). SENSITIVE — do not log in production."
  value       = var.iam_user_has_access_key ? aws_iam_access_key.demo[0].id : "N/A — access key disabled"
  sensitive   = true
}

output "iam_access_key_secret" {
  description = "Secret access key for the demo IAM user. SENSITIVE."
  value       = var.iam_user_has_access_key ? aws_iam_access_key.demo[0].secret : "N/A"
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Compliance Violation Summary (for portfolio documentation)
# ---------------------------------------------------------------------------
output "compliance_violation_summary" {
  description = <<-EOT
    Human-readable summary of all intentional violations deployed.
    Use this in your portfolio README as a "before" snapshot.
  EOT
  value       = <<-EOT
    ============================================================
    COP310 Pre-Setup — Intentional Non-Compliance Summary
    ============================================================
    Resource                  | Violation                          | Status
    --------------------------|------------------------------------|---------
    EC2 Security Group        | SSH open to 0.0.0.0/0             | ${var.instance_open_to_world ? "NON-COMPLIANT" : "COMPLIANT"}
    EC2 Root Volume           | EBS not encrypted                  | ${var.instance_encrypted ? "COMPLIANT" : "NON-COMPLIANT"}
    EC2 Subnet                | Public IP auto-assigned            | NON-COMPLIANT
    S3 Bucket                 | No server-side encryption          | ${var.s3_encryption_enabled ? "COMPLIANT" : "NON-COMPLIANT"}
    S3 Bucket                 | No Public Access Block             | ${var.s3_block_public_access ? "COMPLIANT" : "NON-COMPLIANT"}
    S3 Bucket                 | Versioning disabled                | ${var.s3_versioning_enabled ? "COMPLIANT" : "NON-COMPLIANT"}
    IAM User Policy           | Wildcard Action:* Resource:*       | ${var.iam_policy_overly_broad ? "NON-COMPLIANT" : "COMPLIANT"}
    IAM User                  | Active programmatic access key     | ${var.iam_user_has_access_key ? "NON-COMPLIANT" : "COMPLIANT"}
    CloudWatch Log Group      | No retention policy (never expires)| NON-COMPLIANT
    ============================================================
  EOT
}
