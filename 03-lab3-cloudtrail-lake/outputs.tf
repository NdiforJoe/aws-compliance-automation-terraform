###############################################################################
# outputs.tf — Lab 3: CloudTrail Lake for Security Investigations
#
# Outputs for event data store and query information
###############################################################################

output "event_data_store_arn" {
  description = "ARN of the CloudTrail Lake event data store"
  value       = aws_cloudtrail_event_data_store.main.arn
}

output "event_data_store_id" {
  description = "ID of the CloudTrail Lake event data store"
  value       = aws_cloudtrail_event_data_store.main.id
}

output "retention_period_days" {
  description = "Event retention period in days"
  value       = var.retention_days
}

output "saved_queries_sql" {
  description = "SQL queries to create manually in CloudTrail Lake Console (copy/paste these)"
  value = {
    "1_security_group_creation" = <<-SQL
      SELECT
        eventTime,
        userIdentity.principalId,
        userIdentity.arn,
        eventName,
        requestParameters,
        responseElements
      FROM ${aws_cloudtrail_event_data_store.main.id}
      WHERE
        eventName = 'CreateSecurityGroup'
        OR eventName = 'AuthorizeSecurityGroupIngress'
      ORDER BY eventTime DESC
    SQL

    "2_s3_configuration_changes" = <<-SQL
      SELECT
        eventTime,
        userIdentity.principalId,
        userIdentity.arn,
        eventName,
        requestParameters.bucketName,
        requestParameters
      FROM ${aws_cloudtrail_event_data_store.main.id}
      WHERE
        eventSource = 's3.amazonaws.com'
        AND (
          eventName LIKE 'PutBucket%'
          OR eventName = 'DeleteBucketEncryption'
          OR eventName = 'DeleteBucketPolicy'
        )
      ORDER BY eventTime DESC
    SQL

    "3_ssm_remediation_history" = <<-SQL
      SELECT
        eventTime,
        userIdentity.principalId,
        eventName,
        requestParameters.documentName,
        requestParameters.parameters,
        responseElements.automationExecutionId
      FROM ${aws_cloudtrail_event_data_store.main.id}
      WHERE
        eventSource = 'ssm.amazonaws.com'
        AND eventName = 'StartAutomationExecution'
      ORDER BY eventTime DESC
    SQL

    "4_iam_policy_changes" = <<-SQL
      SELECT
        eventTime,
        userIdentity.principalId,
        userIdentity.arn,
        eventName,
        requestParameters.userName,
        requestParameters.policyName,
        requestParameters.policyDocument
      FROM ${aws_cloudtrail_event_data_store.main.id}
      WHERE
        eventSource = 'iam.amazonaws.com'
        AND (
          eventName LIKE 'Put%Policy'
          OR eventName LIKE 'Attach%Policy'
          OR eventName LIKE 'Create%Policy'
        )
      ORDER BY eventTime DESC
    SQL

    "5_failed_api_calls" = <<-SQL
      SELECT
        eventTime,
        userIdentity.principalId,
        userIdentity.arn,
        eventSource,
        eventName,
        errorCode,
        errorMessage,
        sourceIPAddress
      FROM ${aws_cloudtrail_event_data_store.main.id}
      WHERE
        errorCode IS NOT NULL
        AND (
          errorCode = 'AccessDenied'
          OR errorCode = 'UnauthorizedOperation'
          OR errorCode LIKE '%Unauthorized%'
        )
      ORDER BY eventTime DESC
    SQL

    "6_resource_deletions" = <<-SQL
      SELECT
        eventTime,
        userIdentity.principalId,
        userIdentity.arn,
        eventSource,
        eventName,
        requestParameters,
        responseElements
      FROM ${aws_cloudtrail_event_data_store.main.id}
      WHERE
        eventName LIKE 'Delete%'
        OR eventName LIKE 'Terminate%'
        OR eventName LIKE 'Remove%'
      ORDER BY eventTime DESC
    SQL
  }
}

output "cloudtrail_lake_console_url" {
  description = "URL to CloudTrail Lake query editor in Console"
  value       = "https://console.aws.amazon.com/cloudtrail/home?region=${var.aws_region}#/lake/query"
}

output "next_steps" {
  description = "What to do after CloudTrail Lake deployment"
  value       = <<-EOT
    ========================================================================
    Lab 3: CloudTrail Lake - Deployed Successfully!
    ========================================================================
    
    ✅ Event Data Store: ${aws_cloudtrail_event_data_store.main.name}
    ✅ Retention Period: ${var.retention_days} days
    ✅ SQL Queries: 6 provided in outputs (create manually in Console)
    ✅ Event Collection: Started (capturing all management events)
    
    🔍 How CloudTrail Lake Works:
    
    1. CloudTrail captures ALL AWS API calls (who, what, when, from where)
    2. Events stored in Lake for SQL-based querying
    3. Run queries directly in Console (SQL provided in outputs)
    4. Get answers in seconds vs hours of log parsing
    
    📊 Running Your First Query:
    
    Step 1: Go to CloudTrail Lake Console
    ======================================
    https://console.aws.amazon.com/cloudtrail/home?region=${var.aws_region}#/lake/query
    
    Step 2: Copy a Query from Terraform Outputs
    ============================================
    Run: terraform output saved_queries_sql
    
    Copy one of the 6 SQL queries provided.
    
    Step 3: Paste and Run
    ======================
    1. Paste the SQL into the Query editor
    2. Click "Run query"
    3. View results showing:
       - Who performed the action
       - When it happened
       - What was changed
       - Full request/response details
    
    SELECT
      eventTime,
      userIdentity.principalId,
      userIdentity.arn,
      eventName,
      requestParameters
    FROM ${aws_cloudtrail_event_data_store.main.id}
    WHERE
      eventName = 'AuthorizeSecurityGroupIngress'
      AND requestParameters LIKE '%0.0.0.0/0%'
      AND requestParameters LIKE '%port 22%'
    ORDER BY eventTime DESC
    
    🎯 Investigation Scenarios:
    
    Scenario 1: Root Cause Analysis
    ================================
    Question: "Who created the security group with SSH 0.0.0.0/0?"
    
    Use Query: 1_security_group_creation
    
    Expected Result:
    - User: Terraform (via cop310 IAM role)
    - Time: When Lab 0 was deployed
    - Action: AuthorizeSecurityGroupIngress with 0.0.0.0/0
    
    Scenario 2: Remediation Audit Trail
    ====================================
    Question: "When did SSM Automation fix the violations?"
    
    Use Query: 3_ssm_remediation_history
    
    Expected Result:
    - Document: cop310-RevokeSecurityGroupIngress
    - Execution ID: [from Lab 2]
    - Trigger: Config remediation action
    - Time: Within 2 seconds of detection
    
    Scenario 3: Compliance Timeline
    ===============================
    Question: "Show me all S3 bucket changes in the last 90 days"
    
    Use Query: 2_s3_configuration_changes
    
    Expected Result:
    - PutBucketEncryption events (from remediation)
    - PutBucketVersioning events (from remediation)
    - Who: SSM Automation (via cop310-remediation-role)
    
    Scenario 4: Failed Access Attempts
    ===================================
    Question: "Were there any unauthorized access attempts?"
    
    Use Query: 5_failed_api_calls
    
    Expected Result:
    - AccessDenied errors (if any)
    - Unauthorized operations
    - Potential security incidents
    
    📸 Screenshots for Portfolio:
    
    1. Event Data Store dashboard (showing event count, retention)
    2. Query editor interface
    3. Query results - "Who created the security group?"
    4. Query results - "SSM remediation execution history"
    5. Query results - "S3 configuration changes"
    
    💡 Pro Tips:
    
    - Events appear within 5-15 minutes of API call
    - Query up to 90 days of history (per retention setting)
    - Use LIMIT clause for large result sets
    - Export results to CSV for reporting
    - Share queries with security team
    
    🎯 Common SQL Patterns:
    
    # Find specific event types
    WHERE eventName = 'CreateBucket'
    
    # Filter by time range
    WHERE eventTime > '2026-02-01'
    
    # Search in nested JSON
    WHERE requestParameters.bucketName = 'my-bucket'
    
    # Multiple conditions
    WHERE eventSource = 's3.amazonaws.com'
      AND eventName LIKE 'Put%'
      AND userIdentity.principalId LIKE '%terraform%'
    
    # Group by user
    SELECT
      userIdentity.principalId,
      COUNT(*) as event_count
    FROM ${aws_cloudtrail_event_data_store.main.id}
    GROUP BY userIdentity.principalId
    
    Cost: ~$2.50/month (90 days retention, management events only)
    ========================================================================
  EOT
}
