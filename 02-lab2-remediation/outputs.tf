###############################################################################
# outputs.tf — Lab 2: Auto-Remediation with SSM Automation
#
# Outputs for remediation resources and testing information
###############################################################################

output "remediation_role_arn" {
  description = "IAM role ARN for SSM Automation remediation"
  value       = aws_iam_role.remediation.arn
}

output "ssm_documents_created" {
  description = "List of SSM Automation documents deployed"
  value = [
    aws_ssm_document.revoke_sg_ingress.name,
    aws_ssm_document.enable_s3_encryption.name,
    aws_ssm_document.enable_s3_versioning.name,
    aws_ssm_document.attach_s3_public_access_block.name,
  ]
}

output "remediation_configurations" {
  description = "Config rules with automatic remediation enabled"
  value = {
    restricted_ssh   = aws_config_remediation_configuration.revoke_sg_ingress.config_rule_name
    s3_encryption    = aws_config_remediation_configuration.enable_s3_encryption.config_rule_name
    s3_versioning    = aws_config_remediation_configuration.enable_s3_versioning.config_rule_name
    s3_public_access = aws_config_remediation_configuration.attach_s3_pab.config_rule_name
  }
}

output "automatic_remediation_enabled" {
  description = "Whether automatic remediation is enabled"
  value       = var.enable_automatic_remediation
}

output "ssm_console_url" {
  description = "URL to view SSM Automation executions in Console"
  value       = "https://console.aws.amazon.com/systems-manager/automation/executions?region=${var.aws_region}"
}

output "next_steps" {
  description = "What to do after Lab 2 deployment"
  value       = <<-EOT
    ========================================================================
    Lab 2: Auto-Remediation - Deployed Successfully!
    ========================================================================
    
    ✅ SSM Automation Documents: 4 remediation runbooks created
    ✅ Config Remediation Actions: 4 rules configured for auto-fix
    ✅ Automatic Remediation: ${var.enable_automatic_remediation ? "ENABLED" : "DISABLED"}
    ✅ IAM Role: Remediation permissions configured
    
    🔄 How Auto-Remediation Works:
    
    1. Config detects violation (e.g., SSH from 0.0.0.0/0)
    2. Config triggers SSM Automation document
    3. SSM executes remediation (revokes the rule)
    4. Config re-evaluates resource (should now be COMPLIANT)
    5. Total time: ~90 seconds from detection to fix
    
    📊 Testing Auto-Remediation:
    
    Method 1: Trigger Existing Violations
    ======================================
    Config has already detected violations from Lab 0. If automatic 
    remediation is enabled, fixes should begin within 5-10 minutes.
    
    Watch for:
    → SSM executions starting (check SSM Console)
    → Resources becoming COMPLIANT (check Config Dashboard)
    → Security group rules being revoked
    → S3 buckets gaining encryption/versioning
    
    Method 2: Create New Violation
    ================================
    Test real-time remediation by creating a new violation:
    
    # Create a test security group with open SSH
    aws ec2 create-security-group \
      --group-name test-remediation \
      --description "Test auto-remediation" \
      --vpc-id $(cd ../00-presetup && terraform output -raw vpc_id)
    
    aws ec2 authorize-security-group-ingress \
      --group-name test-remediation \
      --protocol tcp \
      --port 22 \
      --cidr 0.0.0.0/0
    
    Then wait 5-10 minutes and check:
    → Config detects the violation
    → SSM Automation executes
    → SSH rule is automatically revoked
    
    🔍 Monitoring Remediation:
    
    SSM Console:
       URL: https://console.aws.amazon.com/systems-manager/automation/executions?region=${var.aws_region}
       Look for: Execution status (InProgress -> Success)
       View: Execution details, steps, outputs

    Config Console:
       URL: https://console.aws.amazon.com/config/home?region=${var.aws_region}#/rules
       Look for: Resources changing from NON_COMPLIANT -> COMPLIANT
       Timeline: View remediation actions in resource history
    
    📸 Screenshots for Portfolio:
    
    1. SSM Automation executions (showing "Success" status)
    2. Config resource timeline (before → remediation → after)
    3. Security group rules (before: 0.0.0.0/0 → after: rule removed)
    4. S3 bucket properties (before: no encryption → after: AES256 enabled)
    
    ⚙️ Remediation Configured For:
    
    → Security Groups: Auto-revoke SSH from 0.0.0.0/0
    → S3 Buckets: Auto-enable encryption (AES256)
    → S3 Buckets: Auto-enable versioning
    → S3 Buckets: Auto-attach Public Access Block
    
    💡 Pro Tip:
    
    If automatic remediation is too aggressive for your demo, you can 
    disable it and trigger remediation manually:
    
    # Disable automatic remediation
    terraform apply -var="enable_automatic_remediation=false"
    
    # Manually trigger remediation from Config Console:
    # Config → Rules → Select rule → Actions → Remediate
    
    🎯 Expected Results:
    
    Within 10-15 minutes of deployment:
    → 4+ SSM executions should complete
    → Security group should be compliant (SSH rule revoked)
    → S3 bucket should be compliant (encryption + versioning enabled)
    → Config dashboard compliance score should increase
    
    Cost: ~$0.02/day for SSM executions (~$0.60/month)
    ========================================================================
  EOT
}
