variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "create_nat_gateway" {
  description = "Flag to determine if a NAT Gateway should be created"
  type        = bool
}

variable "allowed_external_cidrs" {
  description = "List of external CIDR blocks allowed to access resources"
  type        = list(string)
}

variable "customer_gateway_ip" {
  description = "IP address of the customer gateway (on-premise)"
  type        = string
}

variable "customer_gateway_bgp_asn" {
  description = "BGP ASN for the customer gateway"
  type        = number
}

variable "vpn_route_cidrs" {
  description = "List of CIDR blocks for VPN routes"
  type        = list(string)
}

variable "create_client_vpn" {
  description = "Flag to determine if Client VPN should be created"
  type        = bool
}

variable "client_vpn_cidr" {
  description = "CIDR block for the Client VPN"
  type        = string
}

variable "client_vpn_server_cert_arn" {
  description = "ARN of the server certificate for Client VPN"
  type        = string
}

variable "client_vpn_client_cert_arn" {
  description = "ARN of the client certificate for Client VPN"
  type        = string
}