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
  description = "ARN of the SNS topic for DR notifications"
  type        = string
}

variable "source_region" {
  description = "AWS region where source servers are located"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "source_server_ids" {
  description = "List of source server IDs to be recovered"
  type        = list(string)
  default     = []
}