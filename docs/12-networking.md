# Networking

This document provides detailed information about the networking architecture and configuration for the AWS DRS solution.

## Network Architecture Overview

The networking architecture for this disaster recovery solution is designed to provide secure, reliable connectivity between on-premises environments and the AWS recovery region while maintaining isolation of critical resources.

![Network Architecture Diagram](../assets/DR%20AWS.png)

## VPC Design

### VPC Configuration

- **CIDR Block**: 10.0.0.0/16
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled
- **Tenancy**: Default

### Subnet Layout

The VPC is divided into multiple subnets across three Availability Zones for high availability:

| Subnet | CIDR Block | Availability Zone | Purpose |
|--------|------------|-------------------|---------|
| Private-App-1 | 10.0.1.0/24 | eu-west-1a | Application tier |
| Private-DB-1 | 10.0.2.0/24 | eu-west-1a | Database tier |
| Private-Mgmt-1 | 10.0.3.0/24 | eu-west-1a | Management/Replication |
| Private-App-2 | 10.0.4.0/24 | eu-west-1b | Application tier |
| Private-DB-2 | 10.0.5.0/24 | eu-west-1b | Database tier |
| Private-Mgmt-2 | 10.0.6.0/24 | eu-west-1b | Management/Replication |
| Private-App-3 | 10.0.7.0/24 | eu-west-1c | Application tier |
| Private-DB-3 | 10.0.8.0/24 | eu-west-1c | Database tier |
| Private-Mgmt-3 | 10.0.9.0/24 | eu-west-1c | Management/Replication |

All subnets are private to enhance security by preventing direct internet access to resources.

## Connectivity Options

The solution offers two primary connectivity options for the replication and recovery processes:

### Option 1: AWS DRS with VPN

This option uses AWS Site-to-Site VPN for connectivity between the on-premises environment and AWS:

- **VPN Connection**: IPsec VPN tunnels
- **Customer Gateway**: Represents the on-premises VPN device
- **Virtual Private Gateway**: AWS side of the VPN connection
- **Encryption**: AES-256 for strong encryption
- **Routing**: BGP for dynamic routing updates

#### VPN Architecture

```
On-Premises                      AWS
+---------------+      VPN      +------------------+
| Customer      |<------------->| Virtual Private  |
| Gateway       |<------------->| Gateway          |
+---------------+               +------------------+
                                        |
                                        |
                                +------------------+
                                | VPC              |
                                | Private Subnets  |
                                +------------------+
```

#### VPN Configuration Parameters

- **VPN Type**: Site-to-Site (IPsec)
- **Tunnel 1 Inside CIDR**: 169.254.21.0/30
- **Tunnel 2 Inside CIDR**: 169.254.22.0/30
- **IKE Version**: IKEv2
- **Encryption Algorithm**: AES-256
- **Authentication Method**: Pre-Shared Key
- **DPD Timeout Action**: Clear
- **Dead Peer Detection Interval**: 10 seconds

### Option 2: AWS DRS with Direct Connect + VPN

This option combines AWS Direct Connect for primary connectivity with Site-to-Site VPN as a backup:

- **Direct Connect**: Dedicated, private connection
- **Direct Connect Gateway**: For connecting Direct Connect to multiple VPCs
- **Virtual Private Gateway**: For VPN backup connection
- **BGP Routing**: Dynamic routing with BGP

#### Direct Connect Architecture

```
On-Premises                      AWS
+---------------+   Direct    +------------------+
| Customer      |<----------->| Direct Connect   |
| Router        |             | Gateway          |
+---------------+             +------------------+
       |                               |
       | Backup                        |
+---------------+     VPN     +------------------+
| Customer      |<----------->| Virtual Private  |
| Gateway       |<----------->| Gateway          |
+---------------+             +------------------+
                                       |
                                +------------------+
                                | VPC              |
                                | Private Subnets  |
                                +------------------+
```

#### Direct Connect Configuration Parameters

- **Connection Capacity**: 1Gbps or 10Gbps
- **Connection Type**: Dedicated
- **Virtual Interface Type**: Private
- **BGP ASN**: Customer specified
- **BGP Authentication**: MD5 (recommended)
- **VLAN**: Customer specified

## Traffic Flow

### Replication Traffic Flow

1. Data is read from on-premises servers by the AWS Replication Agent
2. Encrypted replication traffic flows over the VPN or Direct Connect
3. Traffic enters the VPC through the Virtual Private Gateway
4. Routed to DRS replication servers in the private management subnets
5. Data is processed and stored on encrypted EBS volumes

### Recovery Traffic Flow

1. During recovery, EC2 instances are launched in appropriate subnets
2. Application instances in application-tier subnets
3. Database instances in database-tier subnets
4. Management instances in management-tier subnets
5. User access provided through Client VPN or similar secure access method

## Network Security Controls

### Security Groups

| Security Group | Description | Key Rules |
|----------------|-------------|-----------|
| DR-Replication-SG | For DRS replication servers | Allow 1500 TCP from on-premises |
| DR-App-SG | For application servers | Allow app-specific ports from internal |
| DR-DB-SG | For database servers | Allow DB ports from App-SG |
| DR-Mgmt-SG | For management servers | Allow 22, 3389 from trusted sources |

### Network ACLs

Custom Network ACLs are applied to each subnet tier for an additional layer of security:

| Subnet Type | Inbound Rules | Outbound Rules |
|-------------|---------------|----------------|
| App Tier | Allow app ports from internal | Allow to DB and egress |
| DB Tier | Allow DB ports from App tier | Allow responses only |
| Mgmt Tier | Allow mgmt ports from trusted | Allow to all internal |

### VPC Endpoints

To enhance security and reduce data transfer costs, VPC Endpoints are used for AWS service access:

- **Gateway Endpoints**:
  - S3
  - DynamoDB

- **Interface Endpoints**:
  - CloudWatch
  - CloudWatch Logs
  - EC2
  - EC2 Messages
  - EBS
  - SSM
  - KMS
  - Secrets Manager

## Routing Configuration

### Route Tables

Each subnet tier has dedicated route tables for granular control:

| Route Table | Associated Subnets | Routes |
|-------------|-------------------|--------|
| App-Route-Table | All App tier subnets | Local VPC, VPC endpoints, VPN/DX |
| DB-Route-Table | All DB tier subnets | Local VPC, restrictive external access |
| Mgmt-Route-Table | All Mgmt tier subnets | Local VPC, VPC endpoints, VPN/DX |

### Routing Example (App Tier)

```
Destination         Target
-----------         ------
10.0.0.0/16         local
0.0.0.0/0           vgw-id or tgw-id
s3-prefix-list-id   vpce-s3-id
```

## DNS Configuration

- **Private Hosted Zones**: For internal DNS resolution
- **Route 53 Resolver**: For hybrid DNS resolution between on-premises and AWS
- **Conditional Forwarders**: For domain-specific resolution

## Network Monitoring

- **VPC Flow Logs**: Enabled for all VPCs and subnets
- **CloudWatch Metrics**: Network throughput, packets, errors
- **Direct Connect Health**: Monitoring for Direct Connect connections
- **VPN Tunnel Status**: Monitoring for VPN tunnel availability
- **Transit Gateway Network Manager**: For centralized network visibility

## Bandwidth Considerations

### Replication Bandwidth Requirements

Initial replication and ongoing replication have different bandwidth requirements:

- **Initial Replication**: Higher bandwidth needed for initial data copy
  - Recommendation: Allocate dedicated bandwidth during off-hours
  - Consider AWS Snowball for very large initial datasets

- **Ongoing Replication**: Based on data change rate
  - Formula: Daily Data Change Rate * Compression Factor
  - Example: 100GB daily changes * 0.7 compression = ~70GB daily transfer

### Bandwidth Planning by Environment Size

| Environment Size | Estimated Daily Change | Recommended Bandwidth |
|------------------|------------------------|------------------------|
| Small (<1TB) | 10-50GB | 10-50 Mbps |
| Medium (1-10TB) | 50-250GB | 50-250 Mbps |
| Large (>10TB) | 250GB+ | 250+ Mbps |

### Network Optimization

- **Bandwidth Throttling**: Configure replication agent to limit bandwidth usage
- **Compression**: Enabled by default (typically 30% reduction)
- **Change Block Tracking**: Only changed blocks are replicated
- **Schedule Management**: Configure replication windows for optimal network usage

## Implementation Considerations

### Network Prerequisites

Before implementing the DR solution, ensure the following network prerequisites are met:

1. **Firewall Rules**: Configure on-premises firewalls to allow replication traffic
2. **VPN/Direct Connect**: Establish connectivity before DRS agent installation
3. **DNS Resolution**: Configure DNS resolution between environments
4. **Bandwidth Allocation**: Ensure sufficient bandwidth for replication
5. **IP Address Management**: Plan IP addressing to avoid conflicts

### Network Testing Procedures

The following tests should be performed to validate network configuration:

1. **Connectivity Testing**: Validate basic connectivity between environments
2. **Throughput Testing**: Measure actual bandwidth between sites
3. **Latency Testing**: Measure network latency for performance optimization
4. **Failover Testing**: Validate failover between primary and backup connections
5. **Security Testing**: Validate security controls and isolation

For detailed implementation steps, refer to the [Terraform Implementation](20-terraform-implementation.md) and [Deployment Guide](21-deployment-guide.md) documents.