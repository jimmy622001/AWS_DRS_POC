# Terraform Implementation

This document provides detailed information about the Terraform implementation of the AWS DRS solution.

## Overview

The solution uses Terraform to implement Infrastructure as Code (IaC) for the AWS DRS environment. This approach provides consistency, version control, and automated deployment of the disaster recovery infrastructure.

## Repository Structure

The Terraform code is organized into modules to promote reusability and maintainability:

```
AWS_DRS_POC/
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables definition
├── outputs.tf            # Output values
├── terraform.tfvars      # Variable values (example)
├── versions.tf           # Provider versions
└── modules/              # Terraform modules
    ├── compute/          # EC2, Auto Scaling Groups, Load Balancers
    ├── database/         # RDS, DynamoDB
    ├── data_protection/  # Data Loss Prevention implementation
    ├── direct_connect/   # Direct Connect configuration
    ├── drs/              # AWS Elastic DR Service
    ├── iam/              # IAM roles and policies
    ├── kms/              # KMS keys for encryption
    ├── logging/          # Logging configuration
    ├── monitoring/       # Monitoring and alerting
    ├── networking/       # VPC, subnets, VPN, Transit Gateway
    ├── on_demand_security/ # Security services activated during DR
    ├── recovery_orchestration/ # Automated recovery workflows
    ├── secrets_manager/  # Secrets management
    ├── security/         # Security configurations
    ├── security_compliance/ # Compliance monitoring
    └── storage/          # S3, EFS, EBS configurations
```

## Module Structure

Each module follows a consistent structure:

```
module_name/
├── main.tf           # Main module configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── README.md         # Module documentation
```

## Core Modules

### Networking Module

The networking module creates the VPC, subnets, route tables, and connectivity components (VPN or Direct Connect):

```hcl
module "networking" {
  source = "./modules/networking"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  create_vpn           = var.connectivity_option == "vpn" ? true : false
  create_direct_connect = var.connectivity_option == "direct_connect" ? true : false
  
  # VPN configuration if needed
  customer_gateway_ip  = var.connectivity_option == "vpn" ? var.on_prem_router_ip : null
  
  # Tags
  tags = var.tags
}
```

### DRS Module

The DRS module configures the AWS Elastic Disaster Recovery service:

```hcl
module "drs" {
  source = "./modules/drs"

  subnet_ids           = module.networking.private_mgmt_subnet_ids
  security_group_ids   = [module.security.drs_security_group_id]
  replication_server_instance_type = var.replication_server_instance_type
  ebs_encryption_key_id = module.kms.ebs_key_id
  
  # Tags
  tags = var.tags
}
```

### Compute Module

The compute module provisions EC2 instances, Auto Scaling Groups, and Load Balancers for the recovered environment:

```hcl
module "compute" {
  source = "./modules/compute"

  vpc_id              = module.networking.vpc_id
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  app_security_group_ids = [module.security.app_security_group_id]
  
  dr_activated        = var.dr_activated
  create_load_balancer = var.create_load_balancer
  instance_type       = var.app_instance_type
  key_name            = var.key_name
  
  # Tags
  tags = var.tags
}
```

### Security Module

The security module sets up security groups, NACLs, and other security controls:

```hcl
module "security" {
  source = "./modules/security"

  vpc_id              = module.networking.vpc_id
  vpc_cidr            = var.vpc_cidr
  on_prem_cidr        = var.on_prem_cidr
  
  # Tags
  tags = var.tags
}
```

### On-Demand Security Module

The on-demand security module enables security services that are activated only during DR events:

```hcl
module "on_demand_security" {
  source = "./modules/on_demand_security"

  dr_activated        = var.dr_activated
  create_shield_protection = var.dr_activated && module.compute.load_balancer_arn != null
  shield_resource_arn = module.compute.load_balancer_arn != null ? module.compute.load_balancer_arn : ""
  
  # Tags
  tags = var.tags
}
```

## Variable Definition

Key variables are defined in the root `variables.tf` file:

```hcl
variable "region" {
  description = "The AWS region to deploy resources to"
  type        = string
  default     = "eu-west-1"
}

variable "connectivity_option" {
  description = "The connectivity option to use (vpn or direct_connect)"
  type        = string
  default     = "vpn"
  
  validation {
    condition     = contains(["vpn", "direct_connect"], var.connectivity_option)
    error_message = "Valid values for connectivity_option are: vpn, direct_connect."
  }
}

variable "dr_activated" {
  description = "Whether the DR environment is activated (true) or in standby mode (false)"
  type        = bool
  default     = false
}

variable "on_prem_cidr" {
  description = "CIDR block for the on-premises network"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "DR"
    ManagedBy   = "Terraform"
  }
}
```

## Deployment Options

The solution supports both connectivity options through conditional logic:

```hcl
# VPN option
module "vpn" {
  source = "./modules/networking/vpn"
  count  = var.connectivity_option == "vpn" ? 1 : 0
  
  vpc_id              = module.networking.vpc_id
  customer_gateway_ip = var.on_prem_router_ip
  
  # Tags
  tags = var.tags
}

# Direct Connect option
module "direct_connect" {
  source = "./modules/direct_connect"
  count  = var.connectivity_option == "direct_connect" ? 1 : 0
  
  vpc_id              = module.networking.vpc_id
  direct_connect_gateway_id = var.direct_connect_gateway_id
  
  # Tags
  tags = var.tags
}
```

## DR Activation Control

The solution includes a `dr_activated` variable to control the provisioning of recovery resources:

```hcl
# Example of DR activation control
resource "aws_instance" "dr_instance" {
  count         = var.dr_activated ? 1 : 0
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  # Other configuration...
}
```

This approach allows for cost optimization by provisioning recovery resources only when needed.

## Security Implementation

Security is implemented at multiple levels:

### IAM Roles and Policies

```hcl
module "iam" {
  source = "./modules/iam"
  
  # Configuration...
}
```

### Encryption

```hcl
module "kms" {
  source = "./modules/kms"
  
  # Configuration...
}
```

### Network Security

```hcl
# Security groups for different tiers
resource "aws_security_group" "app_tier" {
  # Configuration...
}

resource "aws_security_group" "db_tier" {
  # Configuration...
}

# Network ACLs
resource "aws_network_acl" "private_app" {
  # Configuration...
}
```

## Recovery Orchestration

The solution includes automated recovery orchestration using AWS Step Functions:

```hcl
module "recovery_orchestration" {
  source = "./modules/recovery_orchestration"
  
  drs_source_server_ids = module.drs.source_server_ids
  lambda_function_arns  = module.lambda.function_arns
  
  # Tags
  tags = var.tags
}
```

## Deployment Instructions

### Prerequisites

Before deploying the solution, ensure you have:

1. AWS account with appropriate permissions
2. Terraform installed (version 1.0.0 or higher)
3. AWS CLI configured with appropriate credentials
4. Network connectivity established (VPN or Direct Connect)

### Deployment Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd AWS_DRS_POC
   ```

2. **Configure variables**:
   Create a `terraform.tfvars` file with your specific configuration:
   ```hcl
   region              = "eu-west-1"
   connectivity_option = "vpn"  # or "direct_connect"
   on_prem_cidr        = "192.168.0.0/16"
   on_prem_router_ip   = "203.0.113.10"
   dr_activated        = false
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan -var-file=terraform.tfvars -out=tfplan
   ```

5. **Apply the deployment**:
   ```bash
   terraform apply tfplan
   ```

### Modifying the Deployment

To switch between connectivity options or activate DR:

1. **Update variables**:
   ```hcl
   connectivity_option = "direct_connect"  # Change from "vpn"
   dr_activated        = true              # Activate DR resources
   ```

2. **Plan and apply the changes**:
   ```bash
   terraform plan -var-file=terraform.tfvars -out=tfplan
   terraform apply tfplan
   ```

## State Management

For production deployments, it's recommended to use remote state storage:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "aws-drs-poc/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Testing and Validation

After deployment, validate the infrastructure using:

```bash
# Validate networking
terraform output networking_validation

# Validate DRS configuration
terraform output drs_validation

# Validate security controls
terraform output security_validation
```

## Next Steps

For detailed deployment instructions, refer to the [Deployment Guide](21-deployment-guide.md).

For testing procedures, refer to the [Testing Procedures](22-testing-procedures.md).