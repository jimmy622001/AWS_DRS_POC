resource "aws_vpc" "dr_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dr-vpc"
  }
}

resource "aws_subnet" "dr_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.dr_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = {
    Name = "dr-private-subnet-${count.index}"
  }
}

resource "aws_subnet" "dr_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.dr_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = {
    Name = "dr-public-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "dr_igw" {
  vpc_id = aws_vpc.dr_vpc.id

  tags = {
    Name = "dr-igw"
  }
}

resource "aws_route_table" "dr_public_rt" {
  vpc_id = aws_vpc.dr_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dr_igw.id
  }

  tags = {
    Name = "dr-public-route-table"
  }
}

resource "aws_route_table_association" "dr_public_rt_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.dr_public_subnets[count.index].id
  route_table_id = aws_route_table.dr_public_rt.id
}

resource "aws_eip" "dr_nat_eip" {
  count      = var.create_nat_gateway ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.dr_igw]

  tags = {
    Name = "dr-nat-eip"
  }
}

resource "aws_nat_gateway" "dr_nat_gateway" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.dr_nat_eip[0].id
  subnet_id     = aws_subnet.dr_public_subnets[0].id
  depends_on    = [aws_internet_gateway.dr_igw]

  tags = {
    Name = "dr-nat-gateway"
  }
}

resource "aws_route_table" "dr_private_rt" {
  vpc_id = aws_vpc.dr_vpc.id

  dynamic "route" {
    for_each = var.create_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.dr_nat_gateway[0].id
    }
  }

  tags = {
    Name = "dr-private-route-table"
  }
}

resource "aws_route_table_association" "dr_private_rt_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.dr_private_subnets[count.index].id
  route_table_id = aws_route_table.dr_private_rt.id
}

resource "aws_security_group" "dr_sg" {
  name        = "dr-security-group"
  description = "Security group for DR resources"
  vpc_id      = aws_vpc.dr_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all internal traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_external_cidrs
    description = "Allow HTTPS from specified external CIDRs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "dr-security-group"
  }
}

resource "aws_vpn_gateway" "dr_vpn_gateway" {
  vpc_id = aws_vpc.dr_vpc.id

  tags = {
    Name = "dr-vpn-gateway"
  }
}

resource "aws_customer_gateway" "dr_customer_gateway" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "dr-customer-gateway"
  }
}

resource "aws_vpn_connection" "dr_vpn_connection" {
  vpn_gateway_id      = aws_vpn_gateway.dr_vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.dr_customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "dr-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "dr_vpn_route" {
  count                  = length(var.vpn_route_cidrs)
  destination_cidr_block = var.vpn_route_cidrs[count.index]
  vpn_connection_id      = aws_vpn_connection.dr_vpn_connection.id
}

resource "aws_ec2_client_vpn_endpoint" "dr_client_vpn" {
  count                  = var.create_client_vpn ? 1 : 0
  description            = "DR Client VPN Endpoint"
  server_certificate_arn = var.client_vpn_server_cert_arn
  client_cidr_block      = var.client_vpn_cidr

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_vpn_client_cert_arn
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    Name = "dr-client-vpn"
  }
}

resource "aws_ec2_client_vpn_network_association" "dr_client_vpn_assoc" {
  count                  = var.create_client_vpn ? length(var.private_subnet_cidrs) : 0
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.dr_client_vpn[0].id
  subnet_id              = aws_subnet.dr_private_subnets[count.index].id
}

resource "aws_ec2_client_vpn_authorization_rule" "dr_client_vpn_auth_rule" {
  count                  = var.create_client_vpn ? 1 : 0
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.dr_client_vpn[0].id
  target_network_cidr    = aws_vpc.dr_vpc.cidr_block
  authorize_all_groups   = true
}