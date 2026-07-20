# Backend configuration for Terraform S3 state
# Use this file with: terraform init -backend-config=backend-config.hcl

bucket         = "your-unique-bucket-name-terraform-state"
key            = "terraform/state"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-locks"
