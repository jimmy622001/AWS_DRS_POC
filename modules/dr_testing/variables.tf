variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "test_schedule_expression" {
  description = "Schedule expression for DR tests (cron format)"
  type        = string
  default     = "cron(0 1 ? * SUN *)" # Default: Weekly on Sunday at 1 AM
}

variable "step_function_arn" {
  description = "ARN of the Step Function to trigger for DR testing"
  type        = string
}

variable "source_server_ids" {
  description = "List of source server IDs to include in DR tests"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for test notifications"
  type        = string
}

variable "rto_threshold_seconds" {
  description = "RTO threshold in seconds for test validation"
  type        = number
  default     = 900 # 15 minutes
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
