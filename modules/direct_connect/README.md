Direct Connect Module

This module provisions AWS Direct Connect resources for the Banking DR solution, establishing a dedicated private connection between an on-premises data center and AWS.

Purpose

Direct Connect provides a dedicated network connection that bypasses the public internet to deliver more consistent network performance, lower latency, and higher bandwidth compared to internet-based connections like VPN. This is critical for banking DR solutions where reliable, high-performance replication is essential.

Resources Created

- AWS Direct Connect Connection
- Direct Connect Gateway (optional)
- Private Virtual Interface
- Gateway Association with VPC

Usage

```hcl
module "direct_connect" {
  source = "./modules/direct_connect"
  
  enabled          = true
  dx_location      = "EqDC2"  # Direct Connect location code
  dxcon_bandwidth  = "1Gbps"
  on_prem_bgp_asn  = 65000    # Your on-premises BGP ASN
  vpc_id           = module.networking.vpc_id
  vpc_cidr         = module.networking.vpc_cidr
  
  tags = {
    Environment = "dr"
    Project     = "banking-dr"
  }
}
```

Input Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enabled | Whether to create Direct Connect resources | bool | true |
| name_prefix | Prefix for resource names | string | "banking-dr" |
| dxcon_bandwidth | Bandwidth of the Direct Connect connection | string | "1Gbps" |
| dx_location | AWS Direct Connect location code | string | - |
| on_prem_bgp_asn | BGP ASN of on-premises equipment | number | 65000 |
| aws_side_asn | BGP ASN for AWS side | number | 64512 |
| vpc_id | VPC ID to associate with the Direct Connect Gateway | string | - |
| vpc_cidr | CIDR block of the VPC | string | "10.0.0.0/16" |

Output Values

| Name | Description |
|------|-------------|
| dx_connection_id | ID of the Direct Connect connection |
| dx_connection_state | State of the Direct Connect connection |
| dx_gateway_id | ID of the Direct Connect gateway |
| private_vif_id | ID of the private virtual interface |
| private_vif_bgp_status | BGP status of the private virtual interface |

Benefits for Banking DR

1. Consistent Replication Performance: Ensures predictable data transfer rates for lower RPO
2. Lower Latency: Reduces time for replication updates to reach AWS
3. Higher Security: Traffic doesn't traverse the public internet
4. SLA-backed Reliability: 99.99% availability SLA from AWS
5. Dedicated Bandwidth: No competition with other internet traffic