resource "aws_drs_source_network" "main" {
  source_network_settings {
    vpc_id             = var.vpc_id
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_drs_recovery_instance" "app_servers" {
  count                = var.dr_activated ? var.app_server_count : 0
  source_server_id     = var.app_server_source_ids[count.index]
  recovery_instance_type = var.app_server_instance_type
  tags = {
    Name = "dr-app-server-${count.index}"
    Environment = "DR"
  }
}

resource "aws_drs_recovery_instance" "db_servers" {
  count                = var.dr_activated ? var.db_server_count : 0
  source_server_id     = var.db_server_source_ids[count.index]
  recovery_instance_type = var.db_server_instance_type
  tags = {
    Name = "dr-db-server-${count.index}"
    Environment = "DR"
  }
}

resource "aws_drs_recovery_instance" "file_servers" {
  count                = var.dr_activated ? var.file_server_count : 0
  source_server_id     = var.file_server_source_ids[count.index]
  recovery_instance_type = var.file_server_instance_type
  tags = {
    Name = "dr-file-server-${count.index}"
    Environment = "DR"
  }
}

# DRS Job configuration - These would be defined in a real environment
# but are represented here for cost estimation purposes
resource "aws_drs_job" "replication" {
  count           = var.dr_activated ? 0 : 1
  source_server_id = "placeholder-for-cost-estimation"
  type            = "RECOVERY"
}

# Cost calculation helper resources - these don't create real resources
# but help Infracost calculate the ongoing costs of the DRS service
resource "aws_drs_replication" "servers" {
  count         = var.total_server_count
  source_size_gb = var.avg_server_size_gb
}