output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = var.dr_activated ? aws_instance.dr_instances[*].id : []
}

output "private_ips" {
  description = "Private IPs of the created EC2 instances"
  value       = var.dr_activated ? aws_instance.dr_instances[*].private_ip : []
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.dr_launch_template.id
}

output "autoscaling_group_id" {
  description = "ID of the autoscaling group"
  value       = var.dr_activated ? aws_autoscaling_group.dr_asg[0].id : null
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = var.dr_activated && var.create_load_balancer ? aws_lb.dr_lb[0].dns_name : null
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.dr_activated && var.create_load_balancer ? aws_lb_target_group.dr_target_group[0].arn : null
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = var.dr_activated && var.create_load_balancer ? aws_lb.dr_lb[0].arn : null
}