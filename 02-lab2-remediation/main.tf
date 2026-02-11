###############################################################################
# main.tf — Lab 2: Auto-Remediation with SSM Automation
#
# Deploys SSM Automation documents and Config remediation actions to
# automatically fix compliance violations detected by Config
###############################################################################

# ===========================================================================
# 1. IAM ROLE FOR SSM AUTOMATION REMEDIATION
# ===========================================================================

resource "aws_iam_role" "remediation" {
  name = "${var.name_prefix}-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ssm.amazonaws.com",
            "config.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Name    = "${var.name_prefix}-remediation-role"
    Purpose = "Automated compliance remediation"
  }
}

# Attach AWS managed policy for SSM Automation
resource "aws_iam_role_policy_attachment" "ssm_automation" {
  role       = aws_iam_role.remediation.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

# Custom inline policy for specific remediation actions
resource "aws_iam_role_policy" "remediation_actions" {
  name = "${var.name_prefix}-remediation-policy"
  role = aws_iam_role.remediation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2RemediationActions"
        Effect = "Allow"
        Action = [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3RemediationActions"
        Effect = "Allow"
        Action = [
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketVersioning",
          "s3:GetBucketPublicAccessBlock"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMRemediationActions"
        Effect = "Allow"
        Action = [
          "iam:DeleteUserPolicy",
          "iam:PutUserPolicy",
          "iam:GetUserPolicy",
          "iam:ListUserPolicies",
          "iam:DeleteAccessKey",
          "iam:ListAccessKeys",
          "iam:GetUser"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsRemediationActions"
        Effect = "Allow"
        Action = [
          "logs:PutRetentionPolicy",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Sid    = "ConfigRemediationActions"
        Effect = "Allow"
        Action = [
          "config:PutRemediationConfigurations",
          "config:DescribeRemediationConfigurations"
        ]
        Resource = "*"
      }
    ]
  })
}

# ===========================================================================
# 2. SSM AUTOMATION DOCUMENT - REVOKE SECURITY GROUP INGRESS (0.0.0.0/0)
# ===========================================================================

resource "aws_ssm_document" "revoke_sg_ingress" {
  name            = "${var.name_prefix}-RevokeSecurityGroupIngress"
  document_type   = "Automation"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "0.3"
    description   = "Revokes security group ingress rules that allow unrestricted SSH access (0.0.0.0/0 on port 22)"
    assumeRole    = aws_iam_role.remediation.arn
    parameters = {
      SecurityGroupId = {
        type        = "String"
        description = "The ID of the security group to remediate"
      }
      AutomationAssumeRole = {
        type        = "String"
        description = "The ARN of the role for SSM Automation"
        default     = aws_iam_role.remediation.arn
      }
    }
    mainSteps = [
      {
        name   = "RevokeUnrestrictedSSH"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "ec2"
          Api     = "RevokeSecurityGroupIngress"
          GroupId = "{{ SecurityGroupId }}"
          IpPermissions = [
            {
              IpProtocol = "tcp"
              FromPort   = 22
              ToPort     = 22
              IpRanges = [
                {
                  CidrIp = "0.0.0.0/0"
                }
              ]
            }
          ]
        }
        description = "Revokes SSH access from 0.0.0.0/0"
        onFailure   = "Continue"
      }
    ]
    outputs = []
  })

  tags = {
    Name       = "${var.name_prefix}-revoke-sg-ingress"
    Purpose    = "Auto-remediation for unrestricted SSH"
    Remediates = "CIS 4.1 - Restricted SSH"
  }
}

# ===========================================================================
# 3. SSM AUTOMATION DOCUMENT - ENABLE S3 BUCKET ENCRYPTION
# ===========================================================================

resource "aws_ssm_document" "enable_s3_encryption" {
  name            = "${var.name_prefix}-EnableS3Encryption"
  document_type   = "Automation"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "0.3"
    description   = "Enables default encryption on S3 buckets using AES256"
    assumeRole    = aws_iam_role.remediation.arn
    parameters = {
      BucketName = {
        type        = "String"
        description = "The name of the S3 bucket to enable encryption on"
      }
      AutomationAssumeRole = {
        type        = "String"
        description = "The ARN of the role for SSM Automation"
        default     = aws_iam_role.remediation.arn
      }
    }
    mainSteps = [
      {
        name   = "EnableBucketEncryption"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "PutBucketEncryption"
          Bucket  = "{{ BucketName }}"
          ServerSideEncryptionConfiguration = {
            Rules = [
              {
                ApplyServerSideEncryptionByDefault = {
                  SSEAlgorithm = "AES256"
                }
                BucketKeyEnabled = true
              }
            ]
          }
        }
        description = "Enables AES256 encryption on the S3 bucket"
        onFailure   = "Continue"
      }
    ]
    outputs = []
  })

  tags = {
    Name       = "${var.name_prefix}-enable-s3-encryption"
    Purpose    = "Auto-remediation for S3 encryption"
    Remediates = "CIS 2.1.2 - S3 Bucket Encryption"
  }
}

# ===========================================================================
# 4. SSM AUTOMATION DOCUMENT - ENABLE S3 VERSIONING
# ===========================================================================

resource "aws_ssm_document" "enable_s3_versioning" {
  name            = "${var.name_prefix}-EnableS3Versioning"
  document_type   = "Automation"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "0.3"
    description   = "Enables versioning on S3 buckets"
    assumeRole    = aws_iam_role.remediation.arn
    parameters = {
      BucketName = {
        type        = "String"
        description = "The name of the S3 bucket to enable versioning on"
      }
      AutomationAssumeRole = {
        type        = "String"
        description = "The ARN of the role for SSM Automation"
        default     = aws_iam_role.remediation.arn
      }
    }
    mainSteps = [
      {
        name   = "EnableVersioning"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "PutBucketVersioning"
          Bucket  = "{{ BucketName }}"
          VersioningConfiguration = {
            Status = "Enabled"
          }
        }
        description = "Enables versioning on the S3 bucket"
        onFailure   = "Continue"
      }
    ]
    outputs = []
  })

  tags = {
    Name       = "${var.name_prefix}-enable-s3-versioning"
    Purpose    = "Auto-remediation for S3 versioning"
    Remediates = "SOC 2 CC8.1 - Data Recovery"
  }
}

# ===========================================================================
# 5. SSM AUTOMATION DOCUMENT - ATTACH S3 PUBLIC ACCESS BLOCK
# ===========================================================================

resource "aws_ssm_document" "attach_s3_public_access_block" {
  name            = "${var.name_prefix}-AttachS3PublicAccessBlock"
  document_type   = "Automation"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "0.3"
    description   = "Attaches Public Access Block configuration to S3 buckets"
    assumeRole    = aws_iam_role.remediation.arn
    parameters = {
      BucketName = {
        type        = "String"
        description = "The name of the S3 bucket"
      }
      AutomationAssumeRole = {
        type        = "String"
        description = "The ARN of the role for SSM Automation"
        default     = aws_iam_role.remediation.arn
      }
    }
    mainSteps = [
      {
        name   = "AttachPublicAccessBlock"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "PutPublicAccessBlock"
          Bucket  = "{{ BucketName }}"
          PublicAccessBlockConfiguration = {
            BlockPublicAcls       = true
            BlockPublicPolicy     = true
            IgnorePublicAcls      = true
            RestrictPublicBuckets = true
          }
        }
        description = "Blocks all public access to the S3 bucket"
        onFailure   = "Continue"
      }
    ]
    outputs = []
  })

  tags = {
    Name       = "${var.name_prefix}-attach-s3-pab"
    Purpose    = "Auto-remediation for S3 public access"
    Remediates = "CIS 2.1.5 - S3 Public Access Block"
  }
}

# ===========================================================================
# 6. CONFIG REMEDIATION CONFIGURATIONS
# ===========================================================================

# Remediation 1: Auto-revoke unrestricted SSH
resource "aws_config_remediation_configuration" "revoke_sg_ingress" {
  config_rule_name = "${var.name_prefix}-restricted-ssh"

  automatic                  = var.enable_automatic_remediation
  maximum_automatic_attempts = var.max_remediation_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  target_type    = "SSM_DOCUMENT"
  target_id      = aws_ssm_document.revoke_sg_ingress.name
  target_version = "1"

  parameter {
    name           = "SecurityGroupId"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.remediation.arn
  }

  depends_on = [
    aws_iam_role_policy.remediation_actions,
    aws_iam_role_policy_attachment.ssm_automation
  ]
}

# Remediation 2: Auto-enable S3 encryption
resource "aws_config_remediation_configuration" "enable_s3_encryption" {
  config_rule_name = "${var.name_prefix}-s3-bucket-sse"

  automatic                  = var.enable_automatic_remediation
  maximum_automatic_attempts = var.max_remediation_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  target_type    = "SSM_DOCUMENT"
  target_id      = aws_ssm_document.enable_s3_encryption.name
  target_version = "1"

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.remediation.arn
  }

  depends_on = [
    aws_iam_role_policy.remediation_actions,
    aws_iam_role_policy_attachment.ssm_automation
  ]
}

# Remediation 3: Auto-enable S3 versioning
resource "aws_config_remediation_configuration" "enable_s3_versioning" {
  config_rule_name = "${var.name_prefix}-s3-versioning-enabled"

  automatic                  = var.enable_automatic_remediation
  maximum_automatic_attempts = var.max_remediation_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  target_type    = "SSM_DOCUMENT"
  target_id      = aws_ssm_document.enable_s3_versioning.name
  target_version = "1"

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.remediation.arn
  }

  depends_on = [
    aws_iam_role_policy.remediation_actions,
    aws_iam_role_policy_attachment.ssm_automation
  ]
}

# Remediation 4: Auto-attach S3 Public Access Block
resource "aws_config_remediation_configuration" "attach_s3_pab" {
  config_rule_name = "${var.name_prefix}-s3-public-read-prohibited"

  automatic                  = var.enable_automatic_remediation
  maximum_automatic_attempts = var.max_remediation_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  target_type    = "SSM_DOCUMENT"
  target_id      = aws_ssm_document.attach_s3_public_access_block.name
  target_version = "1"

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.remediation.arn
  }

  depends_on = [
    aws_iam_role_policy.remediation_actions,
    aws_iam_role_policy_attachment.ssm_automation
  ]
}
