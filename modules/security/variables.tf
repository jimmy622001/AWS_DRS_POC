variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where NACLs will be applied"
  type        = list(string)
}

variable "allowed_ips" {
  description = "List of CIDR blocks allowed to access resources"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Default to private IP ranges only
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "bank-dr"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}