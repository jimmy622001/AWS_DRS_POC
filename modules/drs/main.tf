# Using a local value to represent DRS network configuration for the AWS DRS service
# The aws_drs_source_network resource is not available in the current provider version
locals {
  drs_network_config = {
    vpc_id             = var.vpc_id
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

# Launch template with security settings for app servers
resource "aws_launch_template" "app_servers" {
  name                   = "${var.prefix}-app-servers-lt"
  description            = "Launch template for DRS app server recovery instances"
  image_id               = var.app_server_ami_id
  instance_type          = var.app_server_instance_type
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.app_server_volume_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_id
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-app-servers-lt"
    }
  )
}

# The aws_drs_launch_configuration resource is not available in the current provider version
# Using the launch template directly for recovery instances

# Using EC2 instances as placeholders for DRS recovery instances
resource "aws_instance" "app_servers" {
  count         = var.dr_activated ? var.app_server_count : 0
  ami           = var.app_server_ami_id != "" ? var.app_server_ami_id : "ami-12345678" # Placeholder
  instance_type = var.app_server_instance_type
  subnet_id     = var.subnet_ids[0]

  # Reference launch template
  launch_template {
    id = aws_launch_template.app_servers.id
  }

  # Ensure root block device is encrypted
  root_block_device {
    encrypted  = true
    kms_key_id = var.kms_key_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.prefix}-app-server-${count.index}"
      Environment = "DR"
    }
  )
}

# Launch template with security settings for DB servers
resource "aws_launch_template" "db_servers" {
  name                   = "${var.prefix}-db-servers-lt"
  description            = "Launch template for DRS database server recovery instances"
  image_id               = var.db_server_ami_id
  instance_type          = var.db_server_instance_type
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.db_server_volume_size
      volume_type           = "io2"
      iops                  = 5000
      encrypted             = true
      kms_key_id            = var.kms_key_id
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-db-servers-lt"
    }
  )
}

# The aws_drs_launch_configuration resource is not available in the current provider version
# Using the launch template directly for recovery instances

# Using EC2 instances as placeholders for DRS recovery instances
resource "aws_instance" "db_servers" {
  count         = var.dr_activated ? var.db_server_count : 0
  ami           = var.db_server_ami_id != "" ? var.db_server_ami_id : "ami-12345678" # Placeholder
  instance_type = var.db_server_instance_type
  subnet_id     = var.subnet_ids[0]

  # Reference launch template
  launch_template {
    id = aws_launch_template.db_servers.id
  }

  # Ensure root block device is encrypted
  root_block_device {
    encrypted  = true
    kms_key_id = var.kms_key_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.prefix}-db-server-${count.index}"
      Environment = "DR"
    }
  )
}

# Launch template with security settings for file servers
resource "aws_launch_template" "file_servers" {
  name                   = "${var.prefix}-file-servers-lt"
  description            = "Launch template for DRS file server recovery instances"
  image_id               = var.file_server_ami_id
  instance_type          = var.file_server_instance_type
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    name = var.instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.file_server_volume_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_id
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-file-servers-lt"
    }
  )
}

# The aws_drs_launch_configuration resource is not available in the current provider version
# Using the launch template directly for recovery instances

# Using EC2 instances as placeholders for DRS recovery instances
resource "aws_instance" "file_servers" {
  count         = var.dr_activated ? var.file_server_count : 0
  ami           = var.file_server_ami_id != "" ? var.file_server_ami_id : "ami-12345678" # Placeholder
  instance_type = var.file_server_instance_type
  subnet_id     = var.subnet_ids[0]

  # Reference launch template
  launch_template {
    id = aws_launch_template.file_servers.id
  }

  # Ensure root block device is encrypted
  root_block_device {
    encrypted  = true
    kms_key_id = var.kms_key_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.prefix}-file-server-${count.index}"
      Environment = "DR"
    }
  )
}

# Using locals to simulate DRS costs rather than unsupported resources
locals {
  # Placeholder for cost estimation
  drs_costs = {
    server_count = var.total_server_count
    total_gb     = var.total_server_count * var.avg_server_size_gb
    active       = var.dr_activated
  }
}