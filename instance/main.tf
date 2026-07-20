# Data source to fetch the most recent Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "instance_sg" {
  name        = "ec2-instance-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "ec2-instance-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  # Enable detailed monitoring
  monitoring = true

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "root-volume"
    }
  }

  # User data script to install and start a web server
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (optional - uncomment if needed)
# resource "aws_eip" "instance_eip" {
#   instance = aws_instance.web_server.id
#   domain   = "vpc"
#
#   tags = {
#     Name = "${var.instance_name}-eip"
#   }
# }

# Outputs
output "instance_id" {
  value       = aws_instance.web_server.id
  description = "The ID of the EC2 instance"
}

output "instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP address of the EC2 instance"
}

output "instance_private_ip" {
  value       = aws_instance.web_server.private_ip
  description = "The private IP address of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.instance_sg.id
  description = "The ID of the security group"
}
