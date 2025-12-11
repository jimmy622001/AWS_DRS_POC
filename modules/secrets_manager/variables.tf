variable "secrets" {
  description = "Map of secret names and their values"
  type        = map(string)
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID to encrypt the secrets"
  type        = string
}

variable "prefix" {
  description = "Prefix for the secret names"
  type        = string
  default     = "bank-dr"
}

variable "recovery_window_in_days" {
  description = "Number of days that AWS Secrets Manager waits before it can delete the secret"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the secrets"
  type        = map(string)
  default     = {}
}