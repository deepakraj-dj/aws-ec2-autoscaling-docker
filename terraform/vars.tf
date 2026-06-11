variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu with Docker)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name (must have ECR pull permissions)"
  type        = string
}

variable "asg_name" {
  description = "Name of your existing Auto Scaling Group"
  type        = string
}
