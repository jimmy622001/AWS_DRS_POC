output "recovery_instance_ids" {
  description = "IDs of the created recovery instances"
  value = var.dr_activated ? concat(
    aws_instance.app_servers[*].id,
    aws_instance.db_servers[*].id,
    aws_instance.file_servers[*].id
  ) : []
}

output "network_config" {
  description = "Configuration of the DRS network"
  value       = local.drs_network_config
}

output "app_server_recovery_instance_ids" {
  description = "IDs of the app server recovery instances"
  value       = var.dr_activated ? aws_instance.app_servers[*].id : []
}

output "db_server_recovery_instance_ids" {
  description = "IDs of the database server recovery instances"
  value       = var.dr_activated ? aws_instance.db_servers[*].id : []
}

output "file_server_recovery_instance_ids" {
  description = "IDs of the file server recovery instances"
  value       = var.dr_activated ? aws_instance.file_servers[*].id : []
}