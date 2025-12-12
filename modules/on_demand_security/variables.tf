variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "waf_web_acl_name" {
  description = "Name for the WAF WebACL"
  type        = string
  default     = "dr-banking-web-acl"
}

variable "load_balancer_arn" {
  description = "ARN of the load balancer to associate with the WAF WebACL during failover"
  type        = string
}

variable "create_shield_protection" {
  description = "Whether to create Shield Advanced protection"
  type        = bool
  default     = true
}

variable "shield_resource_arn" {
  description = "ARN of the resource to protect with Shield Advanced"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}