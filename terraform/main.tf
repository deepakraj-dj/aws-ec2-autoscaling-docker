# Configure AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create Launch Template
resource "aws_launch_template" "nginx" {
  name          = "nginx-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  # Embed user_data script (pulls Docker image from ECR and starts container)
  user_data = base64encode(file("${path.module}/user_data.sh"))

  # IAM role for EC2 (needs ECR pull permissions)
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  # Security group
  vpc_security_group_ids = var.security_group_ids

  # Enable detailed CloudWatch monitoring
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-instance"
    }
  }
}

# Reference existing Auto Scaling Group
data "aws_autoscaling_group" "nginx" {
  name = var.asg_name
}

# Output the new Launch Template ID
output "launch_template_id" {
  description = "ID of the new Launch Template to use in your existing ASG"
  value       = aws_launch_template.nginx.id
}
