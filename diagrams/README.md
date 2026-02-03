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

### Lab 1 (AWS Config)
- [ ] Config Dashboard showing non-compliant resources
- [ ] Config Rule evaluation results
- [ ] Conformance pack status

### Lab 2 (Auto-Remediation)
- [ ] SSM Automation execution in progress
- [ ] Security Group after remediation (rule removed)
- [ ] S3 Bucket after remediation (encryption enabled)

### Lab 3 (CloudTrail Lake)
- [ ] CloudTrail Lake SQL query interface
- [ ] Query results showing who disabled encryption

### Lab 4 (Audit Manager)
- [ ] Custom framework definition
- [ ] Assessment in progress
- [ ] Evidence report export

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
