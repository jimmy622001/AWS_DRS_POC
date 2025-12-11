# Direct Connect module for Banking DR solution

resource "aws_dx_connection" "this" {
  count         = var.enabled ? 1 : 0
  name          = "${var.name_prefix}-dx-conn"
  bandwidth     = var.dxcon_bandwidth
  location      = var.dx_location
  provider_name = var.provider_name
  tags          = var.tags
}

resource "aws_dx_gateway" "this" {
  count           = var.enabled && var.create_dx_gateway ? 1 : 0
  name            = "${var.name_prefix}-dxgw"
  amazon_side_asn = var.aws_side_asn
}

resource "aws_dx_private_virtual_interface" "this" {
  count            = var.enabled ? 1 : 0
  connection_id    = aws_dx_connection.this[0].id
  name             = "${var.name_prefix}-private-vif"
  vlan             = var.vlan_id
  amazon_address   = var.amazon_address
  customer_address = var.customer_address
  address_family   = "ipv4"
  bgp_asn          = var.on_prem_bgp_asn
  bgp_auth_key     = var.bgp_auth_key
  dx_gateway_id    = var.create_dx_gateway ? aws_dx_gateway.this[0].id : var.direct_connect_gateway_id

  tags = var.tags
}

resource "aws_dx_gateway_association" "this" {
  count                 = var.enabled && var.create_dx_gateway ? 1 : 0
  dx_gateway_id         = aws_dx_gateway.this[0].id
  associated_gateway_id = var.vpc_id

  allowed_prefixes = [
    var.vpc_cidr
  ]
}