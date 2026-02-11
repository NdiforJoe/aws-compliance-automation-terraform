###############################################################################
# main.tf — Lab 3: CloudTrail Lake for Security Investigations
#
# Deploys CloudTrail Lake event data store for SQL-based forensic analysis
# of AWS API activity, compliance investigations, and audit evidence
###############################################################################

# ===========================================================================
# 1. CLOUDTRAIL LAKE EVENT DATA STORE
# ===========================================================================

resource "aws_cloudtrail_event_data_store" "main" {
  name = "${var.name_prefix}-event-data-store"

  # Retention period (90 days for demo, up to 7 years for compliance)
  retention_period = var.retention_days

  # Termination protection (disabled for easy cleanup in demo)
  termination_protection_enabled = var.enable_termination_protection

  # Advanced event selectors - capture management events
  advanced_event_selector {
    name = "Log all management events"

    # Management events include API calls like:
    # - CreateBucket, PutBucketEncryption (S3)
    # - AuthorizeSecurityGroupIngress (EC2)
    # - PutUserPolicy (IAM)
    # - StartAutomationExecution (SSM)
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  # Optional: Capture data events for S3 (high volume, costs more)
  # Uncomment if you need to track S3 object-level operations
  # advanced_event_selector {
  #   name = "Log S3 data events"
  #   
  #   field_selector {
  #     field  = "eventCategory"
  #     equals = ["Data"]
  #   }
  #   
  #   field_selector {
  #     field  = "resources.type"
  #     equals = ["AWS::S3::Object"]
  #   }
  # }

  tags = {
    Name    = "${var.name_prefix}-event-data-store"
    Purpose = "Security investigations and compliance queries"
  }
}

# ===========================================================================
# 2. SQL QUERIES (CREATE MANUALLY IN CONSOLE - NOT SUPPORTED BY TERRAFORM)
# ===========================================================================

# Note: aws_cloudtrail_event_data_store_saved_query is not yet supported
# by Terraform AWS provider. You'll create these queries manually in the
# CloudTrail Lake Console after deployment.
#
# The SQL queries are provided in the outputs.tf file for easy copy/paste.
