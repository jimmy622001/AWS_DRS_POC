###############################################
# AWS Step Functions for Automated DR Orchestration
###############################################

# IAM Role for Step Function execution
resource "aws_iam_role" "step_function_role" {
  name = "${var.prefix}-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Step Function execution
resource "aws_iam_policy" "step_function_policy" {
  name        = "${var.prefix}-step-function-policy"
  description = "Policy for AWS Step Functions to orchestrate DR recovery"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "drs:InitiateRecovery",
          "drs:DescribeRecoveryInstances",
          "drs:DescribeJobs",
          "drs:DescribeSourceServers"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          aws_lambda_function.pre_recovery_checks.arn,
          aws_lambda_function.post_recovery_validation.arn,
          aws_lambda_function.notify_recovery_status.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

# Lambda function for pre-recovery checks
resource "aws_lambda_function" "pre_recovery_checks" {
  function_name = "${var.prefix}-pre-recovery-checks"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  timeout       = 300

  filename         = "${path.module}/lambda/pre_recovery_checks.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/pre_recovery_checks.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = var.tags
}

# Lambda function for post-recovery validation
resource "aws_lambda_function" "post_recovery_validation" {
  function_name = "${var.prefix}-post-recovery-validation"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  timeout       = 300

  filename         = "${path.module}/lambda/post_recovery_validation.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/post_recovery_validation.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = var.tags
}

# Lambda function for recovery notifications
resource "aws_lambda_function" "notify_recovery_status" {
  function_name = "${var.prefix}-notify-recovery-status"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  timeout       = 60

  filename         = "${path.module}/lambda/notify_recovery_status.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/notify_recovery_status.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = var.tags
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}-dr-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for Lambda functions
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.prefix}-dr-lambda-policy"
  description = "Policy for DR Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "drs:DescribeSourceServers",
          "drs:DescribeRecoveryInstances",
          "drs:DescribeJobs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Attach policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Step Function state machine for DR orchestration
resource "aws_sfn_state_machine" "dr_orchestration" {
  name     = "${var.prefix}-dr-orchestration"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "Comment": "AWS DRS Recovery Orchestration",
  "StartAt": "PreRecoveryChecks",
  "States": {
    "PreRecoveryChecks": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.pre_recovery_checks.arn}",
      "Next": "CheckPreRecoveryStatus",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "NotifyFailure"
        }
      ]
    },
    "CheckPreRecoveryStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.preChecksPassed",
          "BooleanEquals": true,
          "Next": "InitiateRecovery"
        }
      ],
      "Default": "NotifyFailure"
    },
    "InitiateRecovery": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:drs:initiateRecovery",
      "Parameters": {
        "SourceServerIDs.$": "$.sourceServerIDs"
      },
      "Next": "WaitForRecovery",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "NotifyFailure"
        }
      ]
    },
    "WaitForRecovery": {
      "Type": "Wait",
      "Seconds": 60,
      "Next": "CheckRecoveryStatus"
    },
    "CheckRecoveryStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:drs:describeJobs",
      "Parameters": {
        "Filters": {
          "JobIDs.$": "$.jobId"
        }
      },
      "Next": "EvaluateRecoveryStatus",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "NotifyFailure"
        }
      ]
    },
    "EvaluateRecoveryStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.jobs[0].status",
          "StringEquals": "COMPLETED",
          "Next": "PostRecoveryValidation"
        },
        {
          "Variable": "$.jobs[0].status",
          "StringEquals": "PENDING",
          "Next": "WaitForRecovery"
        },
        {
          "Variable": "$.jobs[0].status",
          "StringEquals": "IN_PROGRESS",
          "Next": "WaitForRecovery"
        }
      ],
      "Default": "NotifyFailure"
    },
    "PostRecoveryValidation": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.post_recovery_validation.arn}",
      "Next": "CheckPostRecoveryValidation",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "Next": "NotifyFailure"
        }
      ]
    },
    "CheckPostRecoveryValidation": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.validationPassed",
          "BooleanEquals": true,
          "Next": "NotifySuccess"
        }
      ],
      "Default": "NotifyFailure"
    },
    "NotifySuccess": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.notify_recovery_status.arn}",
      "Parameters": {
        "status": "SUCCESS",
        "message": "DR Recovery completed successfully",
        "details.$": "$"
      },
      "End": true
    },
    "NotifyFailure": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.notify_recovery_status.arn}",
      "Parameters": {
        "status": "FAILED",
        "message": "DR Recovery failed",
        "details.$": "$"
      },
      "End": true
    }
  }
}
EOF

  tags = var.tags
}

# CloudWatch Event Rule for automated DR activation
resource "aws_cloudwatch_event_rule" "dr_activation" {
  name        = "${var.prefix}-dr-activation"
  description = "Trigger DR recovery when source region becomes unavailable"

  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "detail" : {
      "service" : ["EC2"],
      "eventTypeCategory" : ["issue"],
      "region" : [var.source_region]
    }
  })

  tags = var.tags
}

# CloudWatch Event Target for Step Function
resource "aws_cloudwatch_event_target" "dr_step_function" {
  rule      = aws_cloudwatch_event_rule.dr_activation.name
  target_id = "TriggerDROrchestration"
  arn       = aws_sfn_state_machine.dr_orchestration.arn
  role_arn  = aws_iam_role.event_bridge_role.arn
}

# IAM role for EventBridge
resource "aws_iam_role" "event_bridge_role" {
  name = "${var.prefix}-event-bridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for EventBridge
resource "aws_iam_policy" "event_bridge_policy" {
  name        = "${var.prefix}-event-bridge-policy"
  description = "Policy for EventBridge to invoke Step Function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "states:StartExecution"
        ],
        Resource = aws_sfn_state_machine.dr_orchestration.arn
      }
    ]
  })
}

# Attach policy to EventBridge role
resource "aws_iam_role_policy_attachment" "event_bridge_policy_attachment" {
  role       = aws_iam_role.event_bridge_role.name
  policy_arn = aws_iam_policy.event_bridge_policy.arn
}