variable "vpc_id" {
  description = "VPC ID for CI/CD resources"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dr, dev, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "repository_name" {
  description = "Name of the CodeCommit repository"
  type        = string
  default     = ""
}

variable "branch_name" {
  description = "Branch name for CI/CD pipelines"
  type        = string
  default     = "main"
}