# Architecture Diagrams

This folder contains visual diagrams for the COP310 project.

## Diagrams Planned

- `overall-architecture.png` — End-to-end compliance pipeline
- `lab1-config-flow.png` — AWS Config detection workflow
- `lab2-remediation-flow.png` — SSM Automation remediation workflow
- `lab3-cloudtrail-query.png` — CloudTrail Lake investigation example
- `lab4-audit-manager.png` — Audit Manager framework and evidence

## Screenshots to Capture

As you progress through the labs, capture these screenshots:

**CI/CD & Deployment:**
- [x] `ci-pipeline-passing.png` - GitHub Actions all checks passing
- [x] `terraform-plan-lab0.png` - Terraform plan showing 15 resources to create
- [x] `terraform-apply-lab0.png` - Terraform apply output with compliance summary

**AWS Console Violations:**
- [x] `ec2-sg-open-ssh.png` - Security group inbound rules showing SSH 0.0.0.0/0
- [x] `ebs-unencrypted.png` - EBS volume details showing "Encrypted: No"
- [x] `s3-no-encryption.png` - S3 bucket Properties showing encryption disabled
- [x] `s3-no-versioning.png` - S3 bucket Properties showing versioning disabled
- [x] `s3-no-public-access-block.png` - S3 bucket Permissions showing PAB off
- [x] `iam-wildcard-policy.png` - IAM user inline policy JSON (Action:*, Resource:*)

### Lab 1 (AWS Config) - Captured ✅

**Deployment:**
- [x] `terraform-apply-lab1.png` - Terraform output showing 17 Config resources created

**Config Monitoring:**
- [x] `config-dashboard.png` - Dashboard showing 50+ rules (12 cop310 + Security Hub integration)
- [x] `config-rules-list.png` - Filtered view of 12 cop310-* Config rules
- [x] `config-rule-ssh-noncompliant.png` - Rule detail showing NON_COMPLIANT security group
- [x] `config-resource-timeline.png` - Resource timeline with 3 compliance violations detected

**Total Lab 1 screenshots: 5**

### Lab 2 (Auto-Remediation) - Captured ✅

**Deployment:**
- [x] `terraform-plan-lab2.png` - Terraform plan showing 11 remediation resources
- [x] `terraform-apply-lab2.png` - Deployment complete with SSM documents + Config remediation

**Remediation Evidence:**
- [x] `ssm-automation-success.png` - 2 SSM executions showing Success status (<2 sec each)
- [x] `config-rule-after-remediation.png` - Config rule now COMPLIANT with remediation action
- [x] `sg-after-remediation.png` - Security group with NO inbound rules (SSH revoked)
- [x] `s3-after-remediation.png` - S3 bucket with SSE-S3 encryption + versioning enabled

**Total Lab 2 screenshots: 6**

### Lab 3 (CloudTrail Lake) - Captured ✅

**Deployment:**
- [x] `terraform-apply-lab3.png` - CloudTrail Lake event data store deployed

**Infrastructure:**
- [x] `cloudtrail-lake-dashboard.png` - Event data store with 90-day retention

**Query Results (SQL-based investigations):**
- [x] `query-results-security-group.png` - Root cause: Who created SSH 0.0.0.0/0 rule
- [x] `query-results-ssm-remediation.png` - Remediation audit trail (SSM executions)
- [x] `query-results-s3-changes.png` - S3 bucket configuration timeline

**Total Lab 3 screenshots: 5**

**Investigation Demonstrated:**
- Root cause analysis: Identified who created non-compliant security group
- Remediation verification: Tracked SSM Automation executions
- Compliance timeline: Showed S3 bucket hardening events
- Query time: <5 seconds per investigation

### Lab 4 (Audit Manager) - Captured ✅

**Deployment:**
- [x] `terraform-apply-lab4.png` - S3 evidence bucket + IAM role deployed

**Assessment & Framework:**
- [x] `audit-manager-assessment-dashboard.png` - 23 evidence items, 5 controls, 3 control sets
- [x] `audit-manager-framework.png` - Custom framework (Detective, Corrective, Investigative)
- [x] `audit-manager-control-evidence.png` - Control with Config/CloudTrail evidence

**Total Lab 4 screenshots: 4**

**Evidence Collected:**
- Detective Controls: 15 items (Config rule evaluations)
- Corrective Controls: 2 items (SSM executions)  
- Investigative Controls: 6 items (CloudTrail events)
- Total: 23+ automated evidence items

**Audit Preparation Impact:**
- Traditional: 2-3 weeks manual evidence gathering
- Automated: 3 minutes to generate complete report
- Time savings: 99% reduction
## Creating Diagrams

**Recommended tools:**
- **Draw.io** (diagrams.net) — Free, web-based
- **Lucidchart** — Professional cloud architecture diagrams
- **PlantUML** — Code-based diagrams (can be versioned in Git)
- **Mermaid** — Markdown-native diagrams (GitHub renders them)

## Mermaid Example

GitHub renders Mermaid diagrams directly in markdown. Add this to any README:

\`\`\`mermaid
graph LR
    A[Non-Compliant<br/>Resources] --> B[AWS Config<br/>Rules]
    B --> C{Compliant?}
    C -->|No| D[SSM Automation]
    D --> E[Remediated State]
    C -->|Yes| F[Continue Monitoring]
\`\`\`

## Embedding in READMEs

\`\`\`markdown
![Architecture Overview](diagrams/overall-architecture.png)
\`\`\`

## Portfolio Tips

- Take screenshots at **1920x1080** or higher for clarity
- Use **PNG format** for screenshots (smaller file size than JPEG for diagrams)
- **Annotate** screenshots with arrows/text if helpful (use draw.io or Snagit)
- **Before/After** pairs are especially powerful for portfolio presentations
