# Lab 4: AWS Audit Manager — Continuous Audit Readiness & Automated Evidence

## 📋 Lab Overview

Deploy AWS Audit Manager to automate audit evidence collection and demonstrate continuous compliance assessment. Instead of scrambling to gather evidence when auditors arrive, evidence is collected automatically 24/7 from Config, CloudTrail, and SSM.

**What you'll deploy:**
- S3 bucket for audit evidence storage (7-year retention)
- IAM role for Audit Manager service
- Custom compliance framework (5 controls across 3 control sets)
- Assessment linked to Labs 0-3 evidence sources

**Skills demonstrated:**
- Automated audit evidence collection
- Control framework mapping
- Continuous compliance assessment
- SOC 2 / ISO 27001 audit preparation
- Evidence retention and lifecycle management

---

## 🎯 Controls Framework

| Control Set | Control | Evidence Source | What It Proves |
|---|---|---|---|
| **Detective** | Restricted SSH | AWS Config | Security groups block 0.0.0.0/0 |
| **Detective** | S3 Encryption | AWS Config | S3 buckets encrypted (AES256) |
| **Detective** | S3 Versioning | AWS Config | S3 buckets have versioning |
| **Corrective** | Auto-Remediation | CloudTrail + SSM | Violations auto-fixed in <2 min |
| **Investigative** | Forensic Analysis | CloudTrail Lake | All changes tracked and queryable |

**Total: 5 controls demonstrating complete security lifecycle**

---

## ✅ Prerequisites

1. **Labs 0-3 deployed** (provides evidence sources)
2. **AWS CLI configured**
3. **Audit Manager never enabled before** (or settings cleared)
4. **Admin permissions** (Audit Manager requires broad read access)

---

## 🚀 Deployment Steps

### Step 1: Navigate to Lab 4

```bash
cd ~/aws-compliance-automation-terraform/04-lab4-audit-manager
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

**Expected:** ~7 resources to create:
- 1 S3 bucket (evidence storage)
- 4 S3 bucket configurations (versioning, encryption, lifecycle, PAB)
- 1 IAM role
- 1 IAM policy attachment

### Step 4: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time:** ~1 minute

---

## 📋 Console Setup (Required)

**AWS Audit Manager has limited Terraform support.** After Terraform deploys the infrastructure, you'll create the assessment manually in the Console.

### Part 1: Enable Audit Manager (First Time Only)

1. **Get Console URL:**
   ```bash
   terraform output audit_manager_console_url
   ```

2. **Open Audit Manager Console**

3. **If first time:**
   - Click "Get started"
   - Click "Enable Audit Manager"
   - Evidence storage bucket: Use the bucket from `terraform output audit_evidence_bucket`
   - Click "Enable"

---

### Part 2: Create Custom Framework

**Why custom?** We're mapping to Labs 0-3 controls, not a standard framework like SOC 2.

1. **Click "Framework library"** (left sidebar)

2. **Click "Create custom framework"**

3. **Framework details:**
   - Name: `COP310-Compliance-Framework`
   - Description: `Custom framework demonstrating detective, corrective, and investigative controls`
   - Compliance type: `Custom`

4. **Add Control Set 1: "Detective Controls"**

   Click "Add control set" → "Create new control set"
   
   **Control Set Name:** `Detective Controls`
   
   **Add 3 controls:**
   
   **Control 1:**
   - Name: `Restricted SSH Access`
   - Description: `Security groups must not allow SSH from 0.0.0.0/0`
   - Control type: `Technical`
   - Data source: `AWS Config`
   - Keyword: `cop310-restricted-ssh`
   
   **Control 2:**
   - Name: `S3 Bucket Encryption`
   - Description: `S3 buckets must have server-side encryption enabled`
   - Control type: `Technical`
   - Data source: `AWS Config`
   - Keyword: `cop310-s3-bucket-sse`
   
   **Control 3:**
   - Name: `S3 Bucket Versioning`
   - Description: `S3 buckets must have versioning enabled for data recovery`
   - Control type: `Technical`
   - Data source: `AWS Config`
   - Keyword: `cop310-s3-versioning-enabled`

5. **Add Control Set 2: "Corrective Controls"**

   Click "Add control set" → "Create new control set"
   
   **Control Set Name:** `Corrective Controls`
   
   **Control 4:**
   - Name: `Automated Remediation`
   - Description: `Config violations are automatically remediated via SSM Automation`
   - Control type: `Technical`
   - Data source: `AWS CloudTrail`
   - Keyword: `StartAutomationExecution`

6. **Add Control Set 3: "Investigative Controls"**

   Click "Add control set" → "Create new control set"
   
   **Control Set Name:** `Investigative Controls`
   
   **Control 5:**
   - Name: `Security Event Investigation`
   - Description: `All API calls logged and queryable for forensic analysis`
   - Control type: `Technical`
   - Data source: `AWS CloudTrail`
   - Keyword: `AuthorizeSecurityGroupIngress`

7. **Click "Create custom framework"**

---

### Part 3: Create Assessment

1. **Click "Assessments"** (left sidebar)

2. **Click "Create assessment"**

3. **Assessment details:**
   - Name: `COP310-Compliance-Assessment`
   - Description: `Continuous compliance assessment with automated evidence from Config, CloudTrail, and SSM`
   - Framework: Select `COP310-Compliance-Framework` (your custom framework)
   - Reports destination: Select the S3 bucket from `terraform output`

4. **AWS account:**
   - Current AWS account
   - Account name: `COP310-Demo`

5. **AWS services (select these):**
   - ✅ AWS Config
   - ✅ AWS CloudTrail
   - ✅ Amazon EC2
   - ✅ Amazon S3
   - ✅ AWS Systems Manager

6. **Assessment role:**
   - Use existing role: Select the role from `terraform output audit_manager_role_arn`

7. **Click "Create assessment"**

8. **Wait 5-10 minutes** for initial evidence collection

---

## 📊 Viewing Assessment Results

### Assessment Dashboard

After 5-10 minutes, the dashboard will show:

- **Control Sets:** 3 (Detective, Corrective, Investigative)
- **Controls:** 5 total
- **Evidence Items:** 50+ automatically collected
- **Compliance Status:** Per control (Compliant / Non-compliant / Requires investigation)

### Evidence Collection

**What Audit Manager automatically collects:**

| Control | Evidence Type | What's Collected |
|---|---|---|
| Restricted SSH | Config evaluation | Rule compliance status, resource ID, timestamp |
| S3 Encryption | Config evaluation | Bucket encryption config, evaluation result |
| S3 Versioning | Config evaluation | Versioning status per bucket |
| Auto-Remediation | CloudTrail events | SSM StartAutomationExecution events with parameters |
| Forensic Analysis | CloudTrail events | Security group creation/modification events |

**Evidence retention:** 7 years (in S3 bucket)

---

## 📸 Screenshots for Portfolio

Capture these for LinkedIn Post 6 (Lab 4):

1. **Audit Manager Dashboard** - Assessment overview showing 5 controls
2. **Custom Framework** - 3 control sets (Detective, Corrective, Investigative)
3. **Control Detail** - Single control showing evidence items
4. **Evidence Items** - Config compliance evidence
5. **Assessment Report** - Downloaded PDF report

---

## 📄 Generating Assessment Report

**For auditors:**

1. In assessment dashboard, click **"Generate assessment report"**

2. **Report details:**
   - Name: `COP310-Assessment-Report-<date>`
   - Description: `Automated compliance evidence for period X to Y`

3. Click **"Generate report"**

4. Wait 2-3 minutes

5. **Download report:**
   - Go to "Assessment reports" tab
   - Click your report
   - Click "Download report" (PDF)

**The report includes:**
- Executive summary
- Control-by-control compliance status
- Evidence collected (with timestamps and sources)
- Recommendations for non-compliant controls

---

## 💰 Cost Breakdown

| Resource | Cost/Month | Notes |
|---|---|---|
| Audit Manager | ~$5.00 | $0.00125/assessment/hour |
| S3 evidence storage | ~$0.10 | Minimal storage (~100MB) |
| **Total** | **~$5.10/month** | Only while assessment is active |

**Note:** You can disable the assessment when not actively demonstrating to pause costs.

---

## 🐛 Troubleshooting

### Issue: "No evidence collected after 10 minutes"

**Symptoms:**
- Assessment shows 0 evidence items
- Controls show "No evidence"

**Causes:**
1. Services not selected during assessment creation
2. Data sources don't match control keywords
3. Labs 0-3 not deployed (no evidence to collect)

**Fix:**
```bash
# Verify Labs 0-3 are deployed
cd ~/aws-compliance-automation-terraform/00-presetup
terraform state list  # Should show resources

cd ../01-lab1-config
terraform state list  # Should show Config rules

# Check Config rule names match control keywords
aws configservice describe-config-rules \
  --query 'ConfigRules[?starts_with(ConfigRuleName, `cop310`)].ConfigRuleName'
```

### Issue: "Cannot find custom framework"

**Symptoms:**
- Framework not appearing in assessment creation

**Cause:**
- Framework creation wasn't completed

**Fix:**
- Go to "Framework library"
- Verify "COP310-Compliance-Framework" exists
- If not, recreate following Part 2 instructions

### Issue: "Evidence shows non-compliant"

**Symptoms:**
- Controls show "Non-compliant" status
- Evidence indicates violations

**This is expected if:**
- Lab 2 remediation hasn't run yet
- Resources were recently redeployed
- Remediation disabled

**Fix:**
- Wait for Lab 2 remediation to execute
- Config re-evaluates every 24 hours
- Or manually trigger Config rule evaluation

---

## 📚 Understanding Evidence Types

### Config Evidence

**What it includes:**
- Resource ID (e.g., sg-0261680986850710c)
- Compliance status (COMPLIANT / NON_COMPLIANT)
- Evaluation timestamp
- Config rule name
- Configuration snapshot

**Use case:** Proves current state compliance

### CloudTrail Evidence

**What it includes:**
- Event name (e.g., StartAutomationExecution)
- User identity (who performed action)
- Timestamp (when it happened)
- Request parameters (what was done)
- Response elements (result)

**Use case:** Proves actions were taken and by whom

---

## 🗑️ Cleanup

When done with Lab 4:

```bash
# First, delete assessment in Console:
# Audit Manager → Assessments → Select assessment → Delete

# Then destroy Terraform resources:
terraform destroy
```

**⚠️ Note:** You must delete the assessment in Console first, otherwise Terraform destroy will fail (assessment still using the S3 bucket).

---

## 📚 Additional Resources

- [AWS Audit Manager Documentation](https://docs.aws.amazon.com/audit-manager/)
- [Creating Custom Frameworks](https://docs.aws.amazon.com/audit-manager/latest/userguide/create-custom-frameworks.html)
- [Evidence Collection](https://docs.aws.amazon.com/audit-manager/latest/userguide/evidence-collection.html)

---

## ➡️ Next Steps

Once assessment is collecting evidence:

1. ✅ **Capture screenshots** for portfolio
2. ✅ **Generate assessment report** (PDF for auditors)
3. ✅ **Create LinkedIn Post 6** (Lab 4 - Continuous audit readiness)
4. ✅ **Proceed to Lab 5** - Multi-account deployment with StackSets (optional)

---

## 📝 Portfolio Notes

**What to highlight when discussing Lab 4:**

- **Continuous evidence collection** - Not point-in-time snapshots
- **Automated control mapping** - Evidence linked to specific controls
- **Audit readiness** - Reports generated on-demand for auditors
- **Multi-framework support** - Can map to SOC 2, ISO 27001, PCI-DSS, etc.

**Suggested talking points:**

> "Lab 4 automated audit evidence collection using AWS Audit Manager. Instead of spending weeks gathering evidence when auditors arrive, evidence is collected continuously from Config, CloudTrail, and SSM. Generated a compliance report in 3 minutes that would normally take 2-3 weeks of manual effort."

> "The key insight: Audit Manager doesn't just collect evidence—it maps evidence to specific controls. For SOC 2 CC6.1 (encryption), it automatically pulls Config evaluations showing all S3 buckets have encryption enabled. Auditors get timestamped proof with zero manual effort."
