resource "aws_fsx_windows_file_system" "dr_file_system" {
  storage_capacity    = var.fsx_storage_capacity
  subnet_ids          = [var.subnet_id]
  throughput_capacity = var.fsx_throughput_capacity
  deployment_type     = "SINGLE_AZ_1"
  storage_type        = "SSD"

  self_managed_active_directory {
    dns_ips                                = var.ad_dns_ips
    domain_name                            = var.ad_domain_name
    password                               = var.ad_password
    username                               = var.ad_username
    organizational_unit_distinguished_name = var.ad_ou_path
  }

  tags = {
    Name = "dr-fsx-file-system"
  }
}

resource "aws_s3_bucket" "dr_data_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "dr-data-bucket"
  }
}

resource "aws_s3_bucket_versioning" "dr_data_bucket_versioning" {
  bucket = aws_s3_bucket.dr_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dr_data_bucket_encryption" {
  bucket = aws_s3_bucket.dr_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Placeholder for storage gateway resource
# In a real environment, you would need to provide either gateway_ip_address or activation_key
resource "aws_storagegateway_gateway" "file_gateway" {
  gateway_name         = "dr-file-gateway"
  gateway_timezone     = "GMT"
  gateway_type         = "FILE_S3"
  gateway_vpc_endpoint = var.vpc_endpoint_id
  gateway_ip_address   = "192.0.2.10"  # This is a placeholder IP. In a real environment, use the actual gateway IP.

  tags = {
    Name = "dr-file-gateway"
  }
}

resource "aws_storagegateway_smb_file_share" "file_share" {
  gateway_arn     = aws_storagegateway_gateway.file_gateway.arn
  location_arn    = aws_s3_bucket.dr_data_bucket.arn
  role_arn        = var.storage_gateway_role_arn
  file_share_name = "dr-file-share"

  authentication = "ActiveDirectory"

  tags = {
    Name = "dr-smb-file-share"
  }
}

resource "aws_datasync_location_s3" "dr_datasync_dest" {
  s3_bucket_arn = aws_s3_bucket.dr_data_bucket.arn
  subdirectory  = "/datasync"

  s3_config {
    bucket_access_role_arn = var.datasync_role_arn
  }
}

resource "aws_datasync_task" "dr_datasync_task" {
  destination_location_arn = aws_datasync_location_s3.dr_datasync_dest.arn
  source_location_arn      = var.datasync_source_location_arn
  name                     = "dr-datasync-task"

  options {
    verify_mode            = "ONLY_FILES_TRANSFERRED"
    atime                  = "BEST_EFFORT"
    mtime                  = "PRESERVE"
    uid                    = "INT_VALUE"
    gid                    = "INT_VALUE"
    preserve_deleted_files = "REMOVE"
    preserve_devices       = "NONE"
  }
}