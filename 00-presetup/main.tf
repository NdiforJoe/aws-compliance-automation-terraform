###############################################################################
# main.tf — COP310 Pre-Setup: Non-Compliant Demo Resources
#
# This file provisions the intentionally misconfigured resources that
# Labs 1–4 will detect, audit, and remediate. Each resource is annotated
# with:
#   [VIOLATION]  — what rule / check catches it
#   [DETECTED BY] — which lab first surfaces it
#   [REMEDIATED BY] — which lab auto-fixes it (if applicable)
###############################################################################

# ===========================================================================
# 1. VPC & NETWORKING
#    Violation: Single public subnet, no private subnet, no NAT Gateway.
#    This forces EC2 instances into a public subnet — bad practice.
# ===========================================================================

resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-demo-vpc"
  }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = var.public_subnet_cidr

  # ⚠️ [VIOLATION] map_public_ip_on_launch = true auto-assigns public IPs.
  #    Detected by: "ec2-instance-public-ip-check" in Lab 1.
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }

  tags = {
    Name = "${var.name_prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ===========================================================================
# 2. SECURITY GROUP — Overly Permissive SSH
#    [VIOLATION]  restricted-ssh (Config managed rule)
#    [DETECTED BY] Lab 1 — AWS Config managed rule
#    [REMEDIATED BY] Lab 2 — SSM Automation (revokes 0.0.0.0/0 rule)
# ===========================================================================

resource "aws_security_group" "demo_ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Demo SG — intentionally overly permissive for compliance lab."
  vpc_id      = aws_vpc.demo.id

  # ⚠️ [VIOLATION] SSH open to the entire internet.
  dynamic "ingress" {
    for_each = var.instance_open_to_world ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "INTENTIONAL: SSH open to world — Lab 1 detects, Lab 2 remediates"
    }
  }

  # Narrow SSH (only created when the violation flag is turned off — used
  # to verify remediation in Lab 2).
  dynamic "ingress" {
    for_each = var.instance_open_to_world ? [] : [1]
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Compliant: SSH restricted to private CIDR only"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (standard for demo)"
  }

  tags = {
    Name = "${var.name_prefix}-ec2-sg"
  }
}

# ===========================================================================
# 3. EC2 INSTANCE — Unencrypted, Public, Untagged (partially)
#    [VIOLATION]  ebs-encrypted, ec2-instance-public-ip-check
#    [DETECTED BY] Lab 1
#    [REMEDIATED BY] Lab 2 (encryption via AMI replacement or stop/encrypt/start)
# ===========================================================================

# IAM instance profile — gives EC2 an identity (needed for SSM in Lab 2)
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.name_prefix}-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-ec2-instance-role"
  }
}

# Attach SSM Agent managed policy so SSM Automation can reach this instance
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_instance" "demo" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public.id
  security_groups      = [aws_security_group.demo_ec2.id]
  iam_instance_profile = aws_iam_instance_profile.ec2.name

  # ⚠️ [VIOLATION] Root volume encryption controlled by variable (default: false)
  root_block_device {
    volume_size = 20
    encrypted   = var.instance_encrypted
    tags = {
      Name = "${var.name_prefix}-demo-root-volume"
    }
  }

  # ⚠️ NOTE: No "Name" tag on the instance itself is intentional — some
  #    compliance frameworks require a Name tag. We add it via default_tags
  #    in the provider, but a custom rule in Lab 1 can check for it.
  tags = {
    Name = "${var.name_prefix}-demo-ec2"
    # Intentionally MISSING: Owner, CostCenter, DataClassification tags
    # Lab 1 custom rule will flag the absence of required tags.
  }
}

# Lookup latest Amazon Linux 2023 AMI in us-east-1
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2023/x86_64/minimal/*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ===========================================================================
# 4. S3 BUCKET — No Encryption, No Public Access Block, No Versioning
#    [VIOLATION]  s3-bucket-server-side-encryption-enabled,
#                 s3-bucket-public-access-blocked,
#                 s3-bucket-versioning-enabled
#    [DETECTED BY] Lab 1
#    [REMEDIATED BY] Lab 2 (auto-enables encryption + public access block)
# ===========================================================================

resource "aws_s3_bucket" "demo" {
  bucket = "${var.name_prefix}-noncompliant-demo-${data.aws_caller_identity.current.account_id}"

  # Force destroy allows Terraform to delete non-empty buckets during cleanup.
  # Only appropriate for demo/test buckets.
  force_destroy = true

  tags = {
    Name = "${var.name_prefix}-noncompliant-s3"
    # ⚠️ Intentionally missing: DataClassification, Owner tags
  }
}

# ⚠️ [VIOLATION] Encryption is CONDITIONALLY applied (default: disabled)
resource "aws_s3_bucket_server_side_encryption_configuration" "demo" {
  count  = var.s3_encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.demo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ⚠️ [VIOLATION] Public Access Block is CONDITIONALLY applied (default: disabled)
resource "aws_s3_bucket_public_access_block" "demo" {
  count  = var.s3_block_public_access ? 1 : 0
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ⚠️ [VIOLATION] Versioning is CONDITIONALLY applied (default: disabled)
resource "aws_s3_bucket_versioning" "demo" {
  count  = var.s3_versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Upload a dummy object so the bucket is non-empty (makes cleanup more realistic)
resource "aws_s3_object" "demo_readme" {
  bucket  = aws_s3_bucket.demo.id
  key     = "README.txt"
  content = "This bucket is part of the COP310 compliance demo. It is intentionally non-compliant."
}

# ---------------------------------------------------------------------------
# Current account ID (used in bucket name to ensure global uniqueness)
# ---------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ===========================================================================
# 5. IAM USER — Overly Broad Policy + Access Key
#    [VIOLATION]  iam-policy-check (wildcard actions), iam-user-credentials-check
#    [DETECTED BY] Lab 1 (Config rules) + Lab 4 (Audit Manager evidence)
#    [REMEDIATED BY] Lab 2 (custom SSM doc to detach and replace policy)
# ===========================================================================

resource "aws_iam_user" "demo" {
  name = "${var.name_prefix}-demo-user"

  tags = {
    Name = "${var.name_prefix}-demo-iam-user"
  }
}

# ⚠️ [VIOLATION] Overly broad inline policy — full admin on everything
resource "aws_iam_user_policy" "demo_admin" {
  count = var.iam_policy_overly_broad ? 1 : 0
  name  = "${var.name_prefix}-overly-broad-policy"
  user  = aws_iam_user.demo.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "INTENTIONAL_FullAdminAccess"
        Effect    = "Allow"
        Action    = "*"
        Resource  = "*"
        Condition = {}
      }
    ]
  })
}

# Least-privilege replacement policy (used when the violation flag is turned off)
resource "aws_iam_user_policy" "demo_scoped" {
  count = var.iam_policy_overly_broad ? 0 : 1
  name  = "${var.name_prefix}-scoped-policy"
  user  = aws_iam_user.demo.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadOnlyS3Demo"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.demo.arn,
          "${aws_s3_bucket.demo.arn}/*"
        ]
      }
    ]
  })
}

# ⚠️ [VIOLATION] Programmatic access key — credentials that can be leaked
resource "aws_iam_user_login_profile" "demo" {
  count = var.iam_user_has_access_key ? 1 : 0
  user  = aws_iam_user.demo.name

  # Password generated by Terraform (you'd rotate this in a real scenario)
  pgp_key = "" # Empty = Terraform generates; for demo only

}

# Note: aws_iam_access_key is the actual programmatic key pair.
# We create it conditionally to demonstrate the violation.
resource "aws_iam_access_key" "demo" {
  count = var.iam_user_has_access_key ? 1 : 0
  user  = aws_iam_user.demo.name
}

# ===========================================================================
# 6. CLOUDWATCH LOG GROUP — No Retention (non-compliant in many frameworks)
#    [VIOLATION]  cloudwatch-log-group-retention-check
#    [DETECTED BY] Lab 1
# ===========================================================================

resource "aws_cloudwatch_log_group" "demo" {
  name              = "/cop310/${var.name_prefix}/demo-app"
  retention_in_days = var.log_group_retention_days # 0 = never expires

  tags = {
    Name = "${var.name_prefix}-demo-log-group"
  }
}
