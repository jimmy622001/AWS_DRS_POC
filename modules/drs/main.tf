resource "aws_drs_source_network" "main" {
  source_network_settings {
    vpc_id             = var.vpc_id
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-drs-source-network"
    }
  )
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

resource "aws_drs_launch_configuration" "app_servers" {
  source_server_id    = "placeholder-for-template"
  launch_template_id  = aws_launch_template.app_servers.id
}

resource "aws_drs_recovery_instance" "app_servers" {
  count                = var.dr_activated ? var.app_server_count : 0
  source_server_id     = var.app_server_source_ids[count.index]
  recovery_instance_type = var.app_server_instance_type

  # Use the launch configuration with security settings
  depends_on = [aws_drs_launch_configuration.app_servers]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-app-server-${count.index}"
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

resource "aws_drs_launch_configuration" "db_servers" {
  source_server_id    = "placeholder-for-template"
  launch_template_id  = aws_launch_template.db_servers.id
}

resource "aws_drs_recovery_instance" "db_servers" {
  count                = var.dr_activated ? var.db_server_count : 0
  source_server_id     = var.db_server_source_ids[count.index]
  recovery_instance_type = var.db_server_instance_type

  # Use the launch configuration with security settings
  depends_on = [aws_drs_launch_configuration.db_servers]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-db-server-${count.index}"
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

resource "aws_drs_launch_configuration" "file_servers" {
  source_server_id    = "placeholder-for-template"
  launch_template_id  = aws_launch_template.file_servers.id
}

resource "aws_drs_recovery_instance" "file_servers" {
  count                = var.dr_activated ? var.file_server_count : 0
  source_server_id     = var.file_server_source_ids[count.index]
  recovery_instance_type = var.file_server_instance_type

  # Use the launch configuration with security settings
  depends_on = [aws_drs_launch_configuration.file_servers]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-file-server-${count.index}"
      Environment = "DR"
    }
  )
}

# DRS Job configuration - These would be defined in a real environment
# but are represented here for cost estimation purposes
resource "aws_drs_job" "replication" {
  count           = var.dr_activated ? 0 : 1
  source_server_id = "placeholder-for-cost-estimation"
  type            = "RECOVERY"

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-replication-job"
    }
  )
}

# Cost calculation helper resources - these don't create real resources
# but help Infracost calculate the ongoing costs of the DRS service
resource "aws_drs_replication" "servers" {
  count         = var.total_server_count
  source_size_gb = var.avg_server_size_gb

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-replication-${count.index}"
    }
  )
}