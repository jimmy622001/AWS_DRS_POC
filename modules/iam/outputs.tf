output "drs_role_arn" {
  description = "ARN of the IAM role for DRS"
  value       = aws_iam_role.drs_role.arn
}

output "drs_role_name" {
  description = "Name of the IAM role for DRS"
  value       = aws_iam_role.drs_role.name
}

output "drs_instance_profile_name" {
  description = "Name of the instance profile for DRS"
  value       = aws_iam_instance_profile.drs_instance_profile.name
}

output "drs_instance_profile_arn" {
  description = "ARN of the instance profile for DRS"
  value       = aws_iam_instance_profile.drs_instance_profile.arn
}