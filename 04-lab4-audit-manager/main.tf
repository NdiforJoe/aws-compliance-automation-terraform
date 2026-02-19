###############################################################################
# main.tf — Lab 4: AWS Audit Manager
#
# Deploys S3 bucket for Audit Manager evidence storage and provides
# instructions for creating assessment (Audit Manager has limited Terraform support)
###############################################################################

# ===========================================================================
# 1. S3 BUCKET FOR AUDIT MANAGER EVIDENCE
# ===========================================================================

resource "aws_s3_bucket" "audit_evidence" {
  bucket = "${var.name_prefix}-audit-evidence-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "${var.name_prefix}-audit-evidence"
    Purpose = "Audit Manager evidence storage"
  }
}

# Enable versioning for audit trail
resource "aws_s3_bucket_versioning" "audit_evidence" {
  bucket = aws_s3_bucket.audit_evidence.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "audit_evidence" {
  bucket = aws_s3_bucket.audit_evidence.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "audit_evidence" {
  bucket = aws_s3_bucket.audit_evidence.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy - retain evidence for 7 years (compliance requirement)
resource "aws_s3_bucket_lifecycle_configuration" "audit_evidence" {
  bucket = aws_s3_bucket.audit_evidence.id

  rule {
    id     = "audit-evidence-retention"
    status = "Enabled"

    expiration {
      days = 2557 # 7 years
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# ===========================================================================
# 2. IAM ROLE FOR AUDIT MANAGER
# ===========================================================================

resource "aws_iam_role" "audit_manager" {
  name = "${var.name_prefix}-audit-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "auditmanager.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.name_prefix}-audit-manager-role"
    Purpose = "Audit Manager service role"
  }
}

# Attach AWS managed policy for Audit Manager
resource "aws_iam_role_policy_attachment" "audit_manager" {
  role       = aws_iam_role.audit_manager.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AWSAuditManagerAdministratorAccess"
}

# Custom policy for evidence collection
resource "aws_iam_role_policy" "audit_manager_evidence" {
  name = "${var.name_prefix}-audit-manager-evidence-policy"
  role = aws_iam_role.audit_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AuditManagerS3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.audit_evidence.arn,
          "${aws_s3_bucket.audit_evidence.arn}/*"
        ]
      },
      {
        Sid    = "ConfigAccess"
        Effect = "Allow"
        Action = [
          "config:DescribeComplianceByConfigRule",
          "config:DescribeConfigRules",
          "config:GetComplianceDetailsByConfigRule"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudTrailAccess"
        Effect = "Allow"
        Action = [
          "cloudtrail:LookupEvents",
          "cloudtrail:GetEventDataStore"
        ]
        Resource = "*"
      }
    ]
  })
}

# ===========================================================================
# 3. NOTE: AUDIT MANAGER ASSESSMENT CREATION
# ===========================================================================

# AWS Audit Manager assessments cannot be fully created via Terraform yet.
# After running terraform apply, you'll create the assessment manually in
# the Console. The outputs.tf file provides step-by-step instructions.
#
# What this Terraform deploys:
# - S3 bucket for evidence storage (required)
# - IAM role for Audit Manager (required)
# - Policies for evidence collection
#
# What you'll create manually:
# - Custom framework (control set based on Labs 0-3)
# - Assessment (links controls to evidence sources)
# - Evidence collection configuration
