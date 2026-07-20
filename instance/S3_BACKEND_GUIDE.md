# Terraform S3 Backend Setup Guide

## Overview
This Terraform configuration stores state in an AWS S3 bucket with state locking via DynamoDB. This provides a centralized, secure, and collaborative state management solution.

## Files

### Backend Configuration Files
- **backend.tf** - Terraform backend configuration
- **backend-config.hcl** - Backend configuration values (copy and customize)
- **s3.tf** - S3 bucket and DynamoDB table resources
- **init-backend.sh** - Shell script to initialize backend with environment variables

### CI/CD Pipeline
- **tf-pipeline.groovy** - Jenkins pipeline with S3 backend support

## Setup Instructions

### Step 1: Update Variables
Edit `terraform.tfvars` and set:
```hcl
terraform_state_bucket = "your-unique-bucket-name-terraform-state"
terraform_lock_table   = "terraform-locks"
```

### Step 2: Create S3 Bucket and DynamoDB Table
First, deploy the infrastructure to create the S3 bucket and DynamoDB table:

```bash
cd instance

# Initialize without backend (local state first)
terraform init

# Create S3 bucket and DynamoDB table
terraform apply -target=aws_s3_bucket.terraform_state \
                 -target=aws_s3_bucket_versioning.terraform_state \
                 -target=aws_s3_bucket_public_access_block.terraform_state \
                 -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state \
                 -target=aws_dynamodb_table.terraform_locks
```

### Step 3: Migrate State to S3
```bash
# Update backend-config.hcl with your bucket name and values
# Then initialize Terraform with S3 backend

terraform init -backend-config=backend-config.hcl -migrate-state
```

Or use the provided script:
```bash
export TERRAFORM_STATE_BUCKET="your-unique-bucket-name-terraform-state"
export AWS_REGION="us-east-1"
bash init-backend.sh
```

### Step 4: Deploy EC2 Instance
```bash
terraform plan
terraform apply -auto-approve
```

## Jenkins Pipeline Setup

### Required Jenkins Credentials
1. **aws-creds** - AWS IAM credentials (AmazonWebServicesCredentialsBinding)
2. **terraform-state-bucket** - S3 bucket name (Secret text)

### In Jenkins:
1. Create credentials:
   - Add AWS credentials with ID `aws-creds`
   - Add secret text `terraform-state-bucket` with your bucket name
2. Create a Pipeline job pointing to `tf-pipeline.groovy`

## S3 Backend Features

### Security
- ✅ Server-side encryption (AES256)
- ✅ Versioning enabled for state recovery
- ✅ Public access blocked
- ✅ State locking with DynamoDB

### State Locking
DynamoDB prevents concurrent Terraform operations on the same state, avoiding corruption:
- Automatic during `terraform plan` and `apply`
- Locked state shows lock owner and timestamp

### Viewing State
```bash
# List all state versions
aws s3api list-object-versions \
  --bucket your-unique-bucket-name-terraform-state \
  --prefix terraform/state

# Download specific state version
aws s3api get-object \
  --bucket your-unique-bucket-name-terraform-state \
  --key terraform/state \
  --version-id <VERSION_ID> \
  terraform.tfstate.backup
```

## Troubleshooting

### "Backend already configured"
If migrating from local state:
```bash
rm -rf .terraform
terraform init -backend-config=backend-config.hcl -migrate-state
```

### "AccessDenied" errors
Ensure AWS credentials have permissions for:
- s3:GetObject, s3:PutObject
- dynamodb:GetItem, dynamodb:PutItem, dynamodb:DeleteItem

### "State lock timeout"
If a lock persists after operations fail:
```bash
terraform force-unlock <LOCK_ID>
```

## Best Practices

1. **Never commit terraform.tfstate locally** - Always use remote state
2. **Restrict S3 bucket access** - Use IAM policies or bucket policies
3. **Enable versioning** - Included in this configuration
4. **Enable encryption** - Included in this configuration
5. **Regular backups** - S3 versioning provides automatic snapshots

## References
- [Terraform S3 Backend Documentation](https://www.terraform.io/language/settings/backends/s3)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/BestPractices.html)
