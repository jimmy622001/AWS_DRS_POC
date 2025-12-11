output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = module.networking.vpn_connection_id
}

output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = module.networking.client_vpn_endpoint_id
}

output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = module.compute.instance_ids
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns_name
}

output "sql_server_endpoint" {
  description = "Endpoint for the SQL Server instance"
  value       = module.database.sql_server_endpoint
}

output "mysql_endpoint" {
  description = "Endpoint for the MySQL instance"
  value       = module.database.mysql_endpoint
}

output "dms_arn" {
  description = "ARN of the DMS replication instance"
  value       = module.database.dms_arn
}

output "fsx_dns_name" {
  description = "DNS name of the FSx file system"
  value       = module.storage.fsx_dns_name
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.storage.s3_bucket_id
}

output "storage_gateway_id" {
  description = "ID of the Storage Gateway"
  value       = module.storage.storage_gateway_id
}

output "recovery_instance_ids" {
  description = "IDs of the created recovery instances"
  value       = module.drs.recovery_instance_ids
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_arn
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value       = module.monitoring.alarm_arns
}