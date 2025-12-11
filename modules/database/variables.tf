variable "subnet_ids" {
  description = "List of subnet IDs for database deployment"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for database instances"
  type        = list(string)
}

variable "dr_activated" {
  description = "Boolean flag to indicate if DR is activated (for cost calculation)"
  type        = bool
}

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