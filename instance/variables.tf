variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance"
  default     = "my-web-server"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod, etc.)"
  default     = "dev"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GB"
  default     = 20
}

variable "key_pair_name" {
  type        = string
  description = "Name of the EC2 key pair for SSH access"
  nullable    = false
}

variable "subnet_id" {
  type        = string
  description = "VPC subnet ID where instance will be deployed"
  nullable    = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the security group"
  nullable    = false
}

variable "allowed_ssh_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed for SSH access"
  default     = ["0.0.0.0/0"]
}

variable "terraform_state_bucket" {
  type        = string
  description = "S3 bucket name for storing Terraform state"
  nullable    = false
}

variable "terraform_lock_table" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"
  default     = "terraform-locks"
}
