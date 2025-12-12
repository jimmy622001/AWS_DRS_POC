resource "aws_cloudwatch_event_rule" "dr_test_schedule" {
  name                = "${var.prefix}-dr-test-schedule"
  description         = "Scheduled DR test trigger"
  schedule_expression = var.test_schedule_expression
}

resource "aws_cloudwatch_event_target" "dr_test_target" {
  rule      = aws_cloudwatch_event_rule.dr_test_schedule.name
  target_id = "StartDRTest"
  arn       = var.step_function_arn
  role_arn  = aws_iam_role.eventbridge_invoke_sf.arn

  input = jsonencode({
    testMode        = true
    sourceServerIDs = var.source_server_ids
  })
}

resource "aws_iam_role" "eventbridge_invoke_sf" {
  name = "${var.prefix}-eventbridge-invoke-sf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "invoke_step_function"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "states:StartExecution"
          ]
          Resource = [var.step_function_arn]
        }
      ]
    })
  }
}

resource "aws_cloudwatch_metric_alarm" "rto_breach" {
  alarm_name          = "${var.prefix}-rto-breach"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RecoveryTime"
  namespace           = "Custom/DR"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.rto_threshold_seconds
  alarm_description   = "DR recovery time exceeded RTO threshold"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    TestType = "Scheduled"
  }
}

resource "aws_cloudwatch_dashboard" "dr_testing" {
  dashboard_name = "${var.prefix}-dr-testing"

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
            ["Custom/DR", "RecoveryTime", "TestType", "Scheduled"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "DR Test Recovery Time"
          yAxis = {
            left = {
              min = 0
              max = var.rto_threshold_seconds
            }
          }
          annotations = {
            horizontal = [
              {
                color = "#d62728"
                label = "RTO Threshold (${var.rto_threshold_seconds} seconds)"
                value = var.rto_threshold_seconds
              }
            ]
          }
        }
      }
    ]
  })
}
