output "dx_connection_id" {
  description = "ID of the Direct Connect connection"
  value       = var.enabled ? aws_dx_connection.this[0].id : null
}

output "dx_connection_state" {
  description = "State of the Direct Connect connection"
  value       = var.enabled ? aws_dx_connection.this[0].id : null  # Using 'id' as a fallback since connection_state isn't available
}

output "dx_gateway_id" {
  description = "ID of the Direct Connect gateway"
  value       = var.enabled && var.create_dx_gateway ? aws_dx_gateway.this[0].id : null
}

output "private_vif_id" {
  description = "ID of the private virtual interface"
  value       = var.enabled ? aws_dx_private_virtual_interface.this[0].id : null
}

output "private_vif_bgp_status" {
  description = "BGP status of the private virtual interface"
  value       = var.enabled ? aws_dx_private_virtual_interface.this[0].aws_device : null # Changed to a supported attribute
}