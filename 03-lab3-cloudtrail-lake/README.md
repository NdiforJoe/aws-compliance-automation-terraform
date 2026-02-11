# Lab 3: CloudTrail Lake — Security Investigations & Forensic Analysis

## 📋 Lab Overview

Deploy AWS CloudTrail Lake to enable SQL-based forensic analysis of AWS API activity. Answer compliance questions in seconds instead of hours: "Who created that open security group?", "When did remediation happen?", "What changed on this S3 bucket?"

**What you'll deploy:**
- CloudTrail Lake event data store (90-day retention)
- 8 saved SQL queries for common investigations
- Management event capture (all AWS API calls)
- Query interface for root cause analysis

**Skills demonstrated:**
- Investigative controls (forensics)
- SQL-based log analysis
- Incident response capabilities  
- Audit evidence collection
- Compliance investigation workflows

---

## 🎯 Investigation Capabilities

| Question | Saved Query | Use Case |
|---|---|---|
| "Who created this resource?" | `security-group-creation` | Root cause analysis |
| "Who modified S3 configuration?" | `s3-config-changes` | Data protection audit |
| "When did remediation execute?" | `ssm-remediation-history` | Compliance verification |
| "Who changed IAM policies?" | `iam-policy-changes` | Privilege escalation detection |
| "What triggered non-compliance?" | `config-compliance-changes` | Compliance timeline |
| "What did this user do?" | `user-activity` | User behavior investigation |
| "Were there failed access attempts?" | `failed-api-calls` | Security incident response |
| "Who deleted resources?" | `resource-deletions` | Data loss investigation |

---

## ✅ Prerequisites

1. **Labs 0-2 deployed** (generates CloudTrail events to query)
2. **AWS CLI configured**
3. **CloudTrail enabled** (automatic in AWS accounts)
4. **Some time has passed** since Labs 0-2 (events need 5-15 min to appear)

---

## 🚀 Deployment Steps

### Step 1: Navigate to Lab 3

```bash
cd ~/aws-compliance-automation-terraform/03-lab3-cloudtrail-lake
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
- 1 CloudTrail Lake event data store
- 8 saved queries (investigation templates)

### Step 4: Deploy CloudTrail Lake

```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time:** ~1-2 minutes

---

## ⏱️ Wait for Events to Populate

**IMPORTANT:** CloudTrail Lake ingests events with a 5-15 minute delay.

**If you just deployed Labs 0-2:**
- Wait 15-20 minutes for events to appear in Lake
- Events from past 90 days are automatically included
- New events appear within 5-15 minutes

---

## 🔍 Running Your First Query

### Method 1: Use Saved Queries (Recommended)

1. **Get Console URL:**
   ```bash
   terraform output cloudtrail_lake_console_url
   ```

2. **Open CloudTrail Lake Console:**
   https://console.aws.amazon.com/cloudtrail/home?region=us-east-1#/lake/query

3. **Click "Saved queries" tab**

4. **Select a query:**
   - `cop310-security-group-creation`
   - `cop310-ssm-remediation-history`
   - `cop310-s3-config-changes`

5. **Click "Run query"**

6. **View results** showing who/what/when

**📸 Screenshot:** Query results showing event details

---

### Method 2: Write Custom SQL

**Investigation: Who created the non-compliant security group?**

```sql
SELECT
  eventTime,
  userIdentity.principalId,
  userIdentity.arn as user_arn,
  eventName,
  requestParameters.groupId as security_group_id,
  requestParameters.ipPermissions as rules_added,
  sourceIPAddress
FROM <YOUR_EVENT_DATA_STORE_ID>
WHERE
  eventName = 'AuthorizeSecurityGroupIngress'
  AND requestParameters LIKE '%0.0.0.0/0%'
ORDER BY eventTime DESC
LIMIT 10
```

**Replace `<YOUR_EVENT_DATA_STORE_ID>` with:**
```bash
terraform output event_data_store_id
```

---

## 📊 Investigation Scenarios

### Scenario 1: Root Cause Analysis

**Question:** "Who created the security group with SSH 0.0.0.0/0?"

**Steps:**
1. Go to CloudTrail Lake Console
2. Select saved query: `cop310-security-group-creation`
3. Run query
4. Look for `AuthorizeSecurityGroupIngress` events
5. Check `requestParameters` for `0.0.0.0/0` and port `22`

**Expected Result:**
```
eventTime: 2026-02-08 11:00:15
userIdentity.principalId: AIDAI...
userIdentity.arn: arn:aws:sts::123456789012:assumed-role/terraform-role/...
eventName: AuthorizeSecurityGroupIngress
requestParameters: {
  "groupId": "sg-0261680986850710c",
  "ipPermissions": [{
    "fromPort": 22,
    "toPort": 22,
    "ipProtocol": "tcp",
    "ipRanges": [{"cidrIp": "0.0.0.0/0"}]
  }]
}
```

**Conclusion:** Terraform (via IAM role) created the rule during Lab 0 deployment.

---

### Scenario 2: Remediation Verification

**Question:** "When did SSM Automation fix the violations?"

**Steps:**
1. Select saved query: `cop310-ssm-remediation-history`
2. Run query
3. Look for `StartAutomationExecution` events
4. Check execution IDs match Lab 2 results

**Expected Result:**
```
eventTime: 2026-02-08 11:12:01
documentName: cop310-RevokeSecurityGroupIngress
parameters: {"SecurityGroupId": "sg-0261680986850710c"}
automationExecutionId: 6f374576-71c8-421f-9ff1-68db49c4939d
```

**Conclusion:** Config triggered SSM remediation 1 second after detection.

---

### Scenario 3: S3 Configuration Timeline

**Question:** "Show all S3 bucket changes in the last 90 days"

**Steps:**
1. Select saved query: `cop310-s3-config-changes`
2. Run query
3. Review chronological list of bucket configuration changes

**Expected Events:**
- `PutBucketEncryption` (from Lab 2 remediation)
- `PutBucketVersioning` (from Lab 2 remediation)
- `PutPublicAccessBlock` (from Lab 2 remediation)

**Conclusion:** All S3 hardening happened via SSM Automation.

---

### Scenario 4: Failed Access Attempts

**Question:** "Were there any unauthorized access attempts?"

**Steps:**
1. Select saved query: `cop310-failed-api-calls`
2. Run query
3. Look for `AccessDenied` or `UnauthorizedOperation` errors

**Use Case:**
- Detect compromised credentials
- Find privilege escalation attempts
- Identify misconfigured IAM policies

---

## 📸 Screenshots for Portfolio

Capture these for LinkedIn Post 5 (Lab 3):

1. **Event Data Store Dashboard** - Showing event count, retention period
2. **Saved Queries List** - 8 investigation templates
3. **Query Results - Root Cause** - Who created the security group
4. **Query Results - Remediation** - SSM execution history
5. **Custom SQL Query** - Advanced investigation example

---

## 💰 Cost Breakdown

| Resource | Cost/Month | Notes |
|---|---|---|
| Event data store | ~$2.03 | $0.0023/GB ingested (~880GB/month management events) |
| Data retention (90 days) | ~$0.45 | $0.005/GB/month (~90GB total) |
| Query execution | Free | First 1TB scanned/month (plenty for this demo) |
| **Total** | **~$2.50/month** | Management events only |

**Note:** Data events (S3 object access, Lambda invocations) cost more. Not enabled in this lab.

---

## 🐛 Troubleshooting

### Issue: "No events found in query results"

**Symptoms:**
- Saved queries return 0 rows
- Event data store shows 0 events

**Causes:**
1. Events haven't ingested yet (5-15 min delay)
2. Labs 0-2 not deployed (no events to capture)
3. CloudTrail not enabled (should be automatic)

**Fix:**
```bash
# Check if events are ingesting
# Run this query in CloudTrail Lake Console:

SELECT COUNT(*) as event_count
FROM <YOUR_EVENT_DATA_STORE_ID>

# If count > 0, events are there - try specific queries
# If count = 0, wait 10-15 more minutes
```

### Issue: "Query timeout or slow performance"

**Symptoms:**
- Queries take >30 seconds
- Timeout errors

**Causes:**
- Very large time range (querying 90 days of data)
- No time filter in WHERE clause

**Fix:**
```sql
# Always add time filters for faster queries
WHERE
  eventTime > '2026-02-08'  -- Today only
  AND eventName = 'AuthorizeSecurityGroupIngress'
```

### Issue: "Can't find specific event"

**Symptoms:**
- Know an action happened but query returns nothing
- Missing recent events

**Causes:**
- Event name is case-sensitive
- Event hasn't ingested yet (5-15 min delay)
- Wrong event data store ID

**Fix:**
```sql
# Search for event name variations
WHERE
  eventName LIKE '%SecurityGroup%'
  AND eventTime > '2026-02-08'
ORDER BY eventTime DESC

# This shows all security group-related events
```

---

## 📚 CloudTrail Lake SQL Reference

### Common Query Patterns

**Filter by time:**
```sql
WHERE eventTime > '2026-02-01'
WHERE eventTime BETWEEN '2026-02-01' AND '2026-02-08'
```

**Filter by user:**
```sql
WHERE userIdentity.principalId = 'AIDAI...'
WHERE userIdentity.arn LIKE '%terraform%'
```

**Filter by service:**
```sql
WHERE eventSource = 's3.amazonaws.com'
WHERE eventSource = 'ec2.amazonaws.com'
```

**Search in JSON:**
```sql
WHERE requestParameters.bucketName = 'my-bucket'
WHERE requestParameters LIKE '%0.0.0.0/0%'
```

**Aggregate data:**
```sql
SELECT
  eventName,
  COUNT(*) as count
FROM <event-data-store-id>
GROUP BY eventName
ORDER BY count DESC
```

---

## 🗑️ Cleanup

When done with Lab 3:

```bash
terraform destroy
```

**⚠️ Warning:** This will:
- Delete the event data store
- Delete all saved queries
- **NOT** delete CloudTrail events (they're stored separately)

---

## 📚 Additional Resources

- [CloudTrail Lake Documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html)
- [CloudTrail Lake SQL Reference](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/query-lake-cli.html)
- [CloudTrail Event Reference](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference.html)

---

## ➡️ Next Steps

Once queries are returning results:

1. ✅ **Capture screenshots** for portfolio
2. ✅ **Document investigation findings** (who/what/when)
3. ✅ **Create LinkedIn Post 5** (Lab 3 - Forensic investigations)
4. ✅ **Proceed to Lab 4** - Audit Manager for automated evidence collection
5. ✅ **Keep Lab 3 running** - Lab 4 will reference CloudTrail Lake data

---

## 📝 Portfolio Notes

**What to highlight when discussing Lab 3:**

- **Investigation speed** - 5 seconds to answer "who did this" vs 2-3 hours parsing logs
- **SQL interface** - Accessible to anyone who knows SQL, not just log experts
- **Audit trail** - Immutable record of all AWS API activity
- **Forensic capability** - Essential for incident response and compliance investigations

**Suggested talking points:**

> "Lab 3 deployed CloudTrail Lake for SQL-based forensic analysis. Using saved queries, I can answer compliance questions in seconds: 'Who created that open security group?' → 5-second SQL query. Before CloudTrail Lake, this required parsing gigabytes of JSON logs for hours."

> "For SOC 2 audits, auditors ask: 'Show me who accessed this sensitive resource.' CloudTrail Lake makes this trivial: SELECT userIdentity, eventTime FROM events WHERE resource = 'X'. Instant audit evidence with full chain of custody."
