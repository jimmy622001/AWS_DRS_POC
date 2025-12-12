variable "aws_region" {
  description = "AWS region for the CloudWatch resources"
  type        = string
}

variable "critical_source_server_ids" {
  description = "List of critical DRS source server IDs to monitor with stricter thresholds"
  type        = list(string)
  default     = []
}

variable "standard_source_server_ids" {
  description = "List of standard DRS source server IDs to monitor"
  type        = list(string)
  default     = []
}

variable "source_server_ids" {
  description = "List of all DRS source server IDs to monitor (legacy - use critical_source_server_ids and standard_source_server_ids instead)"
  type        = list(string)
  default     = []
}

variable "replication_lag_threshold_seconds" {
  description = "Threshold for replication lag alarm in seconds"
  type        = number
}

variable "rto_threshold_minutes" {
  description = "Recovery Time Objective threshold in minutes"
  type        = number
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for standard alarms"
  type        = string
}

variable "critical_sns_topic_arn" {
  description = "ARN of the SNS topic for critical alarms"
  type        = string
  default     = ""
}
