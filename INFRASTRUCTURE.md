# Banking DR Infrastructure Setup

This document provides instructions for setting up the AWS infrastructure for the banking system disaster recovery.

## Prerequisites

1. AWS CLI installed and configured
2. Terraform v1.0+ installed
3. Access keys with appropriate permissions
4. On-premise network information:
   - Public IP address for VPN connection
   - CIDR ranges for internal networks
   - Details of existing infrastructure (VMs, databases, file servers)

## Setup Instructions

### 1. Initialize Terraform

```bash
cd "D:\Terraform Playground\banking-dr"
terraform init
```

### 2. Customize Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:
- Update AWS region if needed
- Configure on-premise IP and CIDR
- Select appropriate instance types and sizes
- Provide secure database credentials

### 3. Plan Deployment

```bash
terraform plan -out=tfplan
```

Review the plan carefully to ensure it meets your requirements.

### 4. Deploy Infrastructure

```bash
terraform apply tfplan
```

### 5. Configure VPN Connection

After deployment:
1. Download the VPN configuration file from the AWS Console
2. Apply the configuration to your on-premise VPN device
3. Verify connectivity between on-premise and AWS environments

### 6. Configure Replication

Follow the steps in `docs/replication_strategy.md` to set up replication for:
- VMs using AWS Application Migration Service
- Databases using appropriate replication methods
- File systems using AWS DataSync or Storage Gateway

### 7. Testing

1. Perform connectivity tests between on-premise and AWS
2. Validate replication is working for all components
3. Conduct a test failover in an isolated environment
4. Document results and any necessary adjustments

## Monitoring

- Set up CloudWatch dashboards for key metrics
- Configure alarms for replication lag and failure
- Implement regular automated testing of DR components

## Cost Optimization

- Use Auto Scaling to minimize resources when not in DR mode
- Consider using reserved instances for components that run continuously
- Implement lifecycle policies for storage to move infrequently accessed data to cheaper storage tiers

## Security Considerations

- Ensure all data in transit is encrypted
- Implement least privilege access controls
- Use AWS Security Hub for security monitoring
- Regularly review and rotate credentials

## Additional Resources

- AWS Documentation: [Disaster Recovery of On-Premises Applications to AWS](https://aws.amazon.com/solutions/implementations/disaster-recovery-of-on-premises-applications-to-aws/)
- AWS Whitepapers: [Disaster Recovery Options in the Cloud](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html)