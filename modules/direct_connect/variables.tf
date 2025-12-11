variable "enabled" {
  description = "Whether to create Direct Connect resources"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "banking-dr"
}

variable "dxcon_bandwidth" {
  description = "Bandwidth of the Direct Connect connection"
  type        = string
  default     = "1Gbps"
}

variable "dx_location" {
  description = "AWS Direct Connect location code"
  type        = string
}

variable "provider_name" {
  description = "The name of the Direct Connect provider"
  type        = string
  default     = null
}

variable "on_prem_bgp_asn" {
  description = "BGP ASN of on-premises equipment"
  type        = number
  default     = 65000
}

variable "aws_side_asn" {
  description = "BGP ASN for AWS side"
  type        = number
  default     = 64512
}

variable "create_dx_gateway" {
  description = "Whether to create a new Direct Connect Gateway"
  type        = bool
  default     = true
}

variable "direct_connect_gateway_id" {
  description = "Existing Direct Connect Gateway ID if not creating a new one"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID to associate with the Direct Connect Gateway"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vlan_id" {
  description = "VLAN ID for the Virtual Interface"
  type        = number
  default     = 100
}

variable "amazon_address" {
  description = "IP address assigned to the Amazon router"
  type        = string
  default     = "169.254.0.1/30"
}

variable "customer_address" {
  description = "IP address assigned to the customer router"
  type        = string
  default     = "169.254.0.2/30"
}

variable "bgp_auth_key" {
  description = "BGP authentication key"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}