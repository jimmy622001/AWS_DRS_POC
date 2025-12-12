# Main AWS provider
provider "aws" {
  region = var.aws_region

  # Allow for AWS API retries
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Centralized notifications
module "notifications" {
  source = "./modules/notifications"

  create_topic          = var.create_sns_topic
  topic_name            = var.sns_topic_name != "" ? var.sns_topic_name : "${var.project}-${var.environment}-dr-notifications"
  admin_email           = var.admin_email
  create_critical_topic = true
  critical_topic_name   = "${var.project}-${var.environment}-critical-dr-notifications"
  critical_admin_email  = var.critical_admin_email
  prefix                = "${var.project}-${var.environment}"
  environment           = var.environment
  kms_key_id            = module.kms.key_id

  tags = {
    Environment = var.environment
    Project     = var.project
    Component   = "Monitoring"
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr                   = var.vpc_cidr
  private_subnet_cidrs       = var.private_subnet_cidrs
  public_subnet_cidrs        = var.public_subnet_cidrs
  availability_zones         = var.availability_zones
  create_nat_gateway         = var.create_nat_gateway
  allowed_external_cidrs     = var.allowed_external_cidrs
  customer_gateway_ip        = var.customer_gateway_ip
  customer_gateway_bgp_asn   = var.customer_gateway_bgp_asn
  vpn_route_cidrs            = var.vpn_route_cidrs
  create_client_vpn          = var.create_client_vpn
  client_vpn_cidr            = var.client_vpn_cidr
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

  vpc_id               = module.networking.vpc_id
  subnet_ids           = module.networking.private_subnet_ids
  security_group_ids   = [module.networking.security_group_id]
  dr_activated         = var.dr_activated
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  ebs_volume_size      = var.ebs_volume_size
  instance_count       = var.instance_count
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  create_load_balancer = var.create_load_balancer
  certificate_arn      = var.certificate_arn
}

# KMS Module for encryption
module "kms" {
  source = "./modules/kms"

  prefix      = "${var.project}-${var.environment}"
  description = "KMS key for ${var.project} ${var.environment} environment"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Secrets Manager Module
module "secrets_manager" {
  source = "./modules/secrets_manager"

  secrets = {
    "db_password"  = var.db_password
    "ad_password"  = var.ad_password
    "vpn_password" = var.vpn_password
  }

  kms_key_id = module.kms.key_id
  prefix     = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Security Module
module "security" {
  source = "./modules/security"

  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.private_subnet_ids
  allowed_ips = var.allowed_ips # This should be specified with your IP
  prefix      = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  prefix      = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  kms_key_arn = module.kms.key_arn

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Database Module
module "database" {
  source = "./modules/database"

  subnet_ids                = module.networking.private_subnet_ids
  security_group_ids        = [module.security.security_group_id]
  dr_activated              = var.dr_activated
  create_sql_server         = var.create_sql_server
  create_mysql              = var.create_mysql
  create_dms                = var.create_dms
  sql_server_storage_gb     = var.sql_server_storage_gb
  mysql_storage_gb          = var.mysql_storage_gb
  dms_storage_gb            = var.dms_storage_gb
  sql_server_version        = var.sql_server_version
  mysql_version             = var.mysql_version
  dms_engine_version        = var.dms_engine_version
  sql_server_instance_class = var.sql_server_instance_class
  mysql_instance_class      = var.mysql_instance_class
  dms_instance_class        = var.dms_instance_class
  db_username               = var.db_username
  db_password               = module.secrets_manager.secret_arns["db_password"]
  db_family                 = var.db_family
  multi_az                  = var.multi_az
  backup_retention_days     = var.backup_retention_days
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  subnet_id                    = module.networking.private_subnet_ids[0]
  vpc_endpoint_id              = var.vpc_endpoint_id
  fsx_storage_capacity         = var.fsx_storage_capacity
  fsx_throughput_capacity      = var.fsx_throughput_capacity
  ad_dns_ips                   = var.ad_dns_ips
  ad_domain_name               = var.ad_domain_name
  ad_password                  = module.secrets_manager.secret_arns["ad_password"]
  ad_username                  = var.ad_username
  ad_ou_path                   = var.ad_ou_path
  s3_bucket_name               = var.s3_bucket_name
  storage_gateway_role_arn     = var.storage_gateway_role_arn
  datasync_role_arn            = var.datasync_role_arn
  datasync_source_location_arn = var.datasync_source_location_arn
}

# DRS Module
module "drs" {
  source = "./modules/drs"

  vpc_id                    = module.networking.vpc_id
  subnet_ids                = module.networking.private_subnet_ids
  security_group_ids        = [module.security.security_group_id]
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
  kms_key_id                = module.kms.key_id
  instance_profile_name     = module.iam.drs_instance_profile_name
  prefix                    = "${var.project}-${var.environment}"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  aws_region                        = var.aws_region
  critical_source_server_ids        = var.critical_source_server_ids
  standard_source_server_ids        = var.standard_source_server_ids
  replication_lag_threshold_seconds = var.replication_lag_threshold_seconds
  rto_threshold_minutes             = var.rto_threshold_minutes
  sns_topic_arn                     = module.notifications.topic_arn
  critical_sns_topic_arn            = module.notifications.critical_topic_arn
}


# DR Testing Module
module "dr_testing" {
  count  = var.enable_automated_testing ? 1 : 0
  source = "./modules/dr_testing"

  prefix                   = "${var.project}-${var.environment}"
  step_function_arn        = module.recovery_orchestration.step_function_arn
  source_server_ids        = concat(var.app_server_source_ids, var.db_server_source_ids, var.file_server_source_ids)
  sns_topic_arn            = module.notifications.topic_arn
  rto_threshold_seconds    = var.rto_threshold_minutes * 60
  aws_region               = var.aws_region
  test_schedule_expression = var.dr_test_schedule_expression

  tags = {
    Environment = var.environment
    Project     = var.project
    Component   = "DR-Testing"
  }
}

# Security Compliance Module
module "security_compliance" {
  source = "./modules/security_compliance"

  prefix     = "${var.project}-${var.environment}"
  account_id = data.aws_caller_identity.current.account_id
  region     = var.aws_region
  kms_key_id = module.kms.key_id

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Logging Module
module "logging" {
  source = "./modules/logging"

  prefix      = "${var.project}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
  kms_key_id  = module.kms.key_id
  vpc_id      = module.networking.vpc_id
  admin_email = var.admin_email

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# On-Demand Security Module
module "on_demand_security" {
  source = "./modules/on_demand_security"

  environment       = var.environment
  load_balancer_arn = module.compute.load_balancer_arn
  waf_web_acl_name  = "${var.project}-${var.environment}-dr-waf"

  # Shield Advanced Configuration
  create_shield_protection = var.create_shield_protection && module.compute.load_balancer_arn != null
  shield_resource_arn      = module.compute.load_balancer_arn != null ? module.compute.load_balancer_arn : ""

  tags = {
    Environment = var.environment
    Project     = var.project
    Component   = "DR-Security"
  }
}

# Recovery Orchestration Module
module "recovery_orchestration" {
  source = "./modules/recovery_orchestration"

  prefix = "${var.project}-${var.environment}"
  tags = {
    Environment = var.environment
    Project     = var.project
  }
  sns_topic_arn = var.sns_topic_arn
  source_region = var.source_region
  account_id    = data.aws_caller_identity.current.account_id
  source_server_ids = concat(
    var.app_server_source_ids,
    var.db_server_source_ids,
    var.file_server_source_ids
  )
  enable_security_lambda_arn  = module.on_demand_security.enable_security_lambda_arn
  disable_security_lambda_arn = module.on_demand_security.disable_security_lambda_arn
}

# Data Protection Module
module "data_protection" {
  source = "./modules/data_protection"

  prefix = "${var.project}-${var.environment}"
  tags = {
    Environment = var.environment
    Project     = var.project
  }
  sns_topic_arn      = var.sns_topic_arn
  account_id         = data.aws_caller_identity.current.account_id
  kms_key_id         = module.kms.key_id
  config_recorder_id = module.security_compliance.config_recorder_id
}