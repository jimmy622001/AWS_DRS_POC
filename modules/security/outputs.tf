output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.drs_sg.id
}

output "nacl_id" {
  description = "The ID of the NACL"
  value       = aws_network_acl.drs_nacl.id
}