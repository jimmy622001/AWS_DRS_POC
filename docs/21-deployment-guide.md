# Deployment Guide

This guide provides step-by-step instructions for deploying the AWS DRS solution for banking environments.

## Deployment Overview

The deployment process consists of the following phases:

1. **Preparation**: Set up prerequisites and prepare the environment
2. **Infrastructure Deployment**: Deploy the AWS infrastructure using Terraform
3. **Replication Configuration**: Configure and initialize replication
4. **Testing and Validation**: Validate the deployment and test recovery
5. **Documentation and Handover**: Document the deployment and train users

## Phase 1: Preparation

### AWS Account Setup

1. **Create or Identify AWS Account**:
   - Ensure the account has appropriate permissions
   - Set up AWS Organizations if using multiple accounts

2. **Configure AWS Account Security**:
   - Enable MFA for root and IAM users
   - Set up CloudTrail
   - Configure appropriate service control policies

3. **Set Up IAM Users and Roles**:
   - Create IAM users with appropriate permissions
   - Create service roles for Terraform

### Network Preparation

#### For VPN Option:

1. **Identify On-Premises VPN Device**:
   - Document make, model, and software version
   - Ensure it supports BGP routing

2. **Allocate Public IP Address**:
   - Assign static public IP to on-premises VPN device
   - Document this IP for use in Terraform configuration

3. **Prepare Firewall Rules**:
   - Allow UDP ports 500 and 4500 for IKE and NAT-T
   - Allow IP protocol 50 (ESP) if not using NAT-T

#### For Direct Connect Option:

1. **Order Direct Connect**:
   - Work with AWS or partner to order Direct Connect
   - Choose appropriate bandwidth (1Gbps or 10Gbps)
   - Document the Direct Connect ID and details

2. **Prepare On-Premises Router**:
   - Configure router for BGP
   - Allocate ASN for BGP peering
   - Configure VLAN tagging

### Source Environment Preparation

1. **Inventory Source Servers**:
   - Document server specifications (OS, CPU, RAM, disk)
   - Identify dependencies between servers
   - Document IP addressing scheme

2. **Assess Bandwidth Requirements**:
   - Calculate total data volume
   - Estimate change rate
   - Determine replication bandwidth needs

3. **Prepare Source Servers**:
   - Ensure servers meet AWS DRS requirements
   - Check OS compatibility
   - Ensure sufficient disk space for agent installation

## Phase 2: Infrastructure Deployment

### Environment Setup

1. **Set Up Local Development Environment**:
   - Install Terraform (version 1.0.0 or higher)
   - Install AWS CLI and configure credentials
   - Clone the repository
   ```bash
   git clone <repository-url>
   cd AWS_DRS_POC
   ```

2. **Configure Terraform Variables**:
   - Create a `terraform.tfvars` file with your specific configuration
   ```hcl
   region              = "eu-west-1"
   connectivity_option = "vpn"  # or "direct_connect"
   on_prem_cidr        = "192.168.0.0/16"
   on_prem_router_ip   = "203.0.113.10"
   dr_activated        = false
   ```

### Terraform Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the Deployment**:
   ```bash
   terraform plan -var-file=terraform.tfvars -out=tfplan
   ```
   - Review the plan to ensure it matches expectations
   - Pay special attention to resource counts and types

3. **Apply the Deployment**:
   ```bash
   terraform apply tfplan
   ```
   - Monitor the deployment for any errors
   - Record the outputs for future reference

### Post-Deployment Configuration

1. **Configure VPN Connection** (if using VPN option):
   - Download VPN configuration from AWS
   - Apply configuration to on-premises VPN device
   - Verify tunnel status in AWS console

2. **Configure Direct Connect** (if using Direct Connect option):
   - Complete cross-connect with Direct Connect partner
   - Configure Virtual Interface (VIF)
   - Verify BGP peering is established

3. **Verify Connectivity**:
   - Test connectivity between on-premises and AWS
   - Verify BGP routes are being exchanged
   - Test end-to-end connectivity to AWS resources

## Phase 3: Replication Configuration

### AWS DRS Agent Installation

1. **Generate and Download AWS DRS Agent Installer**:
   - Navigate to the AWS DRS console
   - Select "Source servers" and click "Add servers"
   - Generate and download the appropriate installer for your OS

2. **Install AWS DRS Agent on Source Servers**:
   - For Windows servers:
     ```
     AwsReplicationWindowsInstaller.exe
     ```
   - For Linux servers:
     ```bash
     chmod +x AwsReplicationLinuxInstaller.sh
     sudo ./AwsReplicationLinuxInstaller.sh
     ```
   - Follow the prompts to complete installation

3. **Verify Agent Registration**:
   - Check the AWS DRS console to confirm servers appear
   - Verify agent status is "Healthy"
   - Check initial data replication status

### Replication Configuration

1. **Configure Replication Settings**:
   - In the AWS DRS console, select your source servers
   - Click "Actions" and select "Configure replication settings"
   - Configure the following settings:
     - EBS encryption (enable and select KMS key)
     - Replication server instance type
     - Staging area subnet

2. **Initialize Replication**:
   - Click "Initialize Data Replication"
   - Monitor the initial replication progress
   - Note: Initial replication may take time depending on data volume

3. **Monitor Replication Status**:
   - Regularly check the replication status in the AWS DRS console
   - Monitor CloudWatch metrics for replication lag
   - Set up CloudWatch alarms for replication issues

## Phase 4: Testing and Validation

### Infrastructure Validation

1. **Validate Network Configuration**:
   - Verify VPC and subnet configuration
   - Check security group rules
   - Validate route tables and routing
   - Test connectivity between components

2. **Validate Security Controls**:
   - Verify encryption configuration
   - Check IAM roles and policies
   - Validate security group rules
   - Test access controls

3. **Validate Monitoring and Logging**:
   - Check CloudWatch logs
   - Verify CloudTrail logging
   - Test CloudWatch alarms
   - Validate log retention policies

### Recovery Testing

1. **Test Recovery for Non-Critical Systems**:
   - Select a non-critical server in the AWS DRS console
   - Launch a recovery instance
   - Verify instance launches successfully
   - Test application functionality

2. **Document Recovery Metrics**:
   - Measure time to launch recovery instances
   - Document any issues encountered
   - Record application startup time
   - Calculate total recovery time

3. **Test Application Functionality**:
   - Verify application connectivity
   - Test application functionality
   - Validate data integrity
   - Test user access

4. **Perform Full Recovery Drill**:
   - Schedule a full recovery drill
   - Follow recovery runbooks
   - Document lessons learned
   - Improve procedures based on findings

## Phase 5: Documentation and Handover

### Documentation

1. **Update Architecture Documentation**:
   - Document the as-built architecture
   - Update network diagrams
   - Document IP addressing scheme
   - Record AWS resource IDs

2. **Create Operational Documentation**:
   - Document monitoring procedures
   - Create incident response procedures
   - Document maintenance tasks
   - Create troubleshooting guides

3. **Update Recovery Runbooks**:
   - Document recovery procedures
   - Create step-by-step recovery guides
   - Document validation checks
   - Create post-recovery procedures

### Training and Handover

1. **Train Operations Team**:
   - Provide training on AWS DRS console
   - Train on recovery procedures
   - Review monitoring and alerting
   - Cover troubleshooting procedures

2. **Train Recovery Team**:
   - Review recovery runbooks
   - Conduct recovery exercises
   - Train on application validation
   - Cover post-recovery procedures

3. **Conduct Handover**:
   - Formal handover to operations team
   - Review documentation
   - Verify access to resources
   - Set up support procedures

## Post-Deployment Activities

### Regular Testing and Maintenance

1. **Schedule Regular Recovery Tests**:
   - Conduct monthly recovery tests for critical systems
   - Perform quarterly full recovery drills
   - Document and address issues

2. **Monitor and Optimize**:
   - Review CloudWatch metrics regularly
   - Optimize replication settings
   - Adjust instance types as needed
   - Review and optimize costs

3. **Keep Documentation Updated**:
   - Update runbooks as procedures change
   - Keep architecture diagrams current
   - Document configuration changes
   - Maintain up-to-date contact information

## Troubleshooting Common Issues

### Connectivity Issues

1. **VPN Connection Problems**:
   - Check tunnel status in AWS console
   - Verify on-premises device configuration
   - Check routing tables
   - Validate security groups and NACLs

2. **Direct Connect Issues**:
   - Check virtual interface status
   - Verify BGP peering
   - Check on-premises router configuration
   - Test connectivity with ping and traceroute

### Replication Issues

1. **Agent Installation Failures**:
   - Check server prerequisites
   - Verify network connectivity
   - Check permissions
   - Review agent logs

2. **Replication Lag**:
   - Check available bandwidth
   - Verify no network throttling
   - Consider increasing replication server instance size
   - Check for disk I/O bottlenecks

### Recovery Issues

1. **Instance Launch Failures**:
   - Check IAM permissions
   - Verify subnet has available IP addresses
   - Review security group configuration
   - Check service quotas

2. **Application Functionality Problems**:
   - Verify network connectivity
   - Check application dependencies
   - Validate database connections
   - Review application logs

For detailed testing procedures, refer to the [Testing Procedures](22-testing-procedures.md) document.