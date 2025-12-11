variable "vpc_id" {
  description = "VPC ID for analytics resources"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for analytics resources"
  type        = list(string)
}

variable "environment" {
  description = "Environment name (e.g., dr, dev, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "redshift_settings" {
  description = "Settings for Redshift cluster"
  type        = map(string)
}

variable "s3_analytics_bucket" {
  description = "Name for S3 bucket to store analytics data"
  type        = string
  default     = ""
}

variable "database_source" {
  description = "Database endpoint for data sources"
  type        = string
}