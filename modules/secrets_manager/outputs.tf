output "secret_arns" {
  description = "ARNs of the created secrets"
  value       = { for i in range(length(local.secret_names_list)) : local.secret_names_list[i] => aws_secretsmanager_secret.secrets[i].arn }
}

output "secret_ids" {
  description = "IDs of the created secrets"
  value       = { for i in range(length(local.secret_names_list)) : local.secret_names_list[i] => aws_secretsmanager_secret.secrets[i].id }
}