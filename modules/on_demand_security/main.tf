/**
 * # On-Demand Security Module
 *
 * This module provides advanced security capabilities that activate ONLY during an actual DR failover,
 * avoiding unnecessary ongoing costs during normal operations.
 */

# ---------------------------------------------------------------------------------------------------------------------
# AWS WAF WebACL - Configured but dormant until activated
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "dr_web_acl" {
  name        = var.waf_web_acl_name
  description = "DR failover Web ACL with banking-specific protections"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # SQL Injection protection rule
  rule {
    name     = "SqlInjectionRule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SqlInjectionRule"
      sampled_requests_enabled   = true
    }
  }

  # Cross-site scripting protection rule
  rule {
    name     = "XssRule"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            block {}
          }
          name = "CrossSiteScripting_BODY"
        }

        rule_action_override {
          action_to_use {
            block {}
          }
          name = "CrossSiteScripting_QUERYARGUMENTS"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XssRule"
      sampled_requests_enabled   = true
    }
  }

  # Banking-specific rule for large money transfers
  rule {
    name     = "LargeMoneyTransferInspection"
    priority = 3

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string         = "amount=[1-9][0-9]{5,}"
        positional_constraint = "CONTAINS"

        field_to_match {
          uri_path {}
        }

        text_transformation {
          priority = 0
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LargeMoneyTransferInspection"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DR-WebACL"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# GuardDuty Detector - Created in disabled state
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_guardduty_detector" "dr_detector" {
  enable                       = false # Disabled by default, activated during DR failover
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  # Note: Using the latest AWS provider version, features should be enabled via separate resources
  # rather than using the features block which is not supported in the current provider

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Shield Advanced Protection - Pre-configured but not active
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_shield_protection" "dr_shield_protection" {
  count        = var.create_shield_protection && var.shield_resource_arn != "" ? 1 : 0
  name         = "${var.environment}-dr-shield-protection"
  resource_arn = var.shield_resource_arn

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Role for Lambda Functions
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "security_lambda_role" {
  name = "${var.environment}-security-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  # managed_policy_arns is deprecated, using aws_iam_role_policy_attachment instead

  tags = var.tags
}

# Create IAM role policy attachment for Lambda basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.security_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create IAM role policy instead of using deprecated inline_policy
resource "aws_iam_role_policy" "security_services_management" {
  name = "SecurityServicesManagement"
  role = aws_iam_role.security_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:DescribeLoadBalancers",
          "guardduty:UpdateDetector",
          "guardduty:GetDetector",
          "shield:CreateProtection",
          "shield:DeleteProtection",
          "shield:DescribeProtection"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Lambda Function to Enable Security Services
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "enable_security_lambda" {
  filename      = "${path.module}/lambda/enable_security.zip"
  function_name = "${var.environment}-enable-security-lambda"
  role          = aws_iam_role.security_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 60

  environment {
    variables = {
      WEB_ACL_ARN       = aws_wafv2_web_acl.dr_web_acl.arn
      GUARDDUTY_ID      = aws_guardduty_detector.dr_detector.id
      LOAD_BALANCER_ARN = var.load_balancer_arn
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Lambda Function to Disable Security Services
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "disable_security_lambda" {
  filename      = "${path.module}/lambda/disable_security.zip"
  function_name = "${var.environment}-disable-security-lambda"
  role          = aws_iam_role.security_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 60

  environment {
    variables = {
      GUARDDUTY_ID      = aws_guardduty_detector.dr_detector.id
      LOAD_BALANCER_ARN = var.load_balancer_arn
    }
  }

  tags = var.tags
}