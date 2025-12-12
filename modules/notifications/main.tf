# Standard DR Notifications SNS Topic
resource "aws_sns_topic" "dr_notifications" {
  count = var.create_topic ? 1 : 0

  name              = var.topic_name != "" ? var.topic_name : "${var.prefix}-dr-notifications"
  display_name      = "${var.prefix} DR Notifications"
  kms_master_key_id = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.prefix}-dr-notifications"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Priority    = "Standard"
    }
  )
}

# Critical DR Notifications SNS Topic for time-sensitive alerts
resource "aws_sns_topic" "critical_dr_notifications" {
  count = var.create_critical_topic ? 1 : 0

  name              = var.critical_topic_name != "" ? var.critical_topic_name : "${var.prefix}-critical-dr-notifications"
  display_name      = "${var.prefix} Critical DR Notifications"
  kms_master_key_id = var.kms_key_id

  # Apply a more strict delivery policy for critical notifications
  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 1,
        "maxDelayTarget" : 10,
        "numRetries" : 5,
        "numMaxDelayRetries" : 3,
        "numNoDelayRetries" : 1,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.prefix}-critical-dr-notifications"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Priority    = "Critical"
      Service     = "Banking-Core-DR"
    }
  )
}

resource "aws_sns_topic_policy" "default" {
  count = var.create_topic ? 1 : 0

  arn    = aws_sns_topic.dr_notifications[0].arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.dr_notifications[0].arn
    ]

    sid = "__default_statement_ID"
  }

  # Allow CloudWatch Events to publish to this topic
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "cloudwatch.amazonaws.com", "lambda.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.dr_notifications[0].arn]
  }
}

# Policy for critical notifications
resource "aws_sns_topic_policy" "critical_notifications" {
  count = var.create_critical_topic ? 1 : 0

  arn    = aws_sns_topic.critical_dr_notifications[0].arn
  policy = data.aws_iam_policy_document.critical_sns_topic_policy.json
}

data "aws_iam_policy_document" "critical_sns_topic_policy" {
  policy_id = "__critical_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = var.create_critical_topic ? [aws_sns_topic.critical_dr_notifications[0].arn] : []

    sid = "__critical_default_statement_ID"
  }

  # Allow CloudWatch Events and CloudWatch to publish to this topic
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "cloudwatch.amazonaws.com", "lambda.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = var.create_critical_topic ? [aws_sns_topic.critical_dr_notifications[0].arn] : []
  }
}

# Email subscription for standard admin notifications
resource "aws_sns_topic_subscription" "admin_email" {
  count = var.create_topic && var.admin_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.dr_notifications[0].arn
  protocol  = "email"
  endpoint  = var.admin_email

  # Prevent diffs when unsubscribing on destroy
  confirmation_timeout_in_minutes = 5

  lifecycle {
    ignore_changes = [endpoint]
  }
}

# Email subscription for critical admin notifications
resource "aws_sns_topic_subscription" "critical_admin_email" {
  count = var.create_critical_topic && var.critical_admin_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.critical_dr_notifications[0].arn
  protocol  = "email"
  endpoint  = var.critical_admin_email

  # Prevent diffs when unsubscribing on destroy
  confirmation_timeout_in_minutes = 5

  lifecycle {
    ignore_changes = [endpoint]
  }
}

# Outputs
output "topic_arn" {
  description = "The ARN of the standard SNS topic"
  value       = var.create_topic ? aws_sns_topic.dr_notifications[0].arn : var.topic_arn
}

output "topic_name" {
  description = "The name of the standard SNS topic"
  value       = var.create_topic ? aws_sns_topic.dr_notifications[0].name : ""
}

output "critical_topic_arn" {
  description = "The ARN of the critical SNS topic"
  value       = var.create_critical_topic ? aws_sns_topic.critical_dr_notifications[0].arn : ""
}

output "critical_topic_name" {
  description = "The name of the critical SNS topic"
  value       = var.create_critical_topic ? aws_sns_topic.critical_dr_notifications[0].name : ""
}

# Data source for current account ID
data "aws_caller_identity" "current" {}
