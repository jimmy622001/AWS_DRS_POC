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

output "config_recorder_id" {
  description = "ID of the AWS Config recorder"
  value       = aws_config_configuration_recorder.main.id
}

output "config_recorder_role_arn" {
  description = "ARN of the IAM role used by AWS Config recorder"
  value       = aws_iam_role.config.arn
}

output "cis_standard_subscription_arn" {
  description = "ARN of the CIS AWS Foundations Benchmark standard subscription"
  value       = aws_securityhub_standards_subscription.cis.id
}

output "pci_dss_standard_subscription_arn" {
  description = "ARN of the PCI DSS standard subscription"
  value       = aws_securityhub_standards_subscription.pci_dss.id
}