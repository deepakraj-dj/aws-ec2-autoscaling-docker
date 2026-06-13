
output "launch_template_id" {
  description = "ID of the new Launch Template to use in your existing ASG"
  value       = aws_launch_template.nginx.id
}
