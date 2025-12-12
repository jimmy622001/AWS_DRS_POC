resource "aws_cloudwatch_dashboard" "banking_dr_dashboard" {
  dashboard_name = "BankingDRDashboard"
  dashboard_body = jsonencode({
    widgets = [
      # Status Indicators Section
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = "# Banking Disaster Recovery Status Dashboard\nThis dashboard monitors the critical metrics for banking system disaster recovery using AWS DRS."
        }
      },
      # Critical Systems Section
      {
        type   = "text"
        x      = 0
        y      = 2
        width  = 24
        height = 1
        properties = {
          markdown = "## Critical Banking Systems - Must meet 15-minute RTO"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "ReplicationLatency", "SourceServerID", "*", { "label" : "Critical Systems Replication Lag" }]
          ]
          period = 60
          stat   = "Maximum"
          region = var.aws_region
          title  = "Critical Systems - DRS Replication Lag"
          annotations = {
            horizontal : [
              {
                value : 600,
                label : "10-minute Threshold",
                color : "#ff9900"
              },
              {
                value : 900,
                label : "RTO Breach (15 min)",
                color : "#d13212"
              }
            ]
          },
          view : "timeSeries",
          stacked : false
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 3
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "DataReplicationRate", "SourceServerID", "*"]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Critical Systems - Data Replication Rate"
          view : "timeSeries",
          stacked : false
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 3
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "DataTransmitted", "SourceServerID", "*"]
          ]
          period = 3600
          stat   = "Sum"
          region = var.aws_region
          title  = "Critical Systems - Hourly Data Transferred"
          view : "timeSeries",
          stacked : false
        }
      },
      # Standard Systems Section
      {
        type   = "text"
        x      = 0
        y      = 9
        width  = 24
        height = 1
        properties = {
          markdown = "## Standard Banking Systems"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 10
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "ReplicationLatency", "SourceServerID", "*"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Standard Systems - DRS Replication Lag"
          annotations = {
            horizontal : [
              {
                value : 900,
                label : "15-minute Threshold",
                color : "#ff9900"
              },
              {
                value : 1800,
                label : "30-minute Warning",
                color : "#d13212"
              }
            ]
          },
          view : "timeSeries",
          stacked : false
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 10
        width  = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/DRS", "DataReplicationRate", "SourceServerID", "*"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Standard Systems - Data Replication Rate"
          view : "timeSeries",
          stacked : false
        }
      },
      # Network and VPC Flow Logs
      {
        type   = "text"
        x      = 0
        y      = 16
        width  = 24
        height = 1
        properties = {
          markdown = "## Network and Security"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 17
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE '/aws/vpc/enhanced-flowlogs/dr-vpc' | filter action='REJECT' | stats count(*) as RejectCount by srcAddr, dstAddr, dstPort | sort RejectCount desc | limit 10",
          region = var.aws_region,
          title  = "Top 10 Rejected Network Connections",
          view : "table"
        }
      },
      # RTO Compliance
      {
        type   = "text"
        x      = 0
        y      = 23
        width  = 24
        height = 1
        properties = {
          markdown = "## Recovery Time Objective Compliance"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["Custom/DR", "EstimatedRecoveryTime"]
          ]
          period = 300
          stat   = "Maximum"
          region = var.aws_region
          title  = "Estimated Recovery Time vs. RTO"
          annotations = {
            horizontal : [
              {
                value : 900,
                label : "15-minute RTO",
                color : "#d13212"
              }
            ]
          },
          view : "timeSeries",
          stacked : false
        }
      }
    ]
  })
}

# Enhanced replication lag monitoring for banking DRS - critical servers
resource "aws_cloudwatch_metric_alarm" "critical_drs_replication_lag" {
  count               = length(var.critical_source_server_ids)
  alarm_name          = "CRITICAL-DRS-ReplicationLag-${var.critical_source_server_ids[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/DRS"
  period              = 60        # 1-minute intervals for critical systems
  statistic           = "Maximum" # Using maximum instead of average to be more conservative
  threshold           = 600       # 10 minutes (in seconds) - stricter for critical systems
  alarm_description   = "CRITICAL - DRS replication lag exceeds 10 minutes for critical banking system"
  alarm_actions       = [var.critical_sns_topic_arn]
  ok_actions          = [var.critical_sns_topic_arn] # Also notify when alarm resolves
  treat_missing_data  = "breaching"                  # Treat missing data as breaching threshold
  dimensions = {
    SourceServerID = var.critical_source_server_ids[count.index]
  }
  tags = {
    Name     = "critical-drs-replication-lag"
    Service  = "Banking-Core"
    Priority = "Critical"
  }
}

# Standard replication lag monitoring for banking DRS - non-critical servers
resource "aws_cloudwatch_metric_alarm" "standard_drs_replication_lag" {
  count               = length(var.standard_source_server_ids)
  alarm_name          = "DRS-ReplicationLag-${var.standard_source_server_ids[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/DRS"
  period              = 300 # 5-minute intervals for standard systems
  statistic           = "Average"
  threshold           = var.replication_lag_threshold_seconds
  alarm_description   = "DRS replication lag exceeds threshold for standard banking system"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    SourceServerID = var.standard_source_server_ids[count.index]
  }
  tags = {
    Name     = "standard-drs-replication-lag"
    Service  = "Banking-Support"
    Priority = "Standard"
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

