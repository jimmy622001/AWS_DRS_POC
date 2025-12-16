# What is AWS DRS?

AWS DRS (AWS Elastic Disaster Recovery Service) is designed to help organizations quickly recover their on-premises or cloud-based workloads to AWS in case of a disaster. This document provides a concise overview of how AWS DRS works and its key benefits.

## How AWS DRS Works

### Agent Installation
You install the AWS DRS agent on your source servers (on-premises or other clouds). This agent is responsible for capturing changes on the server at the block level.

### Continuous Replication
The agent continuously replicates the data from your source servers to a staging area in your AWS account. This replication is near real-time, ensuring that the AWS copy is always up-to-date with the source.

### Staging Area
The replicated data is stored in a low-cost staging area in AWS, not as running EC2 instances but as EBS volumes and snapshots. This keeps costs low because you're not paying for live servers.

### Failover/Recovery
In the event of a disaster or when you need to perform a recovery, AWS DRS can quickly launch EC2 instances using the replicated data. These instances are created based on the latest state of your source servers.

### Standby State
The servers are not "always on standby" as running EC2 instances. Instead, the data is continuously replicated and ready to be launched as EC2 instances when needed. This approach is more cost-effective than keeping standby servers running at all times.

### Failback
After the disaster is resolved, you can replicate the changes back to your original environment if needed.

## Key Benefits

1. **Minimal Data Loss**: Sub-second RPO (Recovery Point Objective) through continuous block-level replication
2. **Rapid Recovery**: Minutes RTO (Recovery Time Objective) for critical systems
3. **Cost Efficiency**: Pay only for the resources you use, with minimal costs during normal operation
4. **Non-disruptive Testing**: Test your disaster recovery plan without impacting production environments
5. **Point-in-Time Recovery**: Roll back to specific recovery points, which is crucial for recovering from ransomware attacks
6. **Application Consistency**: Ensures your applications remain consistent during recovery
7. **Cross-Region/Cross-AZ Capability**: Replicate to any AWS Region for true geographic separation

## Summary

- The agent replicates data continuously to AWS
- Data is stored in a staging area, not as running servers
- EC2 instances are launched only during failover/recovery
- This approach minimizes costs while ensuring rapid recovery

For more detailed information about our AWS DRS implementation, please refer to:

- [Solution Overview](docs/01-solution-overview.md) - Complete overview of our DRS solution
- [Architecture Details](docs/architecture.md) - Technical architecture and implementation specifics
- [Recovery Runbooks](docs/40-recovery-runbooks.md) - Detailed procedures for disaster recovery
- [Deployment Guide](docs/21-deployment-guide.md) - Step-by-step implementation instructions