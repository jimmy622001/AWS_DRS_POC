# AWS Analytics infrastructure for reporting and data processing

resource "aws_redshift_cluster" "analytics" {
  cluster_identifier      = "${var.project}-${var.environment}-redshift"
  database_name           = "analytics"
  master_username         = "admin"
  master_password         = "REPLACE_WITH_SECURE_PASSWORD" # Use AWS Secrets Manager in production
  
  node_type               = var.redshift_settings["node_type"]
  number_of_nodes         = var.redshift_settings["number_of_nodes"]
  cluster_subnet_group_name = aws_redshift_subnet_group.analytics.name
  
  vpc_security_group_ids  = [aws_security_group.redshift.id]
  skip_final_snapshot     = var.redshift_settings["skip_final_snapshot"]
  
  tags = {
    Name        = "${var.project}-${var.environment}-redshift"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_redshift_subnet_group" "analytics" {
  name       = "${var.project}-${var.environment}-redshift-subnet-group"
  subnet_ids = var.private_subnets
  
  tags = {
    Name        = "${var.project}-${var.environment}-redshift-subnet-group"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_security_group" "redshift" {
  name        = "${var.project}-${var.environment}-redshift-sg"
  description = "Security group for Redshift cluster"
  vpc_id      = var.vpc_id
  
  # Redshift port
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Restrict to VPC and on-premise networks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-redshift-sg"
    Environment = var.environment
    Project     = var.project
  }
}

# S3 bucket for analytics data
resource "aws_s3_bucket" "analytics" {
  bucket = var.s3_analytics_bucket != "" ? var.s3_analytics_bucket : "${var.project}-${var.environment}-analytics"
  
  tags = {
    Name        = "${var.project}-${var.environment}-analytics"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analytics" {
  bucket = aws_s3_bucket.analytics.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM role for Redshift to access S3
resource "aws_iam_role" "redshift_s3_access" {
  name = "${var.project}-${var.environment}-redshift-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "redshift_s3_access" {
  name   = "${var.project}-${var.environment}-redshift-s3-policy"
  role   = aws_iam_role.redshift_s3_access.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.analytics.arn,
          "${aws_s3_bucket.analytics.arn}/*"
        ]
      }
    ]
  })
}

# Attach the IAM role to the Redshift cluster
resource "aws_redshift_cluster_iam_roles" "analytics" {
  cluster_identifier = aws_redshift_cluster.analytics.cluster_identifier
  iam_role_arns      = [aws_iam_role.redshift_s3_access.arn]
}

# Glue Catalog Database for analytics queries
resource "aws_glue_catalog_database" "analytics" {
  name = "${var.project}_${var.environment}_analytics"
}

# Output the Redshift connection information
output "redshift_endpoint" {
  value = aws_redshift_cluster.analytics.endpoint
}

output "analytics_bucket_name" {
  value = aws_s3_bucket.analytics.id
}