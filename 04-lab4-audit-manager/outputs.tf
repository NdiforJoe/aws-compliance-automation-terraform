###############################################################################
# outputs.tf — Lab 4: AWS Audit Manager
#
# Outputs and step-by-step instructions for creating assessment in Console
###############################################################################

output "audit_evidence_bucket" {
  description = "S3 bucket for Audit Manager evidence storage"
  value       = aws_s3_bucket.audit_evidence.id
}

output "audit_evidence_bucket_arn" {
  description = "ARN of the evidence storage bucket"
  value       = aws_s3_bucket.audit_evidence.arn
}

output "audit_manager_role_arn" {
  description = "IAM role ARN for Audit Manager"
  value       = aws_iam_role.audit_manager.arn
}

output "audit_manager_console_url" {
  description = "URL to AWS Audit Manager Console"
  value       = "https://console.aws.amazon.com/auditmanager/home?region=${var.aws_region}#/assessments"
}

output "next_steps" {
  description = "Step-by-step instructions for completing Audit Manager setup"
  value       = <<-EOT
    ========================================================================
    Lab 4: AWS Audit Manager - Infrastructure Deployed!
    ========================================================================
    
    ✅ S3 Evidence Bucket: ${aws_s3_bucket.audit_evidence.id}
    ✅ IAM Role: ${aws_iam_role.audit_manager.name}
    ✅ Evidence Retention: 7 years (2,557 days)
    ✅ Encryption: AES256 enabled
    
    📋 Next Steps: Create Assessment in Console
    
    AWS Audit Manager has limited Terraform support. You'll create the
    assessment manually in the Console using the infrastructure deployed.
    
    ========================================================================
    STEP 1: Enable Audit Manager (First Time Only)
    ========================================================================
    
    1. Go to Audit Manager Console:
       https://console.aws.amazon.com/auditmanager/home?region=${var.aws_region}
    
    2. If this is your first time:
       - Click "Get started"
       - Click "Enable Audit Manager"
       - Select evidence storage: ${aws_s3_bucket.audit_evidence.id}
       - Click "Enable"
    
    ========================================================================
    STEP 2: Create Custom Framework
    ========================================================================
    
    1. In Audit Manager Console, click "Framework library" (left sidebar)
    
    2. Click "Create custom framework"
    
    3. Framework details:
       - Name: COP310-Compliance-Framework
       - Description: Custom framework for COP310 demo environment
       - Compliance type: Custom
    
    4. Add Control Set 1: "Detective Controls"
       
       Click "Add control set" → "Create new control set"
       - Control set name: Detective Controls
       - Click "Create"
       
       Add controls to this set:
       
       Control 1: Config Rule - Restricted SSH
       ────────────────────────────────────────
       - Control name: Restricted SSH Access
       - Description: Security groups should not allow unrestricted SSH
       - Testing information: Automated via AWS Config rule
       - Control type: Technical
       - Data source: AWS Config
       - Keyword: cop310-restricted-ssh
       
       Control 2: Config Rule - S3 Encryption
       ───────────────────────────────────────
       - Control name: S3 Bucket Encryption
       - Description: S3 buckets must have encryption enabled
       - Testing information: Automated via AWS Config rule
       - Control type: Technical
       - Data source: AWS Config
       - Keyword: cop310-s3-bucket-sse
       
       Control 3: Config Rule - S3 Versioning
       ───────────────────────────────────────
       - Control name: S3 Bucket Versioning
       - Description: S3 buckets must have versioning enabled
       - Testing information: Automated via AWS Config rule
       - Control type: Technical
       - Data source: AWS Config
       - Keyword: cop310-s3-versioning-enabled
    
    5. Add Control Set 2: "Corrective Controls"
       
       Click "Add control set" → "Create new control set"
       - Control set name: Corrective Controls
       - Click "Create"
       
       Add controls:
       
       Control 4: SSM Automation - Auto-Remediation
       ─────────────────────────────────────────────
       - Control name: Automated Remediation
       - Description: Config violations are automatically remediated via SSM
       - Testing information: Evidence from CloudTrail showing SSM executions
       - Control type: Technical
       - Data source: AWS CloudTrail
       - Keyword: StartAutomationExecution
    
    6. Add Control Set 3: "Investigative Controls"
       
       Click "Add control set" → "Create new control set"
       - Control set name: Investigative Controls
       - Click "Create"
       
       Add controls:
       
       Control 5: CloudTrail Lake - Forensic Analysis
       ──────────────────────────────────────────────
       - Control name: Security Event Investigation
       - Description: All API calls logged and queryable via CloudTrail Lake
       - Testing information: SQL queries demonstrating investigation capability
       - Control type: Technical
       - Data source: AWS CloudTrail
       - Keyword: AuthorizeSecurityGroupIngress
    
    7. Click "Create custom framework"
    
    ========================================================================
    STEP 3: Create Assessment
    ========================================================================
    
    1. In Audit Manager Console, click "Assessments" (left sidebar)
    
    2. Click "Create assessment"
    
    3. Assessment details:
       - Name: ${var.assessment_name}
       - Description: ${var.assessment_description}
       - Compliance standard: Select "COP310-Compliance-Framework" (your custom framework)
       - Assessment reports destination: ${aws_s3_bucket.audit_evidence.id}
    
    4. AWS account selection:
       - Select "Current AWS account"
       - Account ID: ${data.aws_caller_identity.current.account_id}
       - Account name: COP310-Demo
    
    5. AWS services:
       Select the services to include:
       - ✅ AWS Config
       - ✅ AWS CloudTrail
       - ✅ Amazon EC2
       - ✅ Amazon S3
       - ✅ AWS Systems Manager
    
    6. Assessment role:
       - Use existing role: ${aws_iam_role.audit_manager.name}
    
    7. Review and create:
       - Click "Create assessment"
    
    8. Wait 5-10 minutes for initial evidence collection
    
    ========================================================================
    STEP 4: View Assessment Dashboard
    ========================================================================
    
    1. Click on your assessment: "${var.assessment_name}"
    
    2. You'll see:
       - Control sets (Detective, Corrective, Investigative)
       - Controls (5 total)
       - Evidence collected (from Config, CloudTrail, SSM)
       - Compliance status (Compliant/Non-compliant per control)
    
    3. Click on a control to see:
       - Evidence items automatically collected
       - Compliance evaluation
       - Evidence source (Config rule, CloudTrail event, etc.)
    
    ========================================================================
    STEP 5: Generate Assessment Report
    ========================================================================
    
    1. In the assessment dashboard, click "Generate assessment report"
    
    2. Report details:
       - Report name: COP310-Assessment-Report-<date>
       - Description: Automated compliance evidence for COP310 demo
    
    3. Click "Generate report"
    
    4. Wait 2-3 minutes for generation
    
    5. Download the report:
       - Go to "Assessment reports" tab
       - Click on your report
       - Click "Download report"
    
    6. The report includes:
       - Executive summary
       - Control compliance status
       - Evidence collected per control
       - Timestamps and source attribution
    
    📸 Screenshots for Portfolio:
    
    1. Audit Manager dashboard (showing assessment created)
    2. Framework with 3 control sets (Detective, Corrective, Investigative)
    3. Assessment overview (showing 5 controls, evidence count)
    4. Control detail view (showing automated evidence from Config)
    5. Assessment report (PDF download)
    
    💡 What This Demonstrates:
    
    For Auditors:
    - Continuous evidence collection (not point-in-time)
    - Automated mapping of controls to evidence
    - Pre-compiled assessment reports
    - Audit readiness dashboard
    
    For GRC Teams:
    - SOC 2 / ISO 27001 evidence automation
    - Control effectiveness tracking
    - Compliance posture visibility
    - Evidence retention (7 years)
    
    For Security Teams:
    - Technical controls validated automatically
    - Integration with Config, CloudTrail, SSM
    - Proof of detective + corrective + investigative controls
    
    🎯 Expected Results:
    
    After initial evidence collection (5-10 minutes):
    - Control 1 (Restricted SSH): Compliant (after Lab 2 remediation)
    - Control 2 (S3 Encryption): Compliant (after Lab 2 remediation)
    - Control 3 (S3 Versioning): Compliant (after Lab 2 remediation)
    - Control 4 (Auto-Remediation): Evidence collected (SSM executions)
    - Control 5 (Forensic Analysis): Evidence collected (CloudTrail events)
    
    Total evidence items: 50+ (from Config + CloudTrail + SSM)
    
    Cost: ~$5/month for Audit Manager service
    ========================================================================
  EOT
}
