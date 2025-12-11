variable "vpc_id" {
  description = "VPC ID for the DRS source network"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DRS source network"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the DRS source network"
  type        = list(string)
}

variable "dr_activated" {
  description = "Boolean flag to indicate if DR is activated (for cost calculation)"
  type        = bool
}

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

variable "app_server_source_ids" {
  description = "List of app server source IDs for recovery"
  type        = list(string)
  default     = []  # This default is kept for simplicity in this example
}

variable "db_server_source_ids" {
  description = "List of database server source IDs for recovery"
  type        = list(string)
  default     = []  # This default is kept for simplicity in this example
}

variable "file_server_source_ids" {
  description = "List of file server source IDs for recovery"
  type        = list(string)
  default     = []  # This default is kept for simplicity in this example
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