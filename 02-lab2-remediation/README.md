# Lab 2: Auto-Remediation with SSM Automation — Self-Healing Compliance

## 📋 Lab Overview

Deploy AWS Systems Manager (SSM) Automation documents that automatically fix compliance violations detected by AWS Config. This transforms Config from a detective control into a complete detective + corrective control system.

**What you'll deploy:**
- 4 SSM Automation documents (remediation runbooks)
- 4 Config remediation configurations (linking rules to SSM docs)
- IAM role with remediation permissions
- Automatic or manual remediation triggers

**Skills demonstrated:**
- Corrective control automation
- Self-healing infrastructure
- Runbook development (Infrastructure-as-Code for operations)
- Event-driven remediation architecture

---

## 🎯 Remediation Actions Deployed

| Config Rule | SSM Document | What It Fixes | Time to Fix |
|---|---|---|---|
| `cop310-restricted-ssh` | RevokeSecurityGroupIngress | Removes SSH 0.0.0.0/0 rule | ~60 sec |
| `cop310-s3-bucket-sse` | EnableS3Encryption | Enables AES256 encryption | ~45 sec |
| `cop310-s3-versioning-enabled` | EnableS3Versioning | Turns on versioning | ~30 sec |
| `cop310-s3-public-read-prohibited` | AttachS3PublicAccessBlock | Blocks all public access | ~45 sec |

**Total: 4 automated fixes covering 6 violations from Lab 0**

---

## 🔄 How Auto-Remediation Works

```
┌─────────────┐
│   Config    │ Detects violation (SSH 0.0.0.0/0)
│    Rule     │
└──────┬──────┘
       │ Triggers remediation
       ▼
┌─────────────┐
│   Config    │ Invokes SSM Automation
│ Remediation │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│     SSM     │ Executes: aws ec2 revoke-security-group-ingress
│ Automation  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Security  │ SSH rule removed
│    Group    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Config    │ Re-evaluates → COMPLIANT ✅
│    Rule     │
└─────────────┘

Total time: ~90 seconds
```

---

## ✅ Prerequisites

1. **Lab 0 deployed** (non-compliant resources)
2. **Lab 1 deployed** (Config rules running)
3. **AWS CLI configured**
4. **Violations detected** by Config (visible in dashboard)

---

## 🚀 Deployment Steps

### Step 1: Navigate to Lab 2

```bash
cd ~/aws-compliance-automation-terraform/02-lab2-remediation
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

**Expected:** ~10 resources to create:
- 1 IAM role + 2 policy attachments
- 4 SSM Automation documents
- 4 Config remediation configurations

### Step 4: Deploy Remediation

```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time:** ~1-2 minutes

---

## ⏱️ What Happens After Deployment

**Immediate (0-5 minutes):**
- ✅ SSM documents created
- ✅ Config remediation configurations active
- ✅ IAM role ready

**Within 5-10 minutes:**
- 🔄 Config triggers remediation for existing violations
- 🔄 SSM Automation executions start
- 🔄 Resources begin getting fixed

**Within 10-15 minutes:**
- ✅ Security group SSH rule revoked
- ✅ S3 bucket encryption enabled
- ✅ S3 bucket versioning enabled
- ✅ S3 Public Access Block attached
- ✅ Config dashboard shows increased compliance

---

## 📸 Monitoring Remediation in Real-Time

### View 1: SSM Automation Executions

```bash
# Get SSM Console URL from Terraform
terraform output ssm_console_url
```

1. **Open the SSM Console URL**
2. **Look for executions** with names like:
   - `cop310-RevokeSecurityGroupIngress-xxxxx`
   - `cop310-EnableS3Encryption-xxxxx`
3. **Click on an execution** to see:
   - Status: InProgress → Success
   - Steps executed
   - Input parameters
   - Output results

**📸 Screenshot:** SSM execution showing "Success" status

**Save as:** `ssm-automation-success.png`

### View 2: Config Resource Timeline (Before/After)

1. **Go to Config Console** → Resources
2. **Find:** Your security group (cop310-ec2-sg)
3. **Click on it**
4. **View timeline** showing:
   - Before: NON_COMPLIANT
   - Remediation action executed
   - After: COMPLIANT ✅

**📸 Screenshot:** Timeline showing the compliance state change

**Save as:** `config-remediation-timeline.png`

### View 3: Security Group Rules (Before/After)

**Before remediation:**
```bash
# View security group rules
aws ec2 describe-security-groups \
  --group-ids $(cd ../00-presetup && terraform output -raw security_group_id) \
  --query 'SecurityGroups[0].IpPermissions'
```

Should show SSH rule with `0.0.0.0/0`

**After remediation (wait 10 minutes):**
Run the same command - SSH rule should be gone!

**📸 Screenshot:** EC2 Console showing security group with SSH rule removed

**Save as:** `sg-after-remediation.png`

### View 4: S3 Bucket Properties (Before/After)

1. **Go to S3 Console**
2. **Click on:** `cop310-noncompliant-demo-[account-id]`
3. **Properties tab:**
   - Default encryption: Should now show **AES-256**
   - Bucket Versioning: Should now show **Enabled**
4. **Permissions tab:**
   - Block public access: Should show **All blocked**

**📸 Screenshot:** S3 bucket properties showing encryption enabled

**Save as:** `s3-after-remediation.png`

---

## 🧪 Testing Auto-Remediation with New Violation

Want to see remediation happen in real-time? Create a new violation:

### Test 1: Create Non-Compliant Security Group

```bash
# Create test security group
aws ec2 create-security-group \
  --group-name test-auto-remediation \
  --description "Testing automatic remediation" \
  --vpc-id $(cd ../00-presetup && terraform output -raw vpc_id)

# Add open SSH rule (this will trigger Config)
aws ec2 authorize-security-group-ingress \
  --group-name test-auto-remediation \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

**What happens next:**
1. ⏰ **5 minutes:** Config detects the violation
2. ⏰ **6 minutes:** Config triggers SSM Automation
3. ⏰ **7 minutes:** SSM revokes the SSH rule
4. ⏰ **8 minutes:** Config re-evaluates → COMPLIANT

**Watch it happen:**
- SSM Console: See execution start and complete
- Config Console: See NON_COMPLIANT → COMPLIANT transition

**Clean up:**
```bash
aws ec2 delete-security-group --group-name test-auto-remediation
```

---

## 📊 Understanding Remediation Status

### SSM Execution States

| Status | Meaning | Next Action |
|---|---|---|
| **Pending** | Execution queued | Wait (~30 sec) |
| **InProgress** | Remediation running | Watch steps execute |
| **Success** | Remediation completed ✅ | Check Config for COMPLIANT |
| **Failed** | Remediation error ❌ | Check execution logs for errors |
| **TimedOut** | Execution exceeded time limit | May retry automatically |

### Config Remediation States

**In Config Console → Rules → Select rule:**
- **Remediation action:** Shows the SSM document
- **Automatic:** Yes/No
- **Retry attempts:** How many times Config will retry
- **Last execution:** Recent remediation history

---

## 💰 Cost Breakdown

| Resource | Cost/Month | Notes |
|---|---|---|
| SSM Automation | ~$0.60 | $0.002/execution × ~10 executions/day |
| Config (from Lab 1) | ~$4.53 | No additional charge |
| IAM roles | $0.00 | No charge |
| **Total Lab 2** | **~$0.60/month** | Only when remediations execute |

---

## 🐛 Troubleshooting

### Issue: "Remediation not triggered"

**Symptoms:**
- Config shows NON_COMPLIANT
- No SSM executions visible
- Nothing happening after 15 minutes

**Possible causes:**
1. Automatic remediation disabled: `var.enable_automatic_remediation = false`
2. Config hasn't re-evaluated yet (wait longer)
3. IAM permissions missing

**Fix:**
```bash
# Check if automatic remediation is enabled
terraform output automatic_remediation_enabled

# If false, enable it:
terraform apply -var="enable_automatic_remediation=true"

# Manually trigger remediation from Console:
# Config → Rules → Select rule → Actions → Remediate
```

### Issue: "SSM execution failed"

**Symptoms:**
- SSM execution shows "Failed" status
- Resource still NON_COMPLIANT

**Common errors:**

**Error 1: Insufficient permissions**
```
AccessDeniedException: User is not authorized to perform: ec2:RevokeSecurityGroupIngress
```
**Fix:** Check IAM role has all required permissions (should be automatic if deployed via Terraform)

**Error 2: Resource not found**
```
InvalidGroup.NotFound: The security group 'sg-xxxxx' does not exist
```
**Fix:** Resource was deleted manually. Config will stop trying to remediate.

**Error 3: Invalid parameter**
```
InvalidParameterValue: Cannot revoke rule that doesn't exist
```
**Fix:** Rule was already removed. Config will mark as COMPLIANT on next evaluation.

### Issue: "Remediation keeps retrying"

**Symptoms:**
- Multiple SSM executions for same resource
- Resource still NON_COMPLIANT after fixes

**Cause:** Remediation might be fixing the wrong thing, or another process is re-creating the violation

**Fix:**
```bash
# Check what's creating the violation
# View resource configuration history in Config Console

# Disable automatic remediation temporarily
terraform apply -var="enable_automatic_remediation=false"

# Fix the root cause manually
# Then re-enable automatic remediation
```

---

## 📸 Screenshots for Portfolio

Capture these for LinkedIn Post 4 (Lab 2):

1. **SSM Automation Success** - Execution showing "Success" status with steps
2. **Config Timeline** - Resource showing NON_COMPLIANT → Remediation → COMPLIANT
3. **Security Group After** - Inbound rules showing SSH rule removed
4. **S3 Bucket After** - Properties showing encryption + versioning enabled
5. **Terraform Output** - Showing remediation configurations deployed

---

## 🗑️ Cleanup

When done with Lab 2:

```bash
# This will disable auto-remediation but keep Config rules
terraform destroy

# Resources will revert to NON_COMPLIANT but won't auto-fix anymore
```

**⚠️ Note:** If you destroy Lab 2 before Lab 1, Config rules will still detect violations but won't remediate them automatically.

---

## 📚 Additional Resources

- [AWS SSM Automation Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-automation.html)
- [Config Remediation Actions](https://docs.aws.amazon.com/config/latest/developerguide/remediation.html)
- [SSM Automation Runbook Reference](https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-runbook-reference.html)

---

## ➡️ Next Steps

Once remediation is working:

1. ✅ **Capture screenshots** showing before/after
2. ✅ **Create LinkedIn Post 4** (Lab 2 - Auto-remediation in action)
3. ✅ **Proceed to Lab 3** - CloudTrail Lake for security investigations
4. ✅ **Keep Labs 0-2 running** - Lab 3 will query their CloudTrail events

---

## 📝 Portfolio Notes

**What to highlight when discussing Lab 2:**

- **Mean Time to Remediate (MTTR)** - 90 seconds vs. days/weeks manual
- **Self-healing** - Infrastructure fixes itself without human intervention
- **Runbook-as-Code** - SSM documents are version-controlled, testable
- **Event-driven** - Remediation triggered automatically by Config
- **Audit trail** - Every remediation logged in SSM and CloudTrail

**Suggested talking points:**

> "Lab 2 automated the remediation of 4 critical violations. Within 90 seconds of Config detecting an issue, SSM Automation executes the fix. This reduced Mean Time to Remediate from 3-5 business days to under 2 minutes - a 99.5% improvement."

> "The key insight: security violations aren't just detected, they're automatically corrected before they can be exploited. This is the difference between reactive and proactive security."
