variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for DLP notifications"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}

variable "config_recorder_id" {
  description = "ID of the AWS Config recorder"
  type        = string
}