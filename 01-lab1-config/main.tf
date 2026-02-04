###############################################################################
# main.tf — Lab 1: AWS Config Foundations
#
# Deploys AWS Config recorder, delivery channel, managed rules, and
# conformance pack to detect compliance violations
###############################################################################

# ===========================================================================
# 1. S3 BUCKET FOR CONFIG SNAPSHOTS
# ===========================================================================

resource "aws_s3_bucket" "config" {
  bucket = "${var.name_prefix}-config-${data.aws_caller_identity.current.account_id}"

  # Force destroy allows cleanup during demo
  force_destroy = true

  tags = {
    Name       = "${var.name_prefix}-config-bucket"
    Purpose    = "AWS Config snapshots and history"
    Compliance = "Audit evidence storage"
  }
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    id     = "config-retention"
    status = "Enabled"

    filter {}

    expiration {
      days = var.config_bucket_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# S3 bucket policy allowing Config service to write
resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config.arn
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.config.arn
      },
      {
        Sid    = "AWSConfigBucketPutObject"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ===========================================================================
# 2. IAM ROLE FOR CONFIG SERVICE
# ===========================================================================

resource "aws_iam_role" "config" {
  name = "${var.name_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-config-role"
  }
}

# Attach AWS managed policy for Config
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Custom policy for S3 bucket access
resource "aws_iam_role_policy" "config_s3" {
  name = "${var.name_prefix}-config-s3-policy"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.config.arn,
          "${aws_s3_bucket.config.arn}/*"
        ]
      }
    ]
  })
}

# ===========================================================================
# 3. CONFIG RECORDER
# ===========================================================================

resource "aws_config_configuration_recorder" "main" {
  name     = "${var.name_prefix}-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.config,
    aws_iam_role_policy.config_s3
  ]
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.name_prefix}-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config.id

  snapshot_delivery_properties {
    delivery_frequency = var.config_snapshot_frequency
  }

  depends_on = [
    aws_config_configuration_recorder.main,
    aws_s3_bucket_policy.config
  ]
}

# Start the recorder
resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = var.enable_config_recorder

  depends_on = [aws_config_delivery_channel.main]
}

# ===========================================================================
# 4. MANAGED CONFIG RULES - CIS AWS FOUNDATIONS
# ===========================================================================

# Rule 1: Restricted SSH (detects 0.0.0.0/0 on port 22)
resource "aws_config_config_rule" "restricted_ssh" {
  name = "${var.name_prefix}-restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 2: Encrypted Volumes (detects unencrypted EBS)
resource "aws_config_config_rule" "encrypted_volumes" {
  name = "${var.name_prefix}-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 3: S3 Bucket Server Side Encryption
resource "aws_config_config_rule" "s3_bucket_sse" {
  name = "${var.name_prefix}-s3-bucket-sse"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 4: S3 Bucket Public Read Prohibited
resource "aws_config_config_rule" "s3_public_read" {
  name = "${var.name_prefix}-s3-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 5: S3 Bucket Public Write Prohibited
resource "aws_config_config_rule" "s3_public_write" {
  name = "${var.name_prefix}-s3-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 6: S3 Bucket Versioning Enabled
resource "aws_config_config_rule" "s3_versioning" {
  name = "${var.name_prefix}-s3-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 7: IAM Policy No Full Wildcard
resource "aws_config_config_rule" "iam_no_wildcard" {
  name = "${var.name_prefix}-iam-policy-no-admin-access"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 8: IAM User Unused Credentials
resource "aws_config_config_rule" "iam_unused_credentials" {
  name = "${var.name_prefix}-iam-unused-credentials"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  input_parameters = jsonencode({
    maxCredentialUsageAge = 90
  })

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 9: CloudWatch Log Group Encryption
resource "aws_config_config_rule" "cloudwatch_log_encryption" {
  name = "${var.name_prefix}-cw-log-encryption"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_LOG_GROUP_ENCRYPTED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 10: EC2 Instance Detailed Monitoring
resource "aws_config_config_rule" "ec2_detailed_monitoring" {
  name = "${var.name_prefix}-ec2-detailed-monitoring"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 11: Root Account MFA Enabled
resource "aws_config_config_rule" "root_mfa" {
  name = "${var.name_prefix}-root-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Rule 12: IAM Password Policy
resource "aws_config_config_rule" "iam_password_policy" {
  name = "${var.name_prefix}-iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = jsonencode({
    RequireUppercaseCharacters = true
    RequireLowercaseCharacters = true
    RequireSymbols             = true
    RequireNumbers             = true
    MinimumPasswordLength      = 14
    MaxPasswordAge             = 90
  })

  depends_on = [aws_config_configuration_recorder.main]
}
