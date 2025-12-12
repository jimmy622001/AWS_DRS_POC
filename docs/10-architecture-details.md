# Architecture Details

This document provides detailed information about the architecture of the AWS DRS solution for banking environments.

## Architecture Overview

The AWS Disaster Recovery Solution architecture is designed with high availability, security, and compliance in mind. It leverages multiple AWS services to create a robust disaster recovery environment in the Ireland (eu-west-1) region.

![DR AWS Architecture](../assets/DR%20AWS.png)

## Core Components

### 1. Network Architecture

#### VPC Design
- **VPC**: A dedicated VPC for the disaster recovery environment
- **Subnets**: Multiple private subnets spread across three Availability Zones
- **Route Tables**: Custom route tables for controlling traffic flow
- **Network ACLs**: Stateless network access controls for additional security
- **Security Groups**: Stateful firewall rules for EC2 instances and other resources

#### Connectivity Options
- **Option 1: VPN Connectivity**
  - Site-to-Site VPN connections between on-premises and AWS
  - Transit Gateway for simplified network management
  - Client VPN for secure user access during DR events
  
- **Option 2: Direct Connect + VPN**
  - AWS Direct Connect for dedicated, private connectivity
  - Site-to-Site VPN as backup connectivity
  - Transit Gateway for simplified network management
  - Client VPN for secure user access during DR events

### 2. AWS Elastic Disaster Recovery Service

- **Replication Servers**: EC2 instances that serve as staging areas for replicated data
- **Replication Settings**: Configured for continuous data replication with minimal RPO
- **Recovery Instances**: EC2 instances launched during recovery operations
- **Recovery Plans**: Pre-configured plans for orchestrated recovery
- **Launch Templates**: Customized templates for recovery instance configuration

### 3. Compute Resources

- **EC2 Instances**: Configured to match source environment specifications
- **Auto Scaling Groups**: For automatic scaling during recovery operations
- **Load Balancers**: Application Load Balancers for distributing traffic

### 4. Storage Resources

- **EBS Volumes**: Block storage for EC2 instances, with multiple volume types
- **EFS**: For shared file storage requirements
- **S3**: For object storage and backups

### 5. Database Resources

- **RDS**: For relational database recovery
- **DynamoDB**: For NoSQL database recovery
- **Database Backup Solutions**: Automated backup and restore procedures

### 6. Security Components

- **IAM**: Roles and policies following least privilege principle
- **KMS**: For encryption key management
- **Security Groups**: Instance-level firewall rules
- **NACLs**: Subnet-level access control lists
- **VPC Endpoints**: For private access to AWS services
- **GuardDuty**: For threat detection
- **AWS Shield**: For DDoS protection
- **AWS WAF**: For web application firewall protection

### 7. Monitoring and Logging

- **CloudWatch**: For metrics, logs, and alarms
- **CloudTrail**: For API activity logging
- **Config**: For configuration compliance
- **EventBridge**: For event-driven automation
- **SNS**: For notifications

### 8. Recovery Orchestration

- **Step Functions**: For automated recovery workflows
- **Lambda**: For serverless automation
- **Systems Manager**: For operational automation

## Detailed Architecture Components

### VPC Network Design

```
VPC: 10.0.0.0/16
|
├── AZ-1: eu-west-1a
│   ├── Private Subnet 1: 10.0.1.0/24 (Application Tier)
│   ├── Private Subnet 2: 10.0.2.0/24 (Database Tier)
│   └── Private Subnet 3: 10.0.3.0/24 (Management Tier)
│
├── AZ-2: eu-west-1b
│   ├── Private Subnet 1: 10.0.4.0/24 (Application Tier)
│   ├── Private Subnet 2: 10.0.5.0/24 (Database Tier)
│   └── Private Subnet 3: 10.0.6.0/24 (Management Tier)
│
└── AZ-3: eu-west-1c
    ├── Private Subnet 1: 10.0.7.0/24 (Application Tier)
    ├── Private Subnet 2: 10.0.8.0/24 (Database Tier)
    └── Private Subnet 3: 10.0.9.0/24 (Management Tier)
```

### Security Groups

| Security Group | Description | Inbound Rules | Outbound Rules |
|----------------|-------------|---------------|----------------|
| DR-Application-SG | For application servers | 80/443 from ALB, 22 from Management | All to DB-SG |
| DR-Database-SG | For database servers | DB ports from App-SG | Limited egress |
| DR-Management-SG | For management servers | 22 from VPN | Limited egress |
| DR-ALB-SG | For load balancers | 80/443 from internet | All to App-SG |
| DR-Replication-SG | For DRS replication servers | DRS ports from on-prem | Limited egress |

### IAM Role Structure

- **DR-Replication-Role**: For DRS replication servers
- **DR-EC2-Application-Role**: For application servers
- **DR-EC2-Database-Role**: For database servers
- **DR-Orchestration-Role**: For recovery orchestration
- **DR-Monitoring-Role**: For monitoring and logging services

### Encryption Strategy

- **KMS Keys**:
  - DR-EBS-Key: For EBS volume encryption
  - DR-RDS-Key: For RDS database encryption
  - DR-S3-Key: For S3 bucket encryption
  - DR-DRS-Key: For DRS replication data encryption

### High Availability Design

- **Multi-AZ Deployment**: All critical resources deployed across three AZs
- **Load Balancing**: ALB distributing traffic across multiple AZs
- **Auto Scaling**: Dynamic scaling based on load
- **Database HA**: Multi-AZ RDS deployments

### Recovery Process Flow

1. **Continuous Replication**:
   - Data continuously replicated from on-premises to AWS
   - Block-level replication for minimal data loss

2. **DR Event Trigger**:
   - Manual or automated triggering of recovery plan
   - Notification sent to relevant stakeholders

3. **Recovery Sequence**:
   - Infrastructure provisioning based on recovery templates
   - Database recovery and validation
   - Application server launch and configuration
   - Network configuration and testing

4. **Validation and Cutover**:
   - Automated testing of recovered environment
   - Traffic cutover to recovered environment
   - Monitoring for performance and functionality

5. **Post-Recovery Operations**:
   - Continuous monitoring of recovered environment
   - Ongoing replication of new data
   - Planning for return to primary site (if applicable)

## AWS Service Integration

### Core Service Integration

| AWS Service | Purpose | Integration Points |
|-------------|---------|-------------------|
| Elastic Disaster Recovery | Primary DR service | Replication, Recovery |
| EC2 | Compute resources | Recovery instances, Replication servers |
| VPC | Networking | Connectivity, Security |
| IAM | Authentication and authorization | Access control |
| KMS | Encryption | Data protection |
| CloudWatch | Monitoring | Metrics, Logs, Alarms |
| Systems Manager | Automation | Recovery scripts, Patching |
| Step Functions | Orchestration | Recovery workflows |
| Lambda | Serverless automation | Custom logic |

### Security Service Integration

| AWS Service | Purpose | Integration Points |
|-------------|---------|-------------------|
| GuardDuty | Threat detection | VPC Flow Logs, CloudTrail |
| Shield | DDoS protection | Load balancers |
| WAF | Web application firewall | Load balancers |
| Secrets Manager | Credential management | Database credentials |
| Config | Compliance monitoring | Resource configuration |
| Security Hub | Security posture | Centralized security view |
| CloudTrail | API logging | Activity monitoring |

## Architecture Decisions and Rationale

### Region Selection

Ireland (eu-west-1) was selected as the DR region for the following reasons:
- Compliance with European data regulations
- Full service availability for all required AWS services
- Geographic separation from on-premises location
- Strong network connectivity options

### Networking Approach

The solution uses private subnets for all resources for the following reasons:
- Enhanced security by preventing direct internet access
- Compliance with banking requirements for network isolation
- Reduced attack surface for critical systems

### Multi-AZ Design

The three Availability Zone design provides:
- Resilience against AZ failures during recovery
- Distributed resources for high availability
- Alignment with banking requirements for redundancy

### Encryption Strategy

Comprehensive encryption is implemented for:
- Compliance with data protection regulations
- Protection of sensitive financial data
- Defense in depth security approach

## Next Steps

For implementation details, please refer to the following documents:
- [Terraform Implementation](20-terraform-implementation.md)
- [Deployment Guide](21-deployment-guide.md)
- [Security Features](11-security-features.md)
- [Networking](12-networking.md)