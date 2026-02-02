# COP310 Pre-Setup: Intentionally Non-Compliant Demo Resources

## 📋 Overview

This module deploys a set of **intentionally misconfigured** AWS resources that serve as the "before" state for the entire COP310 lab series. Every violation here is **by design** — Labs 1–4 will progressively detect, investigate, and remediate them.

| Resource | Violations Introduced | Detected In | Remediated In |
|---|---|---|---|
| EC2 + Security Group | Open SSH (0.0.0.0/0), unencrypted EBS, public subnet | Lab 1 | Lab 2 |
| S3 Bucket | No encryption, no Public Access Block, no versioning | Lab 1 | Lab 2 |
| IAM User + Policy | Wildcard `Action:*` policy, active access key | Lab 1 | Lab 2 |
| CloudWatch Log Group | No retention limit | Lab 1 | — |
| VPC / Subnet | Public-only topology, auto-assign public IPs | Lab 1 | — |

> **⚠️ Warning:** All resources here are in a *personal learning account only*. The open security group rule (`0.0.0.0/0`) is a real network risk — even on a `t3.micro`. SSH brute-force bots will find it within minutes. This is acceptable for a short-lived demo but **do not leave this running longer than needed**. Run `terraform destroy` when you are done with the lab.

---

## 🗂️ File Structure

```
00-presetup/
├── provider.tf       # AWS provider pin, default tags, backend
├── variables.tf      # All tuneable flags (violation on/off switches)
├── main.tf           # All resource definitions with compliance annotations
└── outputs.tf        # Resource IDs + portfolio compliance summary table
```

---

## ✅ Prerequisites

1. **AWS CLI configured** with credentials that have broad permissions in your personal account:
   ```bash
   aws configure
   # Or use a named profile:
   # export AWS_PROFILE=your-personal-profile
   ```

2. **Terraform installed** (>= 1.5.0):
   ```bash
   terraform version
   # Should output: Terraform v1.5.x or higher
   ```

3. **Confirm your account and region:**
   ```bash
   aws sts get-caller-identity
   aws configure set region us-east-1
   ```

4. **GitHub Actions CI/CD** (optional but recommended):
   - The repository includes automated CI/CD checks via GitHub Actions
   - Every push/PR triggers: format checks, validation, security scanning
   - See `.github/workflows/terraform-ci.yml` for details

---

## 🚀 Deployment Steps

### Step 1 — Navigate to the directory

```bash
cd 00-presetup
```

### Step 2 — Initialise Terraform

```bash
terraform init
```

This downloads the `hashicorp/aws` provider (~5.x). You should see:
```
Terraform has been successfully initialized!
```

### Step 3 — Format Terraform files (CI/CD requirement)

```bash
# Format all files
terraform fmt

# Verify formatting
terraform fmt -check
# Should output nothing (no changes needed)
```

> **💡 GitHub Actions Tip:** The CI pipeline will fail if files aren't formatted. Always run `terraform fmt` before committing.

### Step 4 — Review the plan

```bash
terraform plan -out=presetup.tfplan
```

**What to expect:** The plan will show **~15 resources** being created:
- 1 VPC, 1 IGW, 1 Subnet, 1 Route Table, 1 Route Table Association
- 1 Security Group (with the open SSH rule)
- 1 EC2 Instance (unencrypted root volume)
- 1 S3 Bucket + 1 S3 Object (no encryption, no PAB, no versioning)
- 1 IAM User + 1 Inline Policy (wildcard) + 1 Access Key
- 1 IAM Role + 1 Instance Profile + 1 Policy Attachment (for EC2/SSM)
- 1 CloudWatch Log Group

> **📸 Portfolio Screenshot:** Capture the `terraform plan` output here — it shows the "before" state you're about to create.

### Step 5 — Apply

```bash
terraform apply -input=false presetup.tfplan
```

Wait for completion (~30–60 seconds). Terraform will output all the values defined in `outputs.tf`, including the compliance violation summary table.

> **📸 Portfolio Screenshot:** Capture the final `terraform apply` output, especially the `compliance_violation_summary`.

### Step 6 — Validate in the AWS Console

Use these quick checks to confirm the non-compliant state before moving to Lab 1:

| Check | Where to Look | What You Should See |
|---|---|---|
| EC2 Instance | EC2 Console → Instances | Instance running, public IP assigned |
| Security Group | EC2 Console → Security Groups | Inbound SSH rule: `0.0.0.0/0` |
| EBS Volume | EC2 Console → Volumes | Encryption: `No` |
| S3 Bucket | S3 Console → Buckets | No encryption badge, no versioning |
| S3 Public Access | S3 Console → Bucket → Properties | No Public Access Block |
| IAM User | IAM Console → Users | `cop310-demo-user` with inline policy |
| IAM Policy | IAM Console → User → Permissions | Statement shows `Action: *`, `Resource: *` |
| Access Key | IAM Console → User → Security credentials | Active access key present |

> **📸 Portfolio Screenshot:** Take screenshots of each of the above Console views. These are your **"before"** evidence for the portfolio.

---

## 🤖 GitHub Actions Integration

### CI/CD Pipeline Overview

This repository includes automated checks that run on every push and pull request:

| Check | What It Does | Status Badge |
|---|---|---|
| **Terraform Format** | Ensures all `.tf` files follow standard formatting | Required to pass |
| **Terraform Validate** | Checks syntax validity across all labs | Required to pass |
| **TFLint** | Scans for best practices and potential issues | Warning only |
| **Checkov** | Security vulnerability scanning (180+ checks) | Warning only |
| **Documentation** | Validates all required files exist | Required to pass |
| **Secrets Detection** | Scans for hardcoded AWS keys | Required to pass |

### Adding Status Badge to README

After your first successful push, add this badge to your main README.md:

```markdown
[![Terraform CI](https://github.com/NdiforJoe/aws-compliance-automation-terraform/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/NdiforJoe/aws-compliance-automation-terraform/actions/workflows/terraform-ci.yml)
```

### Local Pre-Commit Checks

Before pushing to GitHub, run these locally to catch issues:

```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# (Optional) Install pre-commit hooks
# This automatically runs checks before every commit
```

### Viewing CI Results

1. Push your code to GitHub
2. Go to: `https://github.com/NdiforJoe/aws-compliance-automation-terraform/actions`
3. Click on the latest workflow run
4. Review each job's output

**Expected first-run results:**
- ✅ Format Check: Pass (if you ran `terraform fmt`)
- ✅ Terraform Validate: Pass (Lab 0 syntax is correct)
- ⚠️  TFLint: May show warnings (non-blocking)
- ⚠️  Checkov: May show security recommendations (non-blocking)
- ✅ Docs Check: Pass (all required files present)

> **📸 Portfolio Screenshot:** Capture the GitHub Actions summary page showing all green checkmarks.

---

## 🔧 Toggling Violations On/Off

Each violation is controlled by a variable in `variables.tf`. To simulate what **post-remediation** looks like (useful for Lab 2 verification), you can flip flags:

```bash
# Example: Turn off all violations (simulates full remediation)
terraform apply \
  -var="instance_open_to_world=false" \
  -var="instance_encrypted=true" \
  -var="s3_block_public_access=true" \
  -var="s3_encryption_enabled=true" \
  -var="s3_versioning_enabled=true" \
  -var="iam_policy_overly_broad=false" \
  -var="iam_user_has_access_key=false"
```

> **💡 Tip:** You can also create a `terraform.tfvars` file to persist these overrides instead of typing them on the CLI each time.

---

## 💰 Cost Estimate

| Resource | Approx. Cost/Hour | Notes |
|---|---|---|
| EC2 t3.micro | ~$0.0104/hr | On-Demand, us-east-1 |
| EBS 20 GB gp3 | ~$0.0027/hr | Prorated from $2/month |
| S3 (tiny bucket) | ~$0.00 | Negligible at this size |
| IAM / VPC / SG | $0.00 | No direct charges |
| CloudWatch Log Group | ~$0.00 | No logs ingested yet |
| **Total** | **~$0.013/hr** | **~$0.31/day if left running** |

> **⚠️ Cost Warning:** The EC2 instance is the only resource with meaningful cost. If you are not actively working through Labs 1–2, run `terraform destroy` or at minimum `aws ec2 stop-instances` to avoid surprise charges. **Free Tier covers 750 hrs/month of t3.micro** — this demo uses negligible hours.

---

## 🐛 Troubleshooting

### Issue: Terraform format check fails in CI

**Symptom:**
```
❌ Some files need formatting. Run: terraform fmt -recursive
```

**Fix:**
```bash
cd 00-presetup
terraform fmt
git add .
git commit -m "[CI] Fix Terraform formatting"
git push
```

### Issue: AWS provider download fails

**Symptom:**
```
Error: Failed to install provider
```

**Fix:**
```bash
# Clear Terraform cache
rm -rf .terraform .terraform.lock.hcl

# Re-initialize
terraform init
```

### Issue: IAM permissions error during apply

**Symptom:**
```
Error: creating IAM User: UnauthorizedOperation
```

**Fix:**
Ensure your AWS credentials have these permissions:
- `iam:CreateUser`
- `iam:PutUserPolicy`
- `ec2:RunInstances`
- `s3:CreateBucket`
- Full list in root README → Prerequisites section

### Issue: Region mismatch

**Symptom:**
Resources created in wrong region

**Fix:**
```bash
# Set default region
aws configure set region us-east-1

# Or use provider override
terraform apply -var="aws_region=us-east-1"
```

---

## 🗑️ Cleanup

When you are done with the lab (or before moving to a fresh run):

```bash
terraform destroy
```

Confirm `yes` when prompted. This destroys **all resources** including the EC2 instance, S3 bucket (force-destroyed even if non-empty), IAM user, and access key.

> **⚠️ Warning:** `terraform destroy` is **irreversible**. The IAM access key will be permanently deleted. If you need it for anything, note it first (it's in `outputs.tf` as a sensitive value — run `terraform output iam_access_key_id` to view).

---

## 📦 Portfolio Value

**What this module demonstrates to a hiring manager:**

- ✅ **IaC discipline** — every resource is Terraform-managed, version-controlled, and reproducible
- ✅ **Security awareness** — violations are *documented and intentional*, not accidental
- ✅ **Annotation quality** — each resource explains *why* it's non-compliant and *what will fix it*
- ✅ **Toggle/flag pattern** — compliance state is variable-driven, enabling before/after demos
- ✅ **Cost consciousness** — minimal instance sizes, cleanup instructions, cost estimates included
- ✅ **CI/CD integration** — automated validation and security scanning via GitHub Actions
- ✅ **Documentation excellence** — comprehensive guides, troubleshooting, screenshots

**Suggested README bullets for your portfolio repo:**

```markdown
- Deployed intentionally non-compliant AWS resources via Terraform (EC2, S3, IAM, VPC)
- Introduced 9 distinct compliance violations covering CIS, NIST, and SOC 2 control areas
- Each violation is toggle-able via Terraform variables for before/after demonstration
- Resources serve as the detection & remediation targets for Labs 1–4
- Integrated GitHub Actions CI/CD pipeline for automated validation and security scanning
- Achieved 100% passing CI checks with TFLint, Checkov, and Terraform validation
```

---

## ➡️ Next Steps

Once you have confirmed all violations are visible in the Console:

1. **Capture Portfolio Screenshots:**
   - Terraform apply output with compliance summary
   - AWS Console showing each violation
   - GitHub Actions showing all passing checks

2. **Commit and Push to GitHub:**
   ```bash
   git add .
   git commit -m "[Lab0] Deploy intentional non-compliant resources"
   git push origin main
   ```

3. **Verify CI/CD Pipeline:**
   - Visit: https://github.com/NdiforJoe/aws-compliance-automation-terraform/actions
   - Confirm all checks pass
   - Take screenshot for portfolio

4. **Lab 1: AWS Config Foundations** — Deploy the Config recorder, delivery channel, and managed rules that will *detect* every violation created here.

5. Keep this Terraform state intact — Lab 1 and Lab 2 reference the resource IDs output here.

6. Do **not** manually fix any of the violations — the automated labs are designed to catch them in their current (broken) state.

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Config Best Practices](https://docs.aws.amazon.com/config/latest/developerguide/best-practices.html)
- [GitHub Actions for Terraform](https://learn.hashicorp.com/tutorials/terraform/github-actions)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)

---

## 🎓 Learning Notes

**Key concepts demonstrated in this lab:**

1. **Infrastructure as Code (IaC):** All resources defined in version-controlled Terraform
2. **Compliance-as-Code:** Violations are parameterized and reproducible
3. **Intentional Misconfiguration:** Understanding what *not* to do is as important as knowing best practices
4. **CI/CD for IaC:** Automated validation prevents configuration drift
5. **Cost Optimization:** Free-tier resources with explicit cost tracking

**Questions for reflection:**

- Why is it important to test compliance *detection* before implementing *remediation*?
- How would you extend this setup to a multi-account AWS Organization?
- What additional compliance violations could you add to make this more comprehensive?
- How would you implement this in a real production environment? (Hint: remove toggle flags, use SCPs)
