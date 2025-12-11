variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "bank-dr"
}

variable "tags" {
  description = "Tags to apply to DRS resources"
  type        = map(string)
  default     = {}
}

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

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for DRS instances"
  type        = string
}

variable "app_server_ami_id" {
  description = "AMI ID for app servers"
  type        = string
  default     = "ami-0a3c3a20c09d6f377" # Default to Amazon Linux 2
}

variable "db_server_ami_id" {
  description = "AMI ID for database servers"
  type        = string
  default     = "ami-0a3c3a20c09d6f377" # Default to Amazon Linux 2
}

variable "file_server_ami_id" {
  description = "AMI ID for file servers"
  type        = string
  default     = "ami-0a3c3a20c09d6f377" # Default to Amazon Linux 2
}

variable "app_server_volume_size" {
  description = "Volume size in GB for app servers"
  type        = number
  default     = 100
}

variable "db_server_volume_size" {
  description = "Volume size in GB for database servers"
  type        = number
  default     = 200
}

variable "file_server_volume_size" {
  description = "Volume size in GB for file servers"
  type        = number
  default     = 500
}

variable "total_server_count" {
  description = "Total number of servers being replicated (for cost estimation)"
  type        = number
}

variable "avg_server_size_gb" {
  description = "Average server size in GB (for cost estimation)"
  type        = number
}