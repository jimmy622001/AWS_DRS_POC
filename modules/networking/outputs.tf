output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.dr_vpc.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.dr_private_subnets[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.dr_public_subnets[*].id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.dr_sg.id
}

output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = aws_vpn_connection.dr_vpn_connection.id
}

output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = var.create_client_vpn ? aws_ec2_client_vpn_endpoint.dr_client_vpn[0].id : null
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = var.create_nat_gateway ? aws_nat_gateway.dr_nat_gateway[0].id : null
}