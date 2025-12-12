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
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.dr_notifications[0].arn]
  }
}

# Email subscription for admin notifications
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

# Outputs
output "topic_arn" {
  description = "The ARN of the SNS topic"
  value       = var.create_topic ? aws_sns_topic.dr_notifications[0].arn : var.topic_arn
}

output "topic_name" {
  description = "The name of the SNS topic"
  value       = var.create_topic ? aws_sns_topic.dr_notifications[0].name : ""
}

# Data source for current account ID
data "aws_caller_identity" "current" {}
