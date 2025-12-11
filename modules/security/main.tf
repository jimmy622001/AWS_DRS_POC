resource "aws_security_group" "drs_sg" {
  name        = "${var.prefix}-drs-sg"
  description = "Security group for DRS resources"
  vpc_id      = var.vpc_id

  # Instead of allowing all internal traffic, we specify only required ports
  ingress {
    description = "Management access from allowed IPs only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  ingress {
    description = "HTTPS access from allowed IPs only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # Add other specific ingress rules as needed

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-drs-sg"
    }
  )
}

# Network ACLs for additional protection
resource "aws_network_acl" "drs_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Example NACL rules
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Restrict SSH to allowed IPs
  dynamic "ingress" {
    for_each = var.allowed_ips
    content {
      protocol   = "tcp"
      rule_no    = 120 + index(var.allowed_ips, ingress.value)
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 22
      to_port    = 22
    }
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-drs-nacl"
    }
  )
}