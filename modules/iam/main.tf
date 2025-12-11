# IAM Role for DRS with least privilege
resource "aws_iam_role" "drs_role" {
  name = "${var.prefix}-drs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "drs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Custom policy for DRS with least privilege
resource "aws_iam_policy" "drs_policy" {
  name        = "${var.prefix}-drs-policy"
  description = "Policy for AWS DRS with least privilege"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "drs:DescribeSourceServers",
          "drs:GetLaunchConfiguration",
          "drs:GetReplicationConfiguration",
          "drs:UpdateLaunchConfiguration",
          "drs:ListTagsForResource",
          "drs:TagResource",
          "drs:UntagResource"
        ],
        Resource = "arn:aws:drs:*:${var.account_id}:source-server/*"
      },
      {
        Effect = "Allow",
        Action = [
          "drs:DescribeJobs",
          "drs:BatchGetRecoverySnapshots"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ],
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "drs_policy_attachment" {
  role       = aws_iam_role.drs_role.name
  policy_arn = aws_iam_policy.drs_policy.arn
}

# Instance profile for DRS
resource "aws_iam_instance_profile" "drs_instance_profile" {
  name = "${var.prefix}-drs-instance-profile"
  role = aws_iam_role.drs_role.name
}