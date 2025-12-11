# General variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "allowed_ips" {
  description = "List of CIDR blocks allowed to access resources (your IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # This should be replaced with your specific IP
}

variable "admin_email" {
  description = "Email address for security notifications"
  type        = string
  default     = "admin@example.com" # Replace with your email
}

variable "vpn_password" {
  description = "Password for VPN connections"
  type        = string
  sensitive   = true
  default     = "ChangeMeToSecurePassword" # Should be replaced in a secure manner
}

# Removed failover_region variable - no cross-region DR needed

variable "dr_activated" {
  description = "Boolean flag to indicate if DR is activated (for cost calculation)"
  type        = bool
}

# Networking variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

# Removed failover_availability_zones variable - no cross-region DR needed

variable "create_nat_gateway" {
  description = "Flag to determine if a NAT Gateway should be created"
  type        = bool
}

variable "allowed_external_cidrs" {
  description = "List of external CIDR blocks allowed to access resources"
  type        = list(string)
}

variable "customer_gateway_ip" {
  description = "IP address of the customer gateway (on-premise)"
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the customer gateway"
  type        = number
}

variable "vpn_route_cidrs" {
  description = "List of CIDR blocks for VPN routes"
  type        = list(string)
}

variable "create_client_vpn" {
  description = "Flag to determine if Client VPN should be created"
  type        = bool
}

variable "client_vpn_cidr" {
  description = "CIDR block for the Client VPN"
  type        = string
}

variable "client_vpn_server_cert_arn" {
  description = "ARN of the server certificate for Client VPN"
  type        = string
}

variable "client_vpn_client_cert_arn" {
  description = "ARN of the client certificate for Client VPN"
  type        = string
}

# Compute variables
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "min_size" {
  description = "Minimum size for the autoscaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum size for the autoscaling group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity for the autoscaling group"
  type        = number
}

variable "create_load_balancer" {
  description = "Flag to determine if a load balancer should be created"
  type        = bool
}

# Database variables
variable "create_sql_server" {
  description = "Flag to determine if SQL Server should be created"
  type        = bool
}

variable "create_mysql" {
  description = "Flag to determine if MySQL should be created"
  type        = bool
}

variable "create_dms" {
  description = "Flag to determine if DMS should be created"
  type        = bool
}

variable "sql_server_storage_gb" {
  description = "Storage size for SQL Server in GB"
  type        = number
}

variable "mysql_storage_gb" {
  description = "Storage size for MySQL in GB"
  type        = number
}

variable "dms_storage_gb" {
  description = "Storage size for DMS in GB"
  type        = number
}

variable "sql_server_version" {
  description = "SQL Server engine version"
  type        = string
}

variable "mysql_version" {
  description = "MySQL engine version"
  type        = string
}

variable "dms_engine_version" {
  description = "DMS engine version"
  type        = string
}

variable "sql_server_instance_class" {
  description = "Instance class for SQL Server"
  type        = string
}

variable "mysql_instance_class" {
  description = "Instance class for MySQL"
  type        = string
}

variable "dms_instance_class" {
  description = "Instance class for DMS"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_family" {
  description = "Database parameter group family"
  type        = string
}

variable "multi_az" {
  description = "Boolean flag to enable Multi-AZ deployment"
  type        = bool
}

variable "backup_retention_days" {
  description = "Number of days to retain automated backups"
  type        = number
}

# Storage variables
variable "vpc_endpoint_id" {
  description = "VPC endpoint ID for Storage Gateway"
  type        = string
}

variable "fsx_storage_capacity" {
  description = "Storage capacity for FSx file system in GiB"
  type        = number
}

variable "fsx_throughput_capacity" {
  description = "Throughput capacity for FSx file system in MB/s"
  type        = number
}

variable "ad_dns_ips" {
  description = "DNS IPs for Active Directory integration"
  type        = list(string)
}

variable "ad_domain_name" {
  description = "Active Directory domain name"
  type        = string
}

variable "ad_password" {
  description = "Active Directory admin password"
  type        = string
  sensitive   = true
}

variable "ad_username" {
  description = "Active Directory admin username"
  type        = string
}

variable "ad_ou_path" {
  description = "Active Directory organizational unit path"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for DR data storage"
  type        = string
}

variable "storage_gateway_role_arn" {
  description = "IAM role ARN for Storage Gateway"
  type        = string
}

variable "datasync_role_arn" {
  description = "IAM role ARN for DataSync"
  type        = string
}

variable "datasync_source_location_arn" {
  description = "ARN of the DataSync source location"
  type        = string
}

# DRS variables
variable "app_server_count" {
  description = "Number of application servers to be replicated"
  type        = number
}

variable "db_server_count" {
  description = "Number of database servers to be replicated"
  type        = number
}

variable "file_server_count" {
  description = "Number of file servers to be replicated"
  type        = number
}

variable "app_server_instance_type" {
  description = "EC2 instance type for recovered app servers"
  type        = string
}

variable "db_server_instance_type" {
  description = "EC2 instance type for recovered database servers"
  type        = string
}

variable "file_server_instance_type" {
  description = "EC2 instance type for recovered file servers"
  type        = string
}

variable "total_server_count" {
  description = "Total number of servers being replicated (for cost estimation)"
  type        = number
}

variable "avg_server_size_gb" {
  description = "Average server size in GB (for cost estimation)"
  type        = number
}

variable "app_server_source_ids" {
  description = "List of app server source IDs for recovery"
  type        = list(string)
  default     = [] # Default empty list for simplicity
}

variable "db_server_source_ids" {
  description = "List of database server source IDs for recovery"
  type        = list(string)
  default     = [] # Default empty list for simplicity
}

variable "file_server_source_ids" {
  description = "List of file server source IDs for recovery"
  type        = list(string)
  default     = [] # Default empty list for simplicity
}

# Monitoring variables
variable "monitoring_source_server_ids" {
  description = "List of DRS source server IDs to monitor"
  type        = list(string)
}

variable "replication_lag_threshold_seconds" {
  description = "Threshold for replication lag alarm in seconds"
  type        = number
}

variable "rto_threshold_minutes" {
  description = "Recovery Time Objective threshold in minutes"
  type        = number
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  type        = string
}

# Direct Connect variables
variable "create_direct_connect" {
  description = "Whether to create Direct Connect resources"
  type        = bool
  default     = true
}

variable "dx_bandwidth" {
  description = "Bandwidth of the Direct Connect connection"
  type        = string
  default     = "1Gbps"
}

variable "dx_location" {
  description = "AWS Direct Connect location code"
  type        = string
  default     = "EqDC2" # This should be replaced with an actual location code
}

variable "on_prem_bgp_asn" {
  description = "BGP ASN of on-premises equipment"
  type        = number
  default     = 65000
}

variable "aws_side_asn" {
  description = "BGP ASN for AWS side"
  type        = number
  default     = 64512
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dr"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "banking-dr"
}

# Source region for disaster recovery
variable "source_region" {
  description = "AWS region where source servers are located"
  type        = string
  default     = "us-east-1"
}

# Data classification variables
variable "data_classification_tags" {
  description = "Map of data classification tags to apply to resources"
  type        = map(string)
  default = {
    "Classification"  = "Confidential"
    "ComplianceReq"   = "GLBA"
    "DataOwner"       = "Banking"
    "DataSteward"     = "dr-team@example.com"
    "RetentionPeriod" = "7Y"
  }
}