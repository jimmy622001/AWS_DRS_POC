Option 1: AWS Elastic Disaster Recovery Service with VPN
Cost-Effective DR Solution for Banking Infrastructure

Executive Overview

This document outlines the implementation of AWS Elastic Disaster Recovery Service (DRS) with VPN connectivity as a cost-effective disaster recovery solution for on-premise banking infrastructure. This option provides an excellent balance of performance, simplicity, and cost-efficiency for organizations with moderate recovery time requirements.

Solution Architecture

This DR solution utilizes AWS Site-to-Site VPN for secure connectivity between your on-premise location and AWS, combined with AWS DRS for continuous replication and rapid recovery of workloads.

![AWS DRS with VPN Architecture](https://d1.awsstatic.com/product-marketing/CloudEndure/CloudEndureDRDiagram.78c10efbc9be0e086d6c496e54efb0b70513b1af.png)

Key Components

1. AWS Site-to-Site VPN:
   - Secure IPsec tunnel between on-premise location and AWS
   - 1.25 Gbps bandwidth capacity per tunnel (can be scaled with multiple tunnels)
   - Encrypted connection for all replication traffic
   - Cost-effective alternative to dedicated connections

2. AWS Client VPN Endpoint:
   - Secure access for remote users during DR events
   - OpenVPN-based client compatibility
   - Integrated with AWS IAM for access control
   - Scalable to support entire workforce during emergencies

3. AWS Elastic Disaster Recovery Service (DRS):
   - Continuous block-level replication of on-premise servers
   - Sub-second RPO (Recovery Point Objective)
   - Minutes RTO (Recovery Time Objective)
   - Non-disruptive DR testing capabilities

What is AWS Elastic Disaster Recovery?

AWS Elastic Disaster Recovery (DRS) is a service that minimizes downtime and data loss by providing fast, reliable recovery of on-premises and cloud-based applications using affordable storage, minimal compute, and point-in-time recovery.

Key Capabilities

- Continuous Block-Level Replication: Captures changes at the block level as they occur
- Sub-Second RPO: Achieve recovery point objectives of seconds
- Minutes RTO: Recover entire environments in minutes rather than hours
- Point-in-Time Recovery: Roll back to specific recovery points
- Non-Disruptive Testing: Test failover without disrupting production or replication
- Cross-Region/Cross-AZ: Replicate to any AWS Region for true geographic separation
- Automated Failover: Launch recovery instances automatically with predefined configurations

Banking-Specific Benefits

1. Regulatory Compliance:
   - Helps meet regulatory requirements for business continuity
   - Provides audit trails and testing evidence
   - Maintains data sovereignty through region selection

2. Operational Resilience:
   - Ensures critical banking services remain available
   - Protects against regional disasters and cyber incidents
   - Provides multiple recovery points for ransomware protection

3. Cost Optimization:
   - Minimal infrastructure costs during normal operations
   - No duplicate hardware investment
   - Pay-as-you-go pricing model

4. Remote Worker Support:
   - Seamless access to recovered systems via AWS Client VPN
   - Consistent experience regardless of worker location
   - Scalable connectivity for entire workforce

Technical Architecture

Components and Workflow

1. DRS Replication Servers:
   - Lightweight agents installed on source servers
   - Continuous data replication to AWS
   - Compression and encryption in transit

2. Staging Area Subnet:
   - Low-cost EC2 instances maintaining replica state
   - EBS volumes containing replicated data
   - Minimal resource consumption

3. Recovery Instances:
   - Launched only during testing or actual DR events
   - Automatically configured networking and instance types
   - Pre-configured launch sequences

4. VPN Connectivity:
   - AWS Site-to-Site VPN: For system replication
     - IPsec encrypted tunnels
     - BGP or static routing options
     - Redundant tunnels for high availability

   - AWS Client VPN: For remote worker access to DR environment
     - Secure access for employees during DR events
     - Certificate-based authentication
     - Scalable to entire workforce

For detailed technical implementation including Terraform code and deployment instructions, please refer to the [Terraform Implementation Documentation](docs/terraform-implementation.md).

Replication Process

1. Initial Sync:
   - Complete copy of source servers transferred to AWS
   - Bandwidth throttling available to minimize network impact
   - Can use AWS Snowball for very large initial data sets

2. Continuous Replication:
   - Only changed blocks are transmitted
   - Typical bandwidth requirements of 5-10 Mbps per server after initial sync
   - Compressed and encrypted transmission

3. Recovery Process:
   - Launch recovery instances from replicated data
   - Apply latest replication data
   - Automated or manual DNS redirection
   - Systems available in minutes

Banking Workload Compatibility

Virtual Machines / Servers
DRS fully supports replication and recovery of all bank application servers including:
- Core banking systems
- Customer-facing web applications
- Internal administrative systems
- Reporting servers
- Authentication and security systems

Database Servers
DRS provides VM-level replication for database servers:
- SQL Server instances
- Oracle database servers
- MySQL/MariaDB servers
- PostgreSQL environments
- Other RDBMS platforms

For databases with extremely high transaction volumes, DRS can be supplemented with:
- Native database replication technologies
- AWS Database Migration Service (DMS) for continuous replication

File Servers
DRS effectively replicates file servers with:
- Full preservation of file permissions and attributes
- Entire file system hierarchy maintained
- Support for SMB/CIFS and NFS file servers

Enhanced with AWS Storage Gateway:
- Provides local caching for frequently accessed files
- Reduces bandwidth requirements
- Maintains local access patterns while replicating to AWS

Complemented by AWS DataSync:
- Optimized for efficient file transfer
- Preserves metadata and permissions
- Excellent for initial data seeding

Performance Considerations

While VPN connectivity offers excellent performance for most banking DR scenarios, it's important to note:

- Bandwidth: Each VPN tunnel supports up to 1.25 Gbps
- Latency: May vary based on internet conditions
- Consistency: Performance can fluctuate based on internet traffic patterns

For most banking environments, this connectivity solution provides sufficient performance for:
- Maintaining low RPO (seconds to minutes)
- Supporting rapid recovery (minutes to hours)
- Accommodating user access during DR events

Performance Metrics

| Metric | Traditional DR | AWS DRS with VPN |
|--------|---------------|------------------|
| Recovery Point Objective (RPO) | Hours (based on backup schedule) | Seconds to minutes |
| Recovery Time Objective (RTO) | Hours to days | Minutes to hours |
| Testing Impact | Disrupts production | Non-disruptive |
| Time to Implement | 6-12 months | 4-8 weeks |
| Ongoing Maintenance | High | Minimal |
| Cost Model | High fixed costs | Pay-as-you-go |

Implementation Plan

Phase 1: Discovery and Planning (2 Weeks)
- Identify critical systems for initial implementation
- Document network and security requirements
- Establish success criteria and testing methodology

Phase 2: Initial Setup (2 Weeks)
- Configure AWS environment (VPC, subnets, security)
- Establish VPN connectivity between on-premise and AWS
- Install DRS agents on selected servers

Phase 3: Replication and Validation (2 Weeks)
- Monitor initial synchronization
- Validate data integrity
- Configure recovery settings

Phase 4: Testing and Documentation (2 Weeks)
- Perform non-disruptive recovery tests
- Document RTO/RPO achievements
- Refine processes based on test results

Cost Considerations

One-Time Costs
- AWS Professional Services (optional): $10,000-$20,000
- Implementation resources: Internal IT staff time

Ongoing Monthly Costs
- DRS Service fee: ~$0.028 per GB of storage replicated
- Storage costs: ~$0.10 per GB per month
- Staging area compute: ~$0.05 per hour per server
- VPN connection: ~$0.05 per VPN connection-hour
- Data transfer: Varies based on change rate
- Recovery testing: Only during actual tests

Example: For 10 servers totaling 2TB:
- DRS Service fee: ~$0.028 per GB = ~$56 per month for 2TB
- Storage costs: ~$0.10 per GB per month = ~$200 per month for 2TB
- Staging area compute: ~$0.05 per hour per server = ~$360 per month for 10 servers
- VPN connection: ~$0.05 per hour per connection = ~$73 per month (for 2 tunnels)
- Data transfer: ~$0.09 per GB out from AWS = ~$180 per month for 2TB
- Total Monthly Cost: ~$869 per month
- Additional cost during recovery testing: ~$500 per test

For a detailed side-by-side cost comparison between this VPN-only solution and the hybrid Direct Connect + VPN option, please refer to the [Cost Comparison section in the Hybrid Proposal](hybrid-proposal.md).

Testing Methodology

The implementation will include multiple testing scenarios:

1. Individual Server Recovery:
   - Verify single server recovery process
   - Validate application functionality
   - Measure actual RTO achieved

2. Application Group Recovery:
   - Test related servers as a group
   - Verify inter-server communications
   - Validate application functionality

3. Database Consistency Testing:
   - Verify database integrity after recovery
   - Test application-database interactions
   - Validate data consistency

4. User Access Testing:
   - Verify remote worker access to recovered systems
   - Test authentication and authorization
   - Measure user experience

5. VPN Performance Testing:
   - Validate replication performance over VPN
   - Test user experience via Client VPN
   - Measure bandwidth utilization

Key Success Criteria

1. Technical Success:
   - RPO of less than 5 minutes achieved
   - RTO of less than 60 minutes for full environment
   - 100% data integrity in recovered systems
   - Successful non-disruptive testing

2. Operational Success:
   - Minimal impact on production during replication
   - Clear, repeatable recovery procedures
   - Reduced complexity compared to current DR solutions
   - Documented evidence for compliance requirements

3. Financial Success:
   - Lower TCO compared to traditional DR approach
   - Predictable cost model
   - Reduced operational overhead

Next Steps

After successful implementation, we recommend:

1. Expand Coverage:
   - Extend to all critical banking systems
   - Develop comprehensive recovery plans

2. Integration:
   - Integrate with existing monitoring systems
   - Implement automated failover procedures

3. Documentation and Training:
   - Create detailed runbooks
   - Train IT staff on recovery procedures

4. Regular Testing:
   - Establish quarterly testing schedule
   - Continuously refine recovery processes

Conclusion

AWS Elastic Disaster Recovery Service with VPN connectivity offers a cost-effective, reliable solution for banking disaster recovery. This option provides an excellent balance of performance, simplicity, and efficiency for organizations with moderate recovery time requirements and budget considerations.

---

This document describes Option 1 (AWS DRS with VPN) of our banking DR solution. For enhanced performance and reliability with Direct Connect, see the [Hybrid Proposal](hybrid-proposal.md).