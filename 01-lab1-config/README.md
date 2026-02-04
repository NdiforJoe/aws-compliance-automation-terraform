# Lab 1: AWS Config Foundations — Continuous Compliance Monitoring

## 📋 Lab Overview

Deploy AWS Config to continuously monitor your AWS account for compliance violations. Config acts as your "always-on" detective control, evaluating resources against 12 managed rules targeting the violations from Lab 0.

**What you'll deploy:**
- AWS Config recorder (tracks all resource configuration changes)
- S3 bucket for Config snapshots (90-day retention)
- 12 AWS managed Config rules (CIS, SOC 2, NIST aligned)
- IAM role for Config service
- Delivery channel for Config data

**Skills demonstrated:**
- Detective control implementation
- Continuous compliance monitoring
- Policy-as-code for governance
- Audit evidence automation

---

## 🎯 Config Rules Deployed

| Rule Name                    | What It Detects                         | Maps To                | Lab 0 Violation        |
|:-----------------------------|:----------------------------------------|:-----------------------|:-----------------------|
| `restricted-ssh`             | Security groups with SSH from 0.0.0.0/0 | CIS 4.1                | ✅ EC2 security group  |
| `encrypted-volumes`          | Unencrypted EBS volumes                 | CIS 2.1.1              | ✅ EC2 root volume     |
| `s3-bucket-sse`              | S3 buckets without encryption           | CIS 2.1.2, SOC 2 CC6.1 | ✅ S3 bucket           |
| `s3-public-read-prohibited`  | S3 buckets allowing public read         | CIS 2.1.5              | ✅ S3 bucket (no PAB)  |
| `s3-public-write-prohibited` | S3 buckets allowing public write        | CIS 2.1.5              | ✅ S3 bucket (no PAB)  |
| `s3-versioning-enabled`      | S3 buckets without versioning           | SOC 2 CC8.1            | ✅ S3 bucket           |
| `iam-policy-no-admin-access` | IAM policies with Action:*, Resource:*  | CIS 1.16, SOC 2 CC6.2  | ✅ IAM user policy     |
| `iam-unused-credentials`     | IAM users with unused access keys       | CIS 1.3                | ✅ IAM user access key |
| `cw-log-encryption`          | CloudWatch logs without encryption      | NIST PR.DS-1           | ✅ Log group           |
| `ec2-detailed-monitoring`    | EC2 without detailed monitoring         | CIS 4.9                | ✅ EC2 instance        |
| `root-mfa-enabled`           | Root account without MFA                | CIS 1.13               | ⚠️ Account-level       |
| `iam-password-policy`        | Weak IAM password policy                | CIS 1.5-1.11           | ⚠️ Account-level       |

**Total: 12 rules covering 9+ violations**

---

## ✅ Prerequisites

1. **Lab 0 deployed** (or ready to deploy)
   ```bash
   cd ../00-presetup
   terraform apply  # If you destroyed it earlier
   ```

2. **AWS CLI configured**
   ```bash
   aws sts get-caller-identity  # Verify credentials
   ```

3. **Sufficient IAM permissions:**
   - `config:*`
   - `iam:CreateRole`, `iam:AttachRolePolicy`
   - `s3:CreateBucket`, `s3:PutBucketPolicy`

---

## 🚀 Deployment Steps

### Step 1: Navigate to Lab 1

```bash
cd ~/aws-compliance-automation-terraform/01-lab1-config
```

### Step 2: Initialize Terraform

```bash
terraform init
```

Expected output:
```
Terraform has been successfully initialized!
```

### Step 3: Review the Plan

```bash
terraform plan
```

**What to expect:** ~17 resources to be created:
- 1 S3 bucket + 5 bucket configurations
- 1 IAM role + 2 policy attachments
- 1 Config recorder + 1 delivery channel + 1 recorder status
- 12 Config rules

### Step 4: Deploy Config

```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time:** ~2-3 minutes

---

## ⏱️ Wait for Config Evaluation

**IMPORTANT:** After `terraform apply` completes, Config needs time to:
1. Start the recorder (~1 minute)
2. Take initial configuration snapshot (~2-3 minutes)
3. Evaluate all resources against rules (~5-10 minutes)

**Total wait time: 10-15 minutes** before you'll see compliance results.

---

## ✅ Validation & Testing

### Check 1: Config Recorder Status

```bash
# Via Terraform output
terraform output config_recorder_status
# Should show: RECORDING

# Via AWS CLI
aws configservice describe-configuration-recorder-status
```

### Check 2: Config Dashboard (After 10-15 minutes)

1. **Open Config Console:** https://console.aws.amazon.com/config/home?region=us-east-1#/dashboard
2. **Look for:**
   - "Noncompliant rules" count (should show violations)
   - "Noncompliant resources" count
   - Compliance timeline graph

**📸 Portfolio Screenshot:** Capture the Config dashboard showing noncompliant resources

### Check 3: Individual Rule Status

1. **Navigate to:** Config → Rules
2. **Look for rules with status:** `NON_COMPLIANT`
3. **Click on** `cop310-restricted-ssh`
4. **View:** Resources in scope and compliance status

**📸 Portfolio Screenshot:** Rule detail page showing NON_COMPLIANT status

### Check 4: Resource Timeline

1. **Click on a non-compliant resource** (e.g., your EC2 security group)
2. **View the timeline** of configuration changes
3. **See:** When it was created, current configuration, compliance status

**📸 Portfolio Screenshot:** Resource timeline view

---

## 🔍 Testing Config Detection

### Test 1: Create a New Violation

Let's prove Config detects NEW violations in real-time:

```bash
# Create a new security group with open SSH
aws ec2 create-security-group \
  --group-name test-open-ssh \
  --description "Test security group for Config detection" \
  --vpc-id $(cd ../00-presetup && terraform output -raw vpc_id)

# Add the open SSH rule
aws ec2 authorize-security-group-ingress \
  --group-name test-open-ssh \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

**Wait 5-10 minutes**, then check Config dashboard.

**Expected result:** The `cop310-restricted-ssh` rule should flag the new security group as NON_COMPLIANT.

### Test 2: Fix a Violation and Watch Config Update

```bash
# Remove the open SSH rule from the test security group
aws ec2 revoke-security-group-ingress \
  --group-name test-open-ssh \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

**Wait 5-10 minutes**, then check Config dashboard again.

**Expected result:** The security group should now show as COMPLIANT.

### Cleanup Test Resources

```bash
aws ec2 delete-security-group --group-name test-open-ssh
```

---

## 📊 Understanding Config Results

### Compliance Status Meanings:

| Status | Meaning | Example |
|---|---|---|
| **COMPLIANT** | Resource meets the rule requirements | S3 bucket WITH encryption enabled |
| **NON_COMPLIANT** | Resource violates the rule | Security group with 0.0.0.0/0 SSH |
| **NOT_APPLICABLE** | Rule doesn't apply to this resource type | IAM rule evaluated against EC2 instance |
| **INSUFFICIENT_DATA** | Config needs more time to evaluate | Newly created resource |

### Config Evaluation Triggers:

Config evaluates resources:
- ✅ **On configuration change** (within 10 minutes)
- ✅ **Periodically** (every 24 hours by default)
- ✅ **On demand** (manual evaluation via Console)

---

## 💰 Cost Breakdown

| Resource | Cost/Month | Notes |
|---|---|---|
| Config rules | ~$2.40 | $0.003/rule/region × 12 rules × 30 days |
| Config recorder | ~$2.03 | $0.003/item × ~23 items/day × 30 days |
| S3 storage | ~$0.10 | Config snapshots (~5GB over 90 days) |
| **Total** | **~$4.53/month** | Only while Config is enabled |

**Free Tier:** First 1,000 rule evaluations/month are free

---

## 📸 Screenshots for Portfolio

Capture these for your LinkedIn Post 3 (Lab 1):

1. **Config Dashboard** - showing compliance summary with violations
2. **Config Rules List** - showing 12 deployed rules
3. **Rule Detail** - `restricted-ssh` showing NON_COMPLIANT EC2 security group
4. **Resource Timeline** - showing configuration history of a resource
5. **Compliance Score** - overall compliance percentage

---

## 🐛 Troubleshooting

### Issue: "No evaluation results yet"

**Symptom:** Config dashboard is empty or shows "No data"

**Cause:** Config hasn't completed initial evaluation (takes 10-15 minutes)

**Fix:** Wait longer. Check recorder status:
```bash
aws configservice describe-configuration-recorder-status
```

### Issue: "Config recorder not recording"

**Symptom:** `terraform output config_recorder_status` shows "STOPPED"

**Fix:**
```bash
# Start the recorder manually
aws configservice start-configuration-recorder \
  --configuration-recorder-name $(terraform output -raw config_recorder_name)
```

### Issue: "Some rules show INSUFFICIENT_DATA"

**Symptom:** Rules don't show COMPLIANT or NON_COMPLIANT status

**Cause:** Config needs more time or resources don't exist yet

**Fix:** 
1. Ensure Lab 0 resources are deployed
2. Wait 15-20 minutes for full evaluation
3. Manually trigger evaluation via Console

---

## 🗑️ Cleanup

When you're done with Lab 1:

```bash
terraform destroy
```

**⚠️ Warning:** This will:
- Stop Config recorder (no more monitoring)
- Delete all Config rules
- Delete Config S3 bucket and all snapshots
- Remove IAM roles

**Note:** You should keep Config running while working on Lab 2 (auto-remediation)

---

## 📚 Additional Resources

- [AWS Config Rules Reference](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [SOC 2 Trust Services Criteria](https://us.aicpa.org/content/dam/aicpa/interestareas/frc/assuranceadvisoryservices/downloadabledocuments/trust-services-criteria.pdf)

---

## ➡️ Next Steps

Once Config is showing violations:

1. ✅ **Capture screenshots** for portfolio
2. ✅ **Create LinkedIn Post 3** (Lab 1 - Detection in action)
3. ✅ **Proceed to Lab 2** - Auto-remediation with SSM Automation

**Keep Config running** - Lab 2 will use these Config rules to trigger automatic fixes!

---

## 📝 Portfolio Notes

**What to highlight when discussing Lab 1:**

- **Continuous monitoring** - Config evaluates 24/7 without manual intervention
- **Framework alignment** - Rules mapped to CIS, SOC 2, NIST
- **Audit evidence** - Every evaluation is logged and timestamped
- **Scalability** - Same rules can monitor 1 or 1,000 resources
- **Real-time detection** - New violations caught within 10 minutes

**Suggested talking points:**

> "Lab 1 deployed 12 AWS Config rules that continuously monitor compliance. Within 15 minutes, Config automatically detected all 9 violations from Lab 0 - proving that detective controls work without human intervention."
