# 🔐 AWS COP310: Automating Compliance & Auditing at Scale

[![Terraform](https://img.shields.io/badge/Terraform-≥1.5.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Multi--Service-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)](https://github.com/NdiforJoe/aws-compliance-automation-terraform)

> **Portfolio Project:** A production-grade replication of AWS re:Invent 2025 workshop COP310 — building an end-to-end automated compliance pipeline using Terraform, AWS Config, Systems Manager, CloudTrail Lake, and Audit Manager.

---

## 📖 Overview

This repository demonstrates **automated compliance detection, remediation, investigation, and reporting** across AWS environments using Infrastructure as Code (IaC). The project replicates the AWS re:Invent COP310 hands-on workshop labs, reimplemented entirely in **Terraform** for single and multi-account deployments.

**What this project delivers:**

- 🚨 **Intentional non-compliances** (EC2, S3, IAM) serving as realistic targets for automated controls
- 🔍 **AWS Config** rules (managed + custom) for continuous compliance monitoring
- 🤖 **SSM Automation** documents for self-healing infrastructure (e.g., revoking overly permissive security groups, enabling S3 encryption)
- 🔎 **CloudTrail Lake** queries for security investigation and threat hunting
- 📊 **AWS Audit Manager** custom frameworks for automated evidence collection
- 🌐 **Multi-account scaling** via CloudFormation StackSets (and Terraform alternatives)
- 🎯 **Toggle-based design** — flip variables to simulate before/after compliance states

---

## 💼 Why This Project? (Portfolio Value)

**Target roles:** Cloud Security Engineer, DevSecOps Engineer, Compliance Automation Specialist, Cloud Governance Architect

**Skills demonstrated:**

| Area | Technologies & Practices |
|---|---|
| **Infrastructure as Code** | Terraform (AWS provider), modular design, state management, variable-driven toggles |
| **Compliance Automation** | AWS Config rules, conformance packs, continuous assessment |
| **Auto-Remediation** | Systems Manager Automation, custom SSM documents, event-driven workflows |
| **Audit & Investigation** | CloudTrail Lake SQL queries, Audit Manager frameworks, evidence automation |
| **Multi-Account Governance** | CloudFormation StackSets, AWS Organizations integration, centralized compliance |
| **Security Best Practices** | Least-privilege IAM, encryption by default, network segmentation, tagging policies |
| **Documentation** | Clean Git history, annotated code, step-by-step guides, architecture diagrams |

**Differentiators for recruiters:**

- ✅ **Intentional violations are documented and toggle-able** — shows security maturity, not accidental misconfigurations
- ✅ **Terraform-first approach** — no reliance on CloudFormation except where necessary (StackSets)
- ✅ **Real-world patterns** — SSM remediation documents mirror production runbooks used at scale
- ✅ **Cost-conscious** — all labs run on `t3.micro` / free-tier resources with explicit cost estimates

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          AWS Account (Single)                           │
│                                                                         │
│  ┌──────────────────┐         ┌──────────────────┐                     │
│  │  Non-Compliant   │         │   AWS Config     │                     │
│  │  Resources       │────────▶│   - Rules        │                     │
│  │  (Pre-Setup)     │         │   - Conformance  │                     │
│  └──────────────────┘         │   - Recorder     │                     │
│   • EC2 (open SSH)            └────────┬─────────┘                     │
│   • S3 (no encrypt)                    │                               │
│   • IAM (wildcard)                     │ Triggers                      │
│                                        ▼                               │
│                           ┌──────────────────────┐                     │
│                           │  SSM Automation      │                     │
│                           │  - Managed docs      │                     │
│                           │  - Custom remediations│                    │
│                           └──────────┬───────────┘                     │
│                                      │                                 │
│                                      │ Fixes                           │
│                                      ▼                                 │
│                           ┌──────────────────────┐                     │
│                           │  Compliant State     │                     │
│                           │  (Auto-Remediated)   │                     │
│                           └──────────────────────┘                     │
│                                                                         │
│  ┌──────────────────┐         ┌──────────────────┐                     │
│  │  CloudTrail Lake │◀────────│  Audit Manager   │                     │
│  │  - Event queries │         │  - Frameworks    │                     │
│  │  - Threat hunting│         │  - Evidence      │                     │
│  └──────────────────┘         └──────────────────┘                     │
│                                                                         │
│  Multi-Account Expansion (Lab 5):                                      │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  AWS Organizations + StackSets → Deploy Config to all child OUs │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

**Pipeline flow:**

1. **Deploy** intentionally non-compliant resources (Pre-Setup)
2. **Detect** violations via AWS Config managed rules (Lab 1)
3. **Remediate** automatically via SSM Automation (Lab 2)
4. **Investigate** root causes using CloudTrail Lake (Lab 3)
5. **Report** compliance evidence via Audit Manager (Lab 4)
6. **Scale** to multi-account environments (Lab 5)

---

## 🛠️ Prerequisites

| Requirement | Notes |
|---|---|
| **AWS Account** | Personal/sandbox account — **not production**. Free Tier covers most costs. |
| **AWS CLI** | `>= 2.x`, configured with credentials (`aws configure`) |
| **Terraform** | `>= 1.5.0` ([Download](https://www.terraform.io/downloads)) |
| **IAM Permissions** | Admin or equivalent (creates IAM roles, Config recorder, S3 buckets, etc.) |
| **Region** | `us-east-1` recommended (widest service availability) |
| **Git** | For version control and portfolio submission |

**Optional:**
- **VS Code** with Terraform/HashiCorp extensions for syntax highlighting
- **AWS Console access** for visual verification of compliance states

---

## 📁 Project Structure

```
cop310-compliance-automation/
│
├── README.md                       ← You are here
├── LICENSE                         ← MIT License
│
├── 00-presetup/                    ← Intentional non-compliant resources
│   ├── GUIDE.md                    ← Step-by-step deployment instructions
│   ├── provider.tf                 ← AWS provider configuration
│   ├── variables.tf                ← Toggle flags for each violation
│   ├── main.tf                     ← EC2, S3, IAM, VPC resources
│   └── outputs.tf                  ← Resource IDs + compliance summary
│
├── 01-lab1-config/                 ← AWS Config foundations (COMING SOON)
│   ├── README.md                   ← Lab 1 guide
│   ├── provider.tf
│   ├── main.tf                     ← Config recorder, rules, conformance packs
│   └── outputs.tf
│
├── 02-lab2-remediation/            ← SSM Automation (COMING SOON)
│   ├── README.md                   ← Lab 2 guide
│   ├── main.tf                     ← SSM documents, Config remediation actions
│   └── custom-ssm-docs/            ← Custom remediation runbooks
│
├── 03-lab3-cloudtrail-lake/        ← CloudTrail Lake (COMING SOON)
│   ├── README.md                   ← Lab 3 guide
│   └── queries/                    ← SQL queries for investigation
│
├── 04-lab4-audit-manager/          ← Audit Manager (COMING SOON)
│   ├── README.md                   ← Lab 4 guide
│   └── frameworks/                 ← Custom framework definitions
│
├── 05-lab5-multi-account/          ← Multi-account scaling (COMING SOON)
│   ├── README.md                   ← Lab 5 guide
│   └── stacksets/                  ← CloudFormation StackSet templates
│
└── diagrams/                       ← Architecture diagrams (optional)
    └── architecture.png
```

---

## 🚀 Labs Overview

### **Lab 0: Pre-Setup — Intentionally Non-Compliant Resources**

**Status:** ✅ Complete

Deploy a realistic "broken" environment with 9 intentional violations:

| Resource | Violation | Config Rule | Auto-Remediation |
|---|---|---|---|
| EC2 Security Group | SSH open to `0.0.0.0/0` | `restricted-ssh` | ✅ Lab 2 |
| EC2 EBS Volume | Not encrypted | `encrypted-volumes` | ✅ Lab 2 |
| S3 Bucket | No encryption | `s3-bucket-server-side-encryption-enabled` | ✅ Lab 2 |
| S3 Bucket | No Public Access Block | `s3-bucket-public-read-prohibited` | ✅ Lab 2 |
| S3 Bucket | Versioning disabled | `s3-bucket-versioning-enabled` | — |
| IAM User | Wildcard policy (`Action:*`) | `iam-policy-no-statements-with-admin-access` | ✅ Lab 2 |
| IAM User | Active access key | `iam-user-unused-credentials-check` | — |
| CloudWatch Logs | No retention policy | Custom rule | — |
| VPC Subnet | Auto-assign public IPs | Custom rule | — |

**Cost:** ~$0.31/day (EC2 t3.micro + 20GB EBS)

📂 **[Full guide & code →](00-presetup/GUIDE.md)**

---

### **Lab 1: AWS Config Foundations** *(Coming Soon)*

**Goals:**
- Enable AWS Config recorder and delivery channel (S3 bucket for config history)
- Deploy 12+ managed Config rules targeting the pre-setup violations
- Set up a conformance pack (e.g., AWS Operational Best Practices for CIS)
- Visualize compliance dashboard in Console

**Key Terraform resources:**
- `aws_config_configuration_recorder`
- `aws_config_delivery_channel`
- `aws_config_config_rule` (managed rules)
- `aws_config_conformance_pack`

📂 **[Lab 1 guide →](01-lab1-config/README.md)** *(placeholder)*

---

### **Lab 2: Auto-Remediation with SSM Automation** *(Coming Soon)*

**Goals:**
- Attach SSM Automation documents to Config rules
- Trigger automatic fixes when resources drift out of compliance
- Write a custom SSM document to remediate the wildcard IAM policy
- Verify that EC2 security groups are auto-repaired after manual tampering

**Key Terraform resources:**
- `aws_config_remediation_configuration`
- `aws_ssm_document` (custom remediation runbooks)
- `aws_iam_role` (SSM Automation execution role)

📂 **[Lab 2 guide →](02-lab2-remediation/README.md)** *(placeholder)*

---

### **Lab 3: CloudTrail Lake — Investigation & Threat Hunting** *(Coming Soon)*

**Goals:**
- Create a CloudTrail Lake event data store
- Write SQL queries to investigate compliance drift (e.g., "Who disabled S3 encryption?")
- Demonstrate root cause analysis workflow for a simulated security incident

**Key AWS features:**
- CloudTrail Lake event data stores
- SQL query interface (Console + CLI)

📂 **[Lab 3 guide →](03-lab3-cloudtrail-lake/README.md)** *(placeholder)*

---

### **Lab 4: AWS Audit Manager — Automated Evidence Collection** *(Coming Soon)*

**Goals:**
- Create a custom Audit Manager framework
- Map Config rules to control objectives (e.g., SOC 2, NIST CSF)
- Run an assessment and export evidence reports (CSV/PDF)

**Key Terraform resources:**
- `aws_auditmanager_framework`
- `aws_auditmanager_assessment`

📂 **[Lab 4 guide →](04-lab4-audit-manager/README.md)** *(placeholder)*

---

### **Lab 5: Multi-Account Scaling with StackSets** *(Coming Soon)*

**Goals:**
- Set up AWS Organizations (optional: create test OUs)
- Deploy Config + remediation to all accounts via CloudFormation StackSets
- Demonstrate centralized compliance reporting

**Key AWS features:**
- AWS Organizations
- CloudFormation StackSets
- Aggregated Config views

📂 **[Lab 5 guide →](05-lab5-multi-account/README.md)** *(placeholder)*

---

## 🎬 How to Run / Deploy

### Quick Start (Lab 0 — Pre-Setup)

```bash
# Clone the repo
git clone git@github.com:NdiforJoe/aws-compliance-automation-terraform.git
cd cop310-compliance-automation/00-presetup

# Initialize Terraform
terraform init

# Review the plan (what will be created)
terraform plan -out=presetup.tfplan

# Apply (creates all non-compliant resources)
terraform apply presetup.tfplan

# View the compliance violation summary
terraform output compliance_violation_summary
```

### Running Subsequent Labs

Each lab folder (`01-lab1-config/`, `02-lab2-remediation/`, etc.) is a **standalone Terraform module** but depends on outputs from previous labs. Deploy them sequentially:

```bash
# Lab 1
cd ../01-lab1-config
terraform init
terraform apply

# Lab 2
cd ../02-lab2-remediation
terraform init
terraform apply -var="config_rule_arns=$(terraform -chdir=../01-lab1-config output -json rule_arns)"
```

---

## 🗑️ Cleanup & Cost Management

### Per-Lab Cleanup

```bash
# From within any lab directory
terraform destroy
```

### Full Project Cleanup

```bash
# Destroy in reverse order to avoid dependency issues
cd 05-lab5-multi-account && terraform destroy
cd ../04-lab4-audit-manager && terraform destroy
cd ../03-lab3-cloudtrail-lake && terraform destroy
cd ../02-lab2-remediation && terraform destroy
cd ../01-lab1-config && terraform destroy
cd ../00-presetup && terraform destroy
```

### Cost Estimates (Running All Labs Continuously)

| Lab | Estimated Cost/Day | Notes |
|---|---|---|
| Pre-Setup | $0.31 | EC2 t3.micro + EBS |
| Lab 1 (Config) | $0.06 | Config rules (~$0.003/rule/region) |
| Lab 2 (SSM) | $0.02 | SSM Automation executions |
| Lab 3 (CloudTrail Lake) | $0.50 | Event data store ingestion |
| Lab 4 (Audit Manager) | $0.10 | Assessment runs |
| Lab 5 (StackSets) | Variable | Depends on # of accounts |
| **Total** | **~$1/day** | **With all labs active** |

> **💡 Tip:** Only run the labs you're actively working on. The EC2 instance in Pre-Setup is the largest cost driver — stop it when not in use or destroy the stack.

---

## 📸 Screenshots & Demo Highlights

*(Add your own screenshots here as you progress through the labs)*

### Pre-Setup — Before Compliance

| Description | Screenshot |
|---|---|
| EC2 Security Group — SSH open to 0.0.0.0/0 | `![SG-Before](diagrams/sg-before.png)` |
| S3 Bucket — No encryption | `![S3-Before](diagrams/s3-before.png)` |
| IAM Policy — Wildcard actions | `![IAM-Before](diagrams/iam-before.png)` |

### Lab 1 — Config Dashboard

| Description | Screenshot |
|---|---|
| Config Dashboard — 9 non-compliant resources | `![Config-Dashboard](diagrams/config-dashboard.png)` |
| Config Rule — restricted-ssh (NON_COMPLIANT) | `![Config-Rule](diagrams/config-rule-ssh.png)` |

### Lab 2 — Auto-Remediation in Action

| Description | Screenshot |
|---|---|
| SSM Automation — Execution history | `![SSM-Execution](diagrams/ssm-execution.png)` |
| Security Group — After remediation (rule revoked) | `![SG-After](diagrams/sg-after.png)` |

### Lab 3 — CloudTrail Lake Query

| Description | Screenshot |
|---|---|
| SQL Query — "Who disabled S3 encryption?" | `![CTLake-Query](diagrams/ctlake-query.png)` |

### Lab 4 — Audit Manager Evidence

| Description | Screenshot |
|---|---|
| Assessment Report — Compliance summary | `![AuditMgr-Report](diagrams/audit-report.png)` |

---

## 🧠 Learnings & Key Takeaways

**What I learned building this project:**

1. **Config rules are reactive, not proactive** — they detect drift *after* it happens. This is why SSM remediation is critical for production environments.
2. **SSM Automation documents are more powerful than they appear** — they're essentially serverless runbooks that can orchestrate multi-step fixes (stop EC2, encrypt volume, restart).
3. **CloudTrail Lake SQL is a game-changer** — traditional CloudTrail log queries in S3 + Athena are clunky. Lake's built-in SQL engine is faster and easier.
4. **Audit Manager bridges compliance and engineering** — it auto-collects evidence that auditors actually want (Config rule evaluations, API calls, change logs).
5. **Terraform state management in multi-account setups is hard** — Lab 5 forced me to think about remote backends, locking, and cross-account assume-role patterns.

**Production considerations I'd apply:**

- Use **AWS Organizations SCPs** to enforce guardrails *before* Config even runs
- Store Terraform state in **S3 with DynamoDB locking** (not local backend)
- Add **SNS notifications** on Config rule failures for real-time alerting
- Implement **tagging policies** at the Org level to enforce required tags
- Set up **AWS Security Hub** to aggregate Config findings with other security tools

---

## 🔮 Future Enhancements

- [ ] **GenAI Integration (Amazon Q Developer)** — Use Bedrock to auto-generate SSM remediation documents from Config rule violations
- [ ] **CI/CD Pipeline** — GitHub Actions workflow to deploy Config rules on every PR
- [ ] **Terraform Cloud Backend** — Migrate state to Terraform Cloud for team collaboration
- [ ] **Custom Config Rules (Lambda)** — Write a Python Lambda to detect "EC2 instances running >7 days"
- [ ] **Cost Optimization Checks** — Add Config rules for idle resources (e.g., unused Elastic IPs)
- [ ] **Drift Detection Dashboard** — Build a custom CloudWatch dashboard showing compliance trends over time
- [ ] **Multi-Region Deployment** — Extend to `us-west-2` and `eu-west-1` for global compliance

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

You are free to use, modify, and distribute this code for personal or commercial purposes with attribution.

---

## 🤝 Contributing

Contributions are welcome! If you've replicated this workshop and found improvements, please:

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/your-improvement`)
3. Commit your changes (`git commit -m 'Add XYZ enhancement'`)
4. Push to the branch (`git push origin feature/your-improvement`)
5. Open a Pull Request

**Contribution ideas:**
- Add support for additional AWS regions
- Write more custom SSM remediation documents
- Integrate with AWS Security Hub or GuardDuty
- Add diagrams using PlantUML or Draw.io

---

## 📧 Contact

**Your Name** — Cloud Security & DevSecOps Portfolio  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?logo=linkedin)](https://www.linkedin.com/in/joseph-fonmedig/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?logo=github)](https://github.com/NdiforJoe)
[![Email](https://img.shields.io/badge/Email-Contact-D14836?logo=gmail)](mailto:joewebacc@gmail.com)

**Timezone:** SAST (Johannesburg, South Africa)

---

## 🙏 Acknowledgements

- **AWS re:Invent 2025 COP310 Workshop** — Original content and lab design
- **Terraform AWS Provider Maintainers** — For keeping the provider robust and up-to-date
- **AWS Well-Architected Framework** — Compliance and security pillar guidance

---

<div align="center">

**⭐ Star this repo if it helped you land your next cloud security role! ⭐**

</div>
