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

variable "region" {
  description = "AWS region"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID to use for encryption"
  type        = string
}