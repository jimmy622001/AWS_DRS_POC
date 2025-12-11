variable "subnet_id" {
  description = "Subnet ID for FSx deployment"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "VPC endpoint ID for Storage Gateway"
  type        = string
}

variable "fsx_storage_capacity" {
  description = "Storage capacity for FSx file system in GiB"
  type        = number
}

variable "fsx_throughput_capacity" {
  description = "Throughput capacity for FSx file system in MB/s"
  type        = number
}

variable "ad_dns_ips" {
  description = "DNS IPs for Active Directory integration"
  type        = list(string)
}

variable "ad_domain_name" {
  description = "Active Directory domain name"
  type        = string
}

variable "ad_password" {
  description = "Active Directory admin password"
  type        = string
  sensitive   = true
}

variable "ad_username" {
  description = "Active Directory admin username"
  type        = string
}

variable "ad_ou_path" {
  description = "Active Directory organizational unit path"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for DR data storage"
  type        = string
}

variable "storage_gateway_role_arn" {
  description = "IAM role ARN for Storage Gateway"
  type        = string
}

variable "datasync_role_arn" {
  description = "IAM role ARN for DataSync"
  type        = string
}

variable "datasync_source_location_arn" {
  description = "ARN of the DataSync source location"
  type        = string
}