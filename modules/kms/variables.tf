variable "description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for banking DR solution"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "key_policy" {
  description = "A valid KMS key policy JSON document"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Prefix to use for the KMS alias"
  type        = string
  default     = "bank-dr"
}

variable "tags" {
  description = "Tags to apply to the KMS key"
  type        = map(string)
  default     = {}
}