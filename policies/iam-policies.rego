###############################################################################
# iam-policies.rego — OPA Policy for IAM Security
#
# Prevents overly permissive IAM policies
###############################################################################

package terraform.iam_policies

import future.keywords.in
import future.keywords.if

# METADATA
# title: IAM Policy Security Requirements
# description: IAM policies must follow least privilege principles
# custom:
#   severity: CRITICAL
#   frameworks:
#     - CIS AWS Foundations Benchmark 1.16
#     - SOC 2 CC6.2

# Deny if IAM policy allows all actions (Action: *)
deny[msg] {
    resource := input.resource_changes[_]
    resource.type in ["aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy"]
    
    # Parse policy document
    policy := json.unmarshal(resource.change.after.policy)
    statement := policy.Statement[_]
    
    # Check for wildcard actions
    statement.Effect == "Allow"
    statement.Action == "*"
    
    msg := sprintf(
        "CRITICAL: IAM policy '%s' allows all actions (Action: *). Use specific actions instead.",
        [resource.name]
    )
}

# Deny if IAM policy allows all resources (Resource: *)
deny[msg] {
    resource := input.resource_changes[_]
    resource.type in ["aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy"]
    
    policy := json.unmarshal(resource.change.after.policy)
    statement := policy.Statement[_]
    
    # Check for wildcard resources with powerful actions
    statement.Effect == "Allow"
    statement.Resource == "*"
    
    # List of dangerous actions that should never have Resource: *
    dangerous_action := statement.Action[_]
    dangerous_action in ["iam:*", "s3:*", "ec2:*", "lambda:*"]
    
    msg := sprintf(
        "CRITICAL: IAM policy '%s' allows '%s' on all resources (Resource: *). Scope to specific resources.",
        [resource.name, dangerous_action]
    )
}

# Deny if IAM policy allows both Action and Resource wildcards
deny[msg] {
    resource := input.resource_changes[_]
    resource.type in ["aws_iam_policy", "aws_iam_role_policy", "aws_iam_user_policy"]
    
    policy := json.unmarshal(resource.change.after.policy)
    statement := policy.Statement[_]
    
    statement.Effect == "Allow"
    statement.Action == "*"
    statement.Resource == "*"
    
    msg := sprintf(
        "CRITICAL: IAM policy '%s' allows all actions on all resources. This grants full administrative access.",
        [resource.name]
    )
}

# Warn if IAM user has inline policies (should use managed policies)
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_user_policy"
    
    msg := sprintf(
        "MEDIUM: IAM user '%s' has inline policy. Use managed policies instead for better governance.",
        [resource.name]
    )
}
