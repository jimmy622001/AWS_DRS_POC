output "key_id" {
  description = "The globally unique identifier for the KMS key"
  value       = aws_kms_key.main.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the KMS key"
  value       = aws_kms_key.main.arn
}

output "alias_name" {
  description = "The display name of the alias"
  value       = aws_kms_alias.main.name
}