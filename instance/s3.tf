# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket

  tags = {
    Name        = "${var.instance_name}-terraform-state"
    Environment = var.environment
    Purpose     = "Terraform State Storage"
  }
}

# Enable versioning on state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.terraform_lock_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.instance_name}-terraform-locks"
    Environment = var.environment
    Purpose     = "Terraform State Locking"
  }
}

# Output the S3 bucket and DynamoDB table details
output "terraform_state_bucket" {
  value       = aws_s3_bucket.terraform_state.id
  description = "S3 bucket for Terraform state"
}

output "terraform_lock_table" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table for Terraform state locking"
}
