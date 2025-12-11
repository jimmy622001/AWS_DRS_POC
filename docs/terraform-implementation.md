Terraform Implementation Details for Banking DR Solution
 
This document provides the technical implementation details for deploying the AWS Disaster Recovery solutions using Terraform.

Direct Connect Implementation

For the hybrid connectivity approach (AWS DRS with Direct Connect + VPN):

```hcl
module "direct_connect" {
  source = "./modules/direct_connect"
  
  enabled         = true
  dx_location     = var.dx_location
  dxcon_bandwidth = var.dx_bandwidth
  on_prem_bgp_asn = var.on_prem_bgp_asn
  aws_side_asn    = var.aws_side_asn
  vpc_id          = module.networking.vpc_id
  vpc_cidr        = var.vpc_cidr
}

module "client_vpn" {
  source = "./modules/client_vpn"
  
  enabled            = true
  client_cidr_block  = var.client_vpn_cidr
  server_cert_arn    = var.server_cert_arn
  client_cert_arn    = var.client_cert_arn
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
}
```

VPN-Only Implementation

For the VPN-only approach (AWS DRS with VPN):

```hcl
module "vpn" {
  source = "./modules/vpn"
  
  enabled               = true
  customer_gateway_ip   = var.on_prem_public_ip
  on_prem_cidr_blocks   = var.on_prem_cidr_blocks
  vpc_id                = module.networking.vpc_id
  vpc_cidr              = var.vpc_cidr
  bgp_asn               = var.on_prem_bgp_asn
}

module "client_vpn" {
  source = "./modules/client_vpn"
  
  enabled            = true
  client_cidr_block  = var.client_vpn_cidr
  server_cert_arn    = var.server_cert_arn
  client_cert_arn    = var.client_cert_arn
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
}
```

DRS Service Configuration

This module configures the AWS Elastic Disaster Recovery service:

```hcl
module "drs" {
  source = "./modules/drs"
  
  enabled                   = true
  source_server_ips         = var.source_server_ips
  staging_subnet_id         = module.networking.private_subnet_ids[0]
  recovery_instance_types   = var.recovery_instance_types
  subnet_mapping            = var.subnet_mapping
  security_group_mapping    = var.security_group_mapping
}
```

Variable Definitions

Example variables for the Direct Connect implementation:

```hcl
# terraform.tfvars example for hybrid solution
dx_location     = "EqDC2"  # Direct Connect location code
dx_bandwidth    = "1Gbps"  # Direct Connect bandwidth
on_prem_bgp_asn = 65000    # On-premises BGP ASN
aws_side_asn    = 64512    # AWS side ASN
vpc_cidr        = "10.0.0.0/16"
client_vpn_cidr = "172.16.0.0/22"
```

Example variables for the VPN-only implementation:

```hcl
# terraform.tfvars example for VPN-only solution
on_prem_public_ip   = "203.0.113.1"  # On-premises public IP address
on_prem_cidr_blocks = ["192.168.0.0/16"]
on_prem_bgp_asn     = 65000
vpc_cidr            = "10.0.0.0/16"
client_vpn_cidr     = "172.16.0.0/22"
```

Deployment Instructions

1. Clone the repository
2. Navigate to the repository root directory
3. Create a terraform.tfvars file with the appropriate variables for your environment
4. Initialize Terraform:
   ```
   terraform init
   ```
5. Plan the deployment:
   ```
   terraform plan -out=tfplan
   ```
6. Apply the configuration:
   ```
   terraform apply tfplan
   ```

For the hybrid solution, you'll need to complete additional steps to establish the Direct Connect connection:

1. Download the LOA-CFA (Letter of Authorization and Connecting Facility Assignment)
2. Work with your colocation provider to complete the physical cross-connect
3. Verify BGP peering is established
4. Test connectivity between on-premises and AWS

Additional Technical Resources

- [AWS Direct Connect Documentation](https://docs.aws.amazon.com/directconnect/)
- [AWS Client VPN Documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/)
- [AWS Elastic Disaster Recovery Documentation](https://docs.aws.amazon.com/drs/)