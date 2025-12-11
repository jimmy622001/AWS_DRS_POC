# CI/CD infrastructure for development environments

# Create a CodeCommit repository for application code
resource "aws_codecommit_repository" "app_repo" {
  repository_name = var.repository_name != "" ? var.repository_name : "${var.project}-${var.environment}-repo"
  description     = "Application code repository for ${var.project} ${var.environment} environment"
}

# Create an S3 bucket for build artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project}-${var.environment}-artifacts"
  
  tags = {
    Name        = "${var.project}-${var.environment}-artifacts"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project}-${var.environment}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy for CodeBuild
resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project}-${var.environment}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${aws_s3_bucket.artifacts.arn}",
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GitPull"
        ]
        Resource = aws_codecommit_repository.app_repo.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create a CodeBuild project
resource "aws_codebuild_project" "app_build" {
  name          = "${var.project}-${var.environment}-build"
  description   = "Build project for ${var.project} ${var.environment}"
  service_role  = aws_iam_role.codebuild_role.arn
  
  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }
  
  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode             = true
  }
  
  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.app_repo.clone_url_http
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }
  
  tags = {
    Name        = "${var.project}-${var.environment}-build"
    Environment = var.environment
    Project     = var.project
  }
}

# IAM role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project}-${var.environment}-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy for CodePipeline
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project}-${var.environment}-pipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "${aws_s3_bucket.artifacts.arn}",
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:CancelUploadArchive"
        ]
        Resource = aws_codecommit_repository.app_repo.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.app_build.arn
      }
    ]
  })
}

# Create a CodePipeline pipeline
resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.project}-${var.environment}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }
  
  stage {
    name = "Source"
    
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        RepositoryName = aws_codecommit_repository.app_repo.repository_name
        BranchName     = var.branch_name
      }
    }
  }
  
  stage {
    name = "Build"
    
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      
      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }
  
  # You can add deployment stages here for different environments
  
  tags = {
    Name        = "${var.project}-${var.environment}-pipeline"
    Environment = var.environment
    Project     = var.project
  }
}

# Output the repository clone URL
output "repository_clone_url_http" {
  value = aws_codecommit_repository.app_repo.clone_url_http
}

output "pipeline_name" {
  value = aws_codepipeline.app_pipeline.name
}