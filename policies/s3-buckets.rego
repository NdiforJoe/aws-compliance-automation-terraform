###############################################################################
# s3-buckets.rego — OPA Policy for S3 Bucket Security
#
# Enforces encryption, versioning, and public access blocks
###############################################################################

package terraform.s3_buckets

import future.keywords.in
import future.keywords.if

# METADATA
# title: S3 Bucket Security Requirements
# description: S3 buckets must have encryption, versioning, and public access blocked
# custom:
#   severity: HIGH
#   frameworks:
#     - CIS AWS Foundations Benchmark 2.1
#     - SOC 2 CC6.1
#     - NIST CSF PR.DS-1

# Deny if S3 bucket lacks encryption configuration
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    
    # Check if there's a corresponding encryption configuration
    bucket_name := resource.change.after.bucket
    not has_encryption_config(bucket_name)
    
    msg := sprintf(
        "HIGH: S3 bucket '%s' does not have server-side encryption configured. Add aws_s3_bucket_server_side_encryption_configuration.",
        [resource.name]
    )
}

# Helper: Check if encryption config exists for bucket
has_encryption_config(bucket_name) {
    encryption := input.resource_changes[_]
    encryption.type == "aws_s3_bucket_server_side_encryption_configuration"
    encryption.change.after.bucket == bucket_name
}

# Deny if S3 bucket lacks versioning
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    
    bucket_name := resource.change.after.bucket
    not has_versioning_enabled(bucket_name)
    
    msg := sprintf(
        "HIGH: S3 bucket '%s' does not have versioning enabled. Add aws_s3_bucket_versioning with status='Enabled'.",
        [resource.name]
    )
}

# Helper: Check if versioning is enabled
has_versioning_enabled(bucket_name) {
    versioning := input.resource_changes[_]
    versioning.type == "aws_s3_bucket_versioning"
    versioning.change.after.bucket == bucket_name
    versioning.change.after.versioning_configuration[_].status == "Enabled"
}

# Deny if S3 bucket lacks public access block
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    
    bucket_name := resource.change.after.bucket
    not has_public_access_block(bucket_name)
    
    msg := sprintf(
        "HIGH: S3 bucket '%s' does not have public access blocked. Add aws_s3_bucket_public_access_block.",
        [resource.name]
    )
}

# Helper: Check if public access block exists
has_public_access_block(bucket_name) {
    pab := input.resource_changes[_]
    pab.type == "aws_s3_bucket_public_access_block"
    pab.change.after.bucket == bucket_name
    pab.change.after.block_public_acls == true
    pab.change.after.block_public_policy == true
    pab.change.after.ignore_public_acls == true
    pab.change.after.restrict_public_buckets == true
}

# Deny if bucket name doesn't follow naming convention
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    
    bucket_name := resource.change.after.bucket
    
    # Check if bucket name starts with project prefix
    not startswith(bucket_name, "cop310-")
    
    msg := sprintf(
        "MEDIUM: S3 bucket '%s' does not follow naming convention. Bucket names should start with 'cop310-'.",
        [bucket_name]
    )
}
