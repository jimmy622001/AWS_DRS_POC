Data Replication Strategy for Banking DR

This document outlines the detailed replication strategies for different components of the on-premise banking infrastructure to the AWS DR environment.

VM Server Replication

AWS Application Migration Service (MGN)

AWS MGN (formerly CloudEndure Migration) will be used for continuous replication of on-premise VM servers to EC2 instances in AWS.

Replication Process:
1. Agent Installation: Install the AWS Replication Agent on each source server
2. Initial Sync: Perform initial block-level data sync to AWS
3. Continuous Data Replication: Ongoing capture of byte-level changes

Replication Settings:
- Bandwidth Throttling: Configurable to limit impact on production network
- Data Routing: Private IP routing to avoid data transfer over the public internet
- Compression: Enable data compression to reduce bandwidth usage
- Target Machine Blueprint: Pre-configure instance types, subnet placement, and security groups

Orchestration:
- Test Mode: Launch test instances without disrupting replication
- Cutover: Launch recovery instances during DR event
- Automated Launch Sequence: Define boot order dependencies

Database Replication

AWS Database Migration Service (DMS)

DMS will handle continuous replication of database changes from on-premise to AWS RDS instances.

SQL Server Replication:
1. Source Configuration:
   - Enable MS-CDC (Change Data Capture) on source database
   - Create SQL Server user with appropriate permissions

2. Target Configuration:
   - Create target RDS SQL Server instance with sufficient capacity
   - Configure security groups for proper access

3. DMS Task Configuration:
   - Full load + CDC for initial migration and ongoing replication
   - Configure table mapping and transformation rules
   - Implement validation and error handling

Oracle Database Replication:
1. Source Configuration:
   - Configure Oracle LogMiner or Binary Reader
   - Set up supplemental logging

2. Target Configuration:
   - Create target RDS Oracle instance
   - Configure compatible Oracle version and options

3. DMS Task Configuration:
   - Use Binary Reader for better performance
   - Configure LOB settings for large objects
   - Set up validation and table mapping rules

MySQL/MariaDB Replication:
1. Source Configuration:
   - Enable binary logging
   - Create replication user with required permissions

2. Target Configuration:
   - Create target RDS MySQL/MariaDB instance
   - Configure parameter groups appropriately

3. DMS Task Configuration:
   - Configure binary log position or GTID for replication
   - Set up table mappings and transformations
   - Enable validation to ensure data integrity

Replication Monitoring:
- CloudWatch Metrics: Monitor replication lag, throughput, and errors
- DMS Events: Configure notifications for replication status changes
- Custom Dashboards: Create comprehensive view of replication health

File System Replication

AWS DataSync + Amazon FSx

DataSync will continuously sync files from on-premise file servers to FSx for Windows File Server.

Setup Process:
1. DataSync Agent Installation:
   - Deploy DataSync agent on-premise as a VMware virtual appliance
   - Configure network access to source file shares

2. Source Location Configuration:
   - Create DataSync SMB location for on-premise file servers
   - Configure appropriate credentials and shares

3. Target Configuration:
   - Deploy FSx for Windows File Server in Multi-AZ mode
   - Configure Active Directory integration matching on-premise
   - Set up appropriate file shares and permissions

4. Task Configuration:
   - Schedule regular sync tasks (e.g., every hour)
   - Configure verification mode for data integrity
   - Set up bandwidth throttling to minimize impact

Alternative: AWS Storage Gateway

For scenarios requiring more frequent access or lower latency:

1. File Gateway Deployment:
   - Deploy File Gateway as a VMware appliance on-premise
   - Configure NFS/SMB shares pointing to S3 buckets
   - Cache frequently accessed data locally

2. Storage Configuration:
   - Create S3 buckets with appropriate lifecycle policies
   - Set up IAM roles and bucket policies
   - Configure S3 replication to secondary region for additional resilience

3. Monitoring:
   - Track cache hit ratio and upload/download bandwidth
   - Monitor gateway health metrics
   - Set up CloudWatch alarms for gateway health

Failover Automation

Automated Recovery Procedures

1. Health Checks:
   - Regular monitoring of on-premise systems via CloudWatch custom metrics
   - VPN connection monitoring

2. Failover Triggers:
   - Automated detection of on-premise outage
   - Manual failover option via AWS Systems Manager runbook

3. Recovery Steps:
   - Launch EC2 instances from MGN replication
   - Promote RDS instances if using read replicas
   - Update DNS records for client redirection
   - Activate client VPN for user access

4. Testing:
   - Regular DR drills (quarterly)
   - Validation of RTO/RPO objectives
   - Documentation of lessons learned

Network Configuration for Replication

Optimizing Replication Traffic:
1. Dedicated Bandwidth:
   - Allocate specific bandwidth for replication traffic
   - Schedule intensive replication tasks during off-hours

2. Compression and WAN Optimization:
   - Enable compression in all replication tools
   - Consider WAN optimization appliances for additional efficiency

3. Private Network Paths:
   - Route all replication traffic through the Site-to-Site VPN or Direct Connect
   - Avoid use of public endpoints where possible
   - Utilize multiple AZs within the region for resilience

Compliance and Security Considerations

Data Protection:
- Encrypt all data in transit via VPN
- Encrypt all data at rest in AWS (EBS, S3, FSx)
- Implement appropriate access controls and least privilege

Audit and Compliance:
- Maintain detailed replication logs
- Regular validation of replicated data integrity
- Documentation of DR procedures for regulatory compliance

Estimated RPO and RTO

| Component | Recovery Point Objective (RPO) | Recovery Time Objective (RTO) |
|-----------|-------------------------------|-------------------------------|
| VM Servers | 5-15 minutes | 10-30 minutes |
| Databases | 5 minutes | 15-30 minutes |
| File Systems | 60 minutes | 15 minutes |
| Network Connectivity | N/A | 5-10 minutes |

Note: Actual RPO and RTO may vary based on bandwidth, data change rate, and specific application requirements.