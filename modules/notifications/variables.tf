variable "create_topic" {
  description = "Whether to create a new SNS topic"
  type        = bool
  default     = true
}

variable "topic_name" {
  description = "Name of the SNS topic. If not provided, will be generated using the prefix"
  type        = string
  default     = ""
}

variable "topic_arn" {
  description = "ARN of an existing SNS topic to use instead of creating a new one"
  type        = string
  default     = ""
}

variable "admin_email" {
  description = "Email address for admin notifications"
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "The ID of the KMS key used to encrypt the SNS topic"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
