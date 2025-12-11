output "sql_server_endpoint" {
  description = "Endpoint for the SQL Server instance"
  value       = var.dr_activated && var.create_sql_server ? aws_db_instance.dr_sql_server[0].endpoint : null
}

output "mysql_endpoint" {
  description = "Endpoint for the MySQL instance"
  value       = var.dr_activated && var.create_mysql ? aws_db_instance.dr_mysql[0].endpoint : null
}

output "dms_arn" {
  description = "ARN of the DMS replication instance"
  value       = var.create_dms ? aws_dms_replication_instance.dr_dms[0].replication_instance_arn : null
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.dr_db_subnet_group.name
}

output "parameter_group_name" {
  description = "Name of the DB parameter group"
  value       = aws_db_parameter_group.dr_db_parameter_group.name
}