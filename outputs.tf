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

output "recovery_orchestration_step_function_arn" {
  description = "ARN of the DR recovery orchestration Step Function"
  value       = module.recovery_orchestration.step_function_arn
}

output "recovery_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule for DR activation"
  value       = module.recovery_orchestration.recovery_event_rule_arn
}

output "data_protection_macie_account_id" {
  description = "ID of the Macie account for DLP"
  value       = module.data_protection.macie_account_id
}

output "data_protection_dlp_findings_bucket" {
  description = "S3 bucket for DLP findings"
  value       = module.data_protection.dlp_findings_bucket
}

# On-Demand Security outputs
output "waf_web_acl_arn" {
  description = "ARN of the WAF WebACL for DR security"
  value       = module.on_demand_security.web_acl_arn
}

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector that activates during DR failover"
  value       = module.on_demand_security.guardduty_detector_id
}

output "enable_security_lambda_arn" {
  description = "ARN of the Lambda function for enabling security services"
  value       = module.on_demand_security.enable_security_lambda_arn
}

output "disable_security_lambda_arn" {
  description = "ARN of the Lambda function for disabling security services"
  value       = module.on_demand_security.disable_security_lambda_arn
}