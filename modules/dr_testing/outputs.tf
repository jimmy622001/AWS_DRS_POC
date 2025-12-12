output "event_rule_arn" {
  description = "ARN of the EventBridge rule for DR testing"
  value       = aws_cloudwatch_event_rule.dr_test_schedule.arn
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard for DR testing"
  value       = aws_cloudwatch_dashboard.dr_testing.dashboard_arn
}

output "alarm_arn" {
  description = "ARN of the RTO breach alarm"
  value       = aws_cloudwatch_metric_alarm.rto_breach.arn
}
