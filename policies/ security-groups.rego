###############################################################################
# security-groups.rego — OPA Policy for Security Group Rules
#
# Prevents creation of security groups that allow unrestricted access
###############################################################################

package terraform.security_groups

import future.keywords.in
import future.keywords.if

# METADATA
# title: Restrict SSH Access from Internet
# description: Security groups must not allow SSH (port 22) from 0.0.0.0/0
# custom:
#   severity: CRITICAL
#   frameworks:
#     - CIS AWS Foundations Benchmark 4.1
#     - SOC 2 CC6.1

# Deny if security group allows SSH from 0.0.0.0/0
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    # Check ingress rules
    ingress := resource.change.after.ingress[_]
    
    # Port 22 (SSH)
    ingress.from_port == 22
    ingress.to_port == 22
    
    # From anywhere
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    
    msg := sprintf(
        "CRITICAL: Security group '%s' allows SSH (port 22) from 0.0.0.0/0. Use specific IP ranges instead.",
        [resource.name]
    )
}

# Deny if security group allows RDP from 0.0.0.0/0
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    ingress := resource.change.after.ingress[_]
    
    # Port 3389 (RDP)
    ingress.from_port == 3389
    ingress.to_port == 3389
    
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    
    msg := sprintf(
        "CRITICAL: Security group '%s' allows RDP (port 3389) from 0.0.0.0/0. Use specific IP ranges instead.",
        [resource.name]
    )
}

# Deny if security group has no description
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    not resource.change.after.description
    
    msg := sprintf(
        "MEDIUM: Security group '%s' has no description. Add a description explaining its purpose.",
        [resource.name]
    )
}

# Deny if security group allows all traffic from internet
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    
    ingress := resource.change.after.ingress[_]
    
    # All ports (-1 or 0-65535)
    ingress.from_port == 0
    ingress.to_port == 65535
    
    cidr := ingress.cidr_blocks[_]
    cidr == "0.0.0.0/0"
    
    msg := sprintf(
        "CRITICAL: Security group '%s' allows all traffic from 0.0.0.0/0. This is extremely dangerous.",
        [resource.name]
    )
}
