variable "aws_region" {
  description = "AWS region for the CloudWatch resources"
  type        = string
}

variable "source_server_ids" {
  description = "List of DRS source server IDs to monitor"
  type        = list(string)
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
  description = "ARN of the SNS topic for alarms"
  type        = string
  default     = "" # This default is intentionally empty to allow creation of a new topic
}