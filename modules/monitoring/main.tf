resource "aws_cloudwatch_dashboard" "dr_dashboard" {
  dashboard_name = "BankingDRDashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "ReplicationLatency", "SourceServerID", "*"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "DRS Replication Latency"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "DataReplicationRate", "SourceServerID", "*"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "DRS Data Replication Rate"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "drs_replication_lag" {
  count               = length(var.source_server_ids)
  alarm_name          = "DRS-ReplicationLag-${var.source_server_ids[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/DRS"
  period              = 300
  statistic           = "Average"
  threshold           = var.replication_lag_threshold_seconds
  alarm_description   = "DRS replication lag exceeds threshold"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    SourceServerID = var.source_server_ids[count.index]
  }
}

resource "aws_cloudwatch_metric_alarm" "recovery_time_objective" {
  alarm_name          = "DR-RecoveryTimeObjective"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedRecoveryTime"
  namespace           = "Custom/DR"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.rto_threshold_minutes * 60
  alarm_description   = "Estimated recovery time exceeds RTO threshold"
  alarm_actions       = [var.sns_topic_arn]
}

# SNS Topic for DR alerts if one is not provided
resource "aws_sns_topic" "dr_alerts" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = "dr-alerts-topic"
}