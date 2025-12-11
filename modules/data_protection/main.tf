# AWS DLP (Data Loss Prevention) solution for banking data

# Macie for data classification and PII detection
resource "aws_macie2_account" "main" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# S3 bucket for DLP finding reports
resource "aws_s3_bucket" "dlp_findings" {
  bucket        = "${var.prefix}-dlp-findings-${var.account_id}"
  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name           = "${var.prefix}-dlp-findings-bucket"
      Classification = "Confidential"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dlp_findings" {
  bucket = aws_s3_bucket.dlp_findings.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "dlp_findings" {
  bucket                  = aws_s3_bucket.dlp_findings.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "dlp_findings" {
  bucket = aws_s3_bucket.dlp_findings.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Macie classification job for custom data identifier
resource "aws_macie2_custom_data_identifier" "pci_data" {
  name        = "${var.prefix}-pci-data"
  description = "Custom identifier for PCI data (credit card numbers)"
  regex       = "(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\\d{3})\\d{11})"

  tags = var.tags
}

resource "aws_macie2_custom_data_identifier" "bank_account" {
  name        = "${var.prefix}-bank-account"
  description = "Custom identifier for bank account numbers"
  regex       = "\\b[0-9]{8,17}\\b"
  keywords    = ["account", "acct", "checking", "savings", "IBAN"]

  tags = var.tags
}

resource "aws_macie2_custom_data_identifier" "ssn" {
  name        = "${var.prefix}-ssn"
  description = "Custom identifier for Social Security Numbers"
  regex       = "\\b(?!000|666|9\\d{2})\\d{3}-(?!00)\\d{2}-(?!0000)\\d{4}\\b"

  tags = var.tags
}

# Configure AWS Config Rule for data classification tags
resource "aws_config_config_rule" "required_classification_tags" {
  name        = "${var.prefix}-required-classification-tags"
  description = "Checks whether required data classification tags are applied to resources"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key   = "Classification"
    tag1Value = "Public,Internal,Confidential,Restricted"
  })

  depends_on = [var.config_recorder_id]
}

# DLP remediation actions using Lambda function
resource "aws_lambda_function" "dlp_remediation" {
  function_name = "${var.prefix}-dlp-remediation"
  role          = aws_iam_role.dlp_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  timeout       = 300

  filename         = "${path.module}/lambda/dlp_remediation.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/dlp_remediation.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = var.tags
}

# CloudWatch Event Rule for Macie findings
resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = "${var.prefix}-macie-findings"
  description = "Capture Macie findings for sensitive data"

  event_pattern = jsonencode({
    "source" : ["aws.macie"],
    "detail-type" : ["Macie Finding"]
  })

  tags = var.tags
}

# CloudWatch Event Target for DLP remediation
resource "aws_cloudwatch_event_target" "dlp_remediation" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "DLPRemediationFunction"
  arn       = aws_lambda_function.dlp_remediation.arn
}

# IAM role for DLP Lambda function
resource "aws_iam_role" "dlp_lambda_role" {
  name = "${var.prefix}-dlp-lambda-role"

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

# IAM policy for DLP Lambda function
resource "aws_iam_policy" "dlp_lambda_policy" {
  name        = "${var.prefix}-dlp-lambda-policy"
  description = "Policy for DLP Lambda remediation function"

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
          "macie2:GetFindings",
          "macie2:UpdateFindingsStatus"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObjectTagging",
          "s3:PutEncryptionConfiguration",
          "s3:PutObjectLegalHold",
          "s3:GetBucketEncryption"
        ],
        Resource = [
          "arn:aws:s3:::*"
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

# Attach policy to Lambda role
resource "aws_iam_role_policy_attachment" "dlp_lambda_policy_attachment" {
  role       = aws_iam_role.dlp_lambda_role.name
  policy_arn = aws_iam_policy.dlp_lambda_policy.arn
}

# Allow CloudWatch to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dlp_remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.macie_findings.arn
}

# Data classification tagging policy
resource "aws_resourcegroups_group" "classified_resources" {
  name = "${var.prefix}-classified-resources"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [
        {
          Key    = "Classification",
          Values = ["Confidential", "Restricted"]
        }
      ]
    })
  }

  tags = var.tags
}