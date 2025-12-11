output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.dr_dashboard.dashboard_arn
}

output "alarm_arns" {
  description = "ARNs of the CloudWatch alarms"
  value = concat(
    aws_cloudwatch_metric_alarm.drs_replication_lag[*].arn,
    [aws_cloudwatch_metric_alarm.recovery_time_objective.arn]
  )
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = var.sns_topic_arn != "" ? var.sns_topic_arn : join("", aws_sns_topic.dr_alerts[*].arn)
}