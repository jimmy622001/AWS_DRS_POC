output "fsx_id" {
  description = "ID of the FSx file system"
  value       = aws_fsx_windows_file_system.dr_file_system.id
}

output "fsx_dns_name" {
  description = "DNS name of the FSx file system"
  value       = aws_fsx_windows_file_system.dr_file_system.dns_name
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.dr_data_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.dr_data_bucket.arn
}

output "storage_gateway_id" {
  description = "ID of the Storage Gateway"
  value       = aws_storagegateway_gateway.file_gateway.id
}

output "smb_file_share_id" {
  description = "ID of the SMB file share"
  value       = aws_storagegateway_smb_file_share.file_share.id
}

output "datasync_task_id" {
  description = "ID of the DataSync task"
  value       = aws_datasync_task.dr_datasync_task.id
}