###############################################################################
# outputs.tf — Lab 1: AWS Config Foundations
#
# Outputs for Config resources and monitoring information
###############################################################################

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.main.name
}

output "config_recorder_status" {
  description = "Status of the AWS Config recorder"
  value       = var.enable_config_recorder ? "RECORDING" : "STOPPED"
}

output "config_bucket_name" {
  description = "S3 bucket name for Config snapshots"
  value       = aws_s3_bucket.config.id
}

output "config_bucket_arn" {
  description = "S3 bucket ARN for Config snapshots"
  value       = aws_s3_bucket.config.arn
}

output "config_role_arn" {
  description = "IAM role ARN for Config service"
  value       = aws_iam_role.config.arn
}

output "config_rules_deployed" {
  description = "List of deployed Config rule names"
  value = [
    aws_config_config_rule.restricted_ssh.name,
    aws_config_config_rule.encrypted_volumes.name,
    aws_config_config_rule.s3_bucket_sse.name,
    aws_config_config_rule.s3_public_read.name,
    aws_config_config_rule.s3_public_write.name,
    aws_config_config_rule.s3_versioning.name,
    aws_config_config_rule.iam_no_wildcard.name,
    aws_config_config_rule.iam_unused_credentials.name,
    aws_config_config_rule.cloudwatch_log_encryption.name,
    aws_config_config_rule.ec2_detailed_monitoring.name,
    aws_config_config_rule.root_mfa.name,
    aws_config_config_rule.iam_password_policy.name,
  ]
}

output "config_rules_count" {
  description = "Total number of Config rules deployed"
  value       = 12
}

output "aws_console_config_dashboard" {
  description = "URL to AWS Config dashboard in Console"
  value       = "https://console.aws.amazon.com/config/home?region=${var.aws_region}#/dashboard"
}

output "aws_console_config_rules" {
  description = "URL to AWS Config rules in Console"
  value       = "https://console.aws.amazon.com/config/home?region=${var.aws_region}#/rules"
}

output "next_steps" {
  description = "What to do after Config deployment"
  value       = <<-EOT
    ========================================================================
    Lab 1: AWS Config Foundations - Deployed Successfully!
    ========================================================================
    
    ✅ Config Recorder: ${var.enable_config_recorder ? "RECORDING" : "STOPPED"}
    ✅ Config Rules: 12 deployed
    ✅ S3 Bucket: ${aws_s3_bucket.config.id}
    ✅ Snapshot Frequency: ${var.config_snapshot_frequency}
    
    📊 Next Steps:
    
    1. Wait 5-10 minutes for initial Config evaluation to complete
    
    2. Check Config Dashboard:
       - Open: https://console.aws.amazon.com/config/home?region=${var.aws_region}#/dashboard
       - Look for: Compliance status (Compliant/Non-Compliant counts)

    3. View Non-Compliant Resources:
       - Open: https://console.aws.amazon.com/config/home?region=${var.aws_region}#/rules
       - Click on any rule showing NON_COMPLIANT status
       - Drill down to see which resources are violating
    
    4. Redeploy Lab 0 Resources (if destroyed):
       cd ../00-presetup
       terraform apply
       
       Wait another 5-10 minutes for Config to evaluate the new resources
    
    5. Take Screenshots for Portfolio:
       - Config Dashboard showing compliance summary
       - Individual rule details (e.g., restricted-ssh showing NON_COMPLIANT)
       - Resource timeline showing configuration changes
    
    📸 Portfolio Evidence:
    Config is now continuously monitoring your AWS account. Any new
    resources will be evaluated against these 12 rules automatically.
    
    Cost: ~$0.06/day for Config rules in one region
    ========================================================================
  EOT
}
