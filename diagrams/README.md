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

### Pre-Setup (Lab 0)
- [ ] Terraform plan output
- [ ] Terraform apply output with compliance summary
- [ ] EC2 Security Group showing 0.0.0.0/0 SSH rule
- [ ] S3 Bucket properties (no encryption, no versioning)
- [ ] IAM User with wildcard policy
- [ ] GitHub Actions passing all checks

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
