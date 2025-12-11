provider "aws" {
  region = var.aws_region
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr                = var.vpc_cidr
  private_subnet_cidrs    = var.private_subnet_cidrs
  public_subnet_cidrs     = var.public_subnet_cidrs
  availability_zones      = var.availability_zones
  create_nat_gateway      = var.create_nat_gateway
  allowed_external_cidrs  = var.allowed_external_cidrs
  customer_gateway_ip     = var.customer_gateway_ip
  customer_gateway_bgp_asn = var.customer_gateway_bgp_asn
  vpn_route_cidrs         = var.vpn_route_cidrs
  create_client_vpn       = var.create_client_vpn
  client_vpn_cidr         = var.client_vpn_cidr
  client_vpn_server_cert_arn = var.client_vpn_server_cert_arn
  client_vpn_client_cert_arn = var.client_vpn_client_cert_arn
}

# Direct Connect Module
module "direct_connect" {
  source = "./modules/direct_connect"

  enabled         = var.create_direct_connect
  dx_location     = var.dx_location
  dxcon_bandwidth = var.dx_bandwidth
  on_prem_bgp_asn = var.on_prem_bgp_asn
  aws_side_asn    = var.aws_side_asn
  vpc_id          = module.networking.vpc_id
  vpc_cidr        = var.vpc_cidr

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [module.networking]
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.networking.security_group_id]
  dr_activated       = var.dr_activated
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  ebs_volume_size    = var.ebs_volume_size
  instance_count     = var.instance_count
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  create_load_balancer = var.create_load_balancer
}

# Database Module
module "database" {
  source = "./modules/database"

  subnet_ids             = module.networking.private_subnet_ids
  security_group_ids     = [module.networking.security_group_id]
  dr_activated           = var.dr_activated
  create_sql_server      = var.create_sql_server
  create_mysql           = var.create_mysql
  create_dms             = var.create_dms
  sql_server_storage_gb  = var.sql_server_storage_gb
  mysql_storage_gb       = var.mysql_storage_gb
  dms_storage_gb         = var.dms_storage_gb
  sql_server_version     = var.sql_server_version
  mysql_version          = var.mysql_version
  dms_engine_version     = var.dms_engine_version
  sql_server_instance_class = var.sql_server_instance_class
  mysql_instance_class   = var.mysql_instance_class
  dms_instance_class     = var.dms_instance_class
  db_username            = var.db_username
  db_password            = var.db_password
  db_family              = var.db_family
  multi_az               = var.multi_az
  backup_retention_days  = var.backup_retention_days
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  subnet_id                  = module.networking.private_subnet_ids[0]
  vpc_endpoint_id            = var.vpc_endpoint_id
  fsx_storage_capacity       = var.fsx_storage_capacity
  fsx_throughput_capacity    = var.fsx_throughput_capacity
  ad_dns_ips                 = var.ad_dns_ips
  ad_domain_name             = var.ad_domain_name
  ad_password                = var.ad_password
  ad_username                = var.ad_username
  ad_ou_path                 = var.ad_ou_path
  s3_bucket_name             = var.s3_bucket_name
  storage_gateway_role_arn   = var.storage_gateway_role_arn
  datasync_role_arn          = var.datasync_role_arn
  datasync_source_location_arn = var.datasync_source_location_arn
}

# DRS Module
module "drs" {
  source = "./modules/drs"

  vpc_id                    = module.networking.vpc_id
  subnet_ids                = module.networking.private_subnet_ids
  security_group_ids        = [module.networking.security_group_id]
  dr_activated              = var.dr_activated
  app_server_count          = var.app_server_count
  db_server_count           = var.db_server_count
  file_server_count         = var.file_server_count
  app_server_instance_type  = var.app_server_instance_type
  db_server_instance_type   = var.db_server_instance_type
  file_server_instance_type = var.file_server_instance_type
  total_server_count        = var.total_server_count
  avg_server_size_gb        = var.avg_server_size_gb
  app_server_source_ids     = var.app_server_source_ids
  db_server_source_ids      = var.db_server_source_ids
  file_server_source_ids    = var.file_server_source_ids
  app_server_source_ids     = var.app_server_source_ids
  db_server_source_ids      = var.db_server_source_ids
  file_server_source_ids    = var.file_server_source_ids
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  aws_region                   = var.aws_region
  source_server_ids            = var.monitoring_source_server_ids
  replication_lag_threshold_seconds = var.replication_lag_threshold_seconds
  rto_threshold_minutes        = var.rto_threshold_minutes
  sns_topic_arn                = var.sns_topic_arn
}