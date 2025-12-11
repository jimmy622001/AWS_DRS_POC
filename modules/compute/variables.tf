variable "vpc_id" {
  description = "VPC ID for compute resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for compute deployment"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for compute instances"
  type        = list(string)
}

variable "dr_activated" {
  description = "Boolean flag to indicate if DR is activated (for cost calculation)"
  type        = bool
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
}

variable "min_size" {
  description = "Minimum size for the autoscaling group"
  type        = number
}

variable "max_size" {
  description = "Maximum size for the autoscaling group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity for the autoscaling group"
  type        = number
}

variable "create_load_balancer" {
  description = "Flag to determine if a load balancer should be created"
  type        = bool
}