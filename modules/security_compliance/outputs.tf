output "config_bucket_id" {
  description = "ID of the S3 bucket where AWS Config records are stored"
  value       = aws_s3_bucket.config.id
}

output "config_bucket_arn" {
  description = "ARN of the S3 bucket where AWS Config records are stored"
  value       = aws_s3_bucket.config.arn
}

output "securityhub_arn" {
  description = "ARN of the Security Hub resource"
  value       = aws_securityhub_account.main.id
}