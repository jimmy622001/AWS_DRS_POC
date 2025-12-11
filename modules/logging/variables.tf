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

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID to use for encryption"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where flow logs will be enabled"
  type        = string
}

variable "admin_email" {
  description = "Email address for security notifications"
  type        = string
  default     = ""
}