output "recovery_instance_ids" {
  description = "IDs of the created recovery instances"
  value       = var.dr_activated ? concat(
    aws_drs_recovery_instance.app_servers[*].id,
    aws_drs_recovery_instance.db_servers[*].id,
    aws_drs_recovery_instance.file_servers[*].id
  ) : []
}

output "source_network_id" {
  description = "ID of the DRS source network"
  value       = aws_drs_source_network.main.id
}

output "app_server_recovery_instance_ids" {
  description = "IDs of the app server recovery instances"
  value       = var.dr_activated ? aws_drs_recovery_instance.app_servers[*].id : []
}

output "db_server_recovery_instance_ids" {
  description = "IDs of the database server recovery instances"
  value       = var.dr_activated ? aws_drs_recovery_instance.db_servers[*].id : []
}

output "file_server_recovery_instance_ids" {
  description = "IDs of the file server recovery instances"
  value       = var.dr_activated ? aws_drs_recovery_instance.file_servers[*].id : []
}