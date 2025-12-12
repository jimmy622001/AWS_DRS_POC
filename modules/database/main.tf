resource "aws_db_subnet_group" "dr_db_subnet_group" {
  name       = "dr-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "DR DB Subnet Group"
  }
}

resource "aws_db_parameter_group" "dr_db_parameter_group" {
  name   = "dr-db-parameter-group"
  family = var.db_family

  tags = {
    Name = "DR DB Parameter Group"
  }
}

resource "aws_db_instance" "dr_sql_server" {
  count                               = var.dr_activated && var.create_sql_server ? 1 : 0
  allocated_storage                   = var.sql_server_storage_gb
  storage_type                        = "gp3"
  engine                              = "sqlserver-ee"
  engine_version                      = var.sql_server_version
  instance_class                      = var.sql_server_instance_class
  db_name                             = null # Not supported for SQL Server
  username                            = var.db_username
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.dr_db_subnet_group.name
  parameter_group_name                = aws_db_parameter_group.dr_db_parameter_group.name
  skip_final_snapshot                 = true
  license_model                       = "license-included"
  multi_az                            = var.multi_az
  backup_retention_period             = var.backup_retention_days
  vpc_security_group_ids              = var.security_group_ids
  iam_database_authentication_enabled = true

  tags = {
    Name = "dr-sql-server"
  }
}

resource "aws_db_instance" "dr_mysql" {
  count                               = var.dr_activated && var.create_mysql ? 1 : 0
  allocated_storage                   = var.mysql_storage_gb
  storage_type                        = "gp3"
  engine                              = "mysql"
  engine_version                      = var.mysql_version
  instance_class                      = var.mysql_instance_class
  db_name                             = "drdb"
  username                            = var.db_username
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.dr_db_subnet_group.name
  parameter_group_name                = aws_db_parameter_group.dr_db_parameter_group.name
  skip_final_snapshot                 = true
  multi_az                            = var.multi_az
  backup_retention_period             = var.backup_retention_days
  vpc_security_group_ids              = var.security_group_ids
  iam_database_authentication_enabled = true

  tags = {
    Name = "dr-mysql"
  }
}

resource "aws_dms_replication_instance" "dr_dms" {
  count                       = var.create_dms ? 1 : 0
  allocated_storage           = var.dms_storage_gb
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  engine_version              = var.dms_engine_version
  publicly_accessible         = false
  replication_instance_class  = var.dms_instance_class
  replication_instance_id     = "dr-dms-replication-instance"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dr_dms_subnet_group[0].id
  vpc_security_group_ids      = var.security_group_ids

  tags = {
    Name = "DR DMS Replication Instance"
  }
}

resource "aws_dms_replication_subnet_group" "dr_dms_subnet_group" {
  count                                = var.create_dms ? 1 : 0
  replication_subnet_group_id          = "dr-dms-subnet-group"
  replication_subnet_group_description = "DR DMS subnet group"
  subnet_ids                           = var.subnet_ids

  tags = {
    Name = "DR DMS Subnet Group"
  }
}