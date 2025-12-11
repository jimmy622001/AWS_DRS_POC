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
  default     = ["0.0.0.0/0"] # Default to all, but should be overridden with specific IPs
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