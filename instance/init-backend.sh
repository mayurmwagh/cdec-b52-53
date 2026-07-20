#!/bin/bash
# Script to initialize Terraform backend with S3 state

set -e

# Configuration
BUCKET_NAME=${TERRAFORM_STATE_BUCKET:-"terraform-state-$(date +%s)"}
REGION=${AWS_REGION:-"us-east-1"}
LOCK_TABLE="terraform-locks"

echo "Initializing Terraform S3 backend..."
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "Lock Table: $LOCK_TABLE"

# Initialize Terraform with backend configuration
terraform init \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="key=terraform/state" \
  -backend-config="region=$REGION" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=$LOCK_TABLE"

echo "Terraform backend initialized successfully!"
