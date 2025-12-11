Option 2: AWS DRS with Direct Connect + VPN (Hybrid)
Enhanced Banking Disaster Recovery Solution

Executive Overview

This document outlines the implementation of a hybrid connectivity approach for banking disaster recovery, combining AWS Direct Connect for high-performance replication with AWS Client VPN for flexible user access. This enhanced solution provides superior reliability, performance, and security compared to VPN-only connectivity, making it ideal for banking institutions with stringent recovery and compliance requirements.

Hybrid Connectivity Architecture

This DR solution utilizes a combination of AWS Direct Connect and AWS Client VPN to provide optimized connectivity for different aspects of the disaster recovery workflow:

```
┌────────────────────┐                ┌────────────────────────────────────┐
│                    │                │                                    │
│   On-Premises      │                │   AWS DR Environment               │
│   Data Center      │                │                                    │
│                    │                │   ┌──────────┐    ┌──────────┐     │
│   ┌──────────┐     │                │   │          │    │          │     │
│   │          │     │  Direct Connect│   │  DRS     │    │  DR VMs  │     │
│   │ Banking  │◄────┼────────────────┼───┤  Service │───►│          │     │
│   │ VMs      │     │  (Replication) │   │          │    │          │     │
│   │          │     │                │   └──────────┘    └─────▲────┘     │
│   └──────────┘     │                │                        │           │
│                    │                │                        │           │
└────────────────────┘                └────────────────────────┼───────────┘
                                                              │
                                                              │
┌────────────────────┐                                        │
│                    │                                        │
│   Remote Workers   │                Client VPN              │
│   ┌──────────┐     │◄───────────────────────────────────────┘
│   │          │     │    (User Access after failover)
│   │  Laptops │     │
│   │          │     │
│   └──────────┘     │
│                    │
└────────────────────┘
```

Key Components

1. AWS Direct Connect
Direct Connect provides a dedicated network connection from your on-premises data center to AWS, bypassing the public internet:

- Dedicated Connection: 1Gbps or 10Gbps private connection to AWS
- Predictable Performance: Consistent latency and throughput
- SLA-backed Availability: 99.99% availability guarantee
- Enhanced Security: Traffic doesn't traverse the public internet

2. AWS Client VPN
Client VPN provides secure access for employees during disaster recovery events:

- OpenVPN-based Client: Compatible with major operating systems
- Certificate-based Authentication: Strong security for user access
- Scalable Connectivity: Support for the entire workforce
- Granular Access Control: Control access to specific subnets and resources

3. AWS Elastic Disaster Recovery (DRS)
DRS provides block-level replication and rapid recovery of on-premise workloads:

- Continuous Block-level Replication: Sub-second RPO
- Minutes RTO: Rapid recovery of critical systems
- Point-in-time Recovery: Roll back to specific recovery points
- Non-disruptive Testing: Test recovery without disrupting production

Why Direct Connect for Banking DR?

For banking institutions, Direct Connect offers several critical advantages over internet-based connectivity:

Performance Benefits

- Consistent Network Performance: Direct Connect provides predictable, dedicated bandwidth with consistent latency - essential for maintaining low RPO through reliable replication.
- Higher Bandwidth: Supports connections from 50Mbps to 10Gbps, enabling faster data replication.
- Lower Latency: By bypassing the public internet, latency is reduced by approximately 30-50% compared to VPN connections.

Reliability Advantages

- SLA-backed Connections: Direct Connect offers 99.99% availability SLA, critical for financial institutions.
- Physical Isolation: Not susceptible to internet congestion or public network issues.
- Dedicated Circuit: No bandwidth competition with other internet traffic.

Security Considerations

- Private Connectivity: Traffic doesn't traverse the public internet, reducing attack surface.
- Regulatory Compliance: Better aligns with financial regulations that may require private network connections for sensitive data.
- Consistent Security Posture: Extends on-premises security controls to AWS.

Banking Workload Compatibility

The hybrid connectivity solution supports all critical banking workloads:

Core Banking Systems
- Complete replication of core banking VMs
- Rapid recovery with pre-configured instance types
- Minimal downtime during failover

Database Servers
- VM-level replication of database servers
- Support for SQL Server, Oracle, MySQL, PostgreSQL
- Optional database-specific replication for high-transaction systems

Payment Processing Systems
- Ensures availability of payment processing during disasters
- Maintains secure connectivity for payment transactions
- Preserves PCI-DSS compliance in DR environment

Customer-facing Systems
- Rapid recovery of online banking platforms
- Minimal disruption to customer experience
- Automated DNS redirection for customer traffic

Performance Comparison

| Metric | Option 1: VPN Only | Option 2: Direct Connect + VPN |
|--------|-------------------|-----------------------------|
| Bandwidth | Up to 1.25 Gbps per tunnel | 1-10 Gbps dedicated |
| Latency | Variable (internet-dependent) | Consistent (SLA-backed) |
| Jitter | Medium-High | Very Low |
| Reliability | No SLA | 99.99% SLA |
| Replication Performance | Good | Excellent |
| Recovery Time | Minutes to hours | Minutes |
| Regulatory Compliance | Standard | Enhanced |

Implementation Process

Phase 1: Discovery and Planning (2 Weeks)
- Identify critical systems for DR
- Select appropriate Direct Connect location
- Document network architecture and requirements
- Engage with Direct Connect provider

Phase 2: Initial Setup (2-3 Weeks)
- Order and establish Direct Connect circuit
- Configure AWS environment (VPC, subnets, security)
- Set up Client VPN endpoint
- Install DRS agents on source servers

Phase 3: Replication and Validation (2 Weeks)
- Initiate replication over Direct Connect
- Monitor initial synchronization
- Validate data integrity
- Configure recovery settings

Phase 4: Testing and Documentation (2 Weeks)
- Perform non-disruptive recovery tests
- Document RTO/RPO achievements
- Test user access via Client VPN
- Refine processes based on test results

Cost Comparison: Direct Connect vs VPN

Below is a side-by-side comparison of the costs associated with each connectivity option for the same example scenario (10 servers, 2TB data):

Direct Connect Solution Costs:
- Port Hours: ~$0.30 per hour for 1Gbps = ~$216 per month
- Data Transfer: ~$0.02 per GB out from AWS = ~$40 per month for 2TB
- DRS Service fee: ~$0.028 per GB = ~$56 per month for 2TB
- Storage costs: ~$0.10 per GB per month = ~$200 per month for 2TB
- Staging area compute: ~$0.05 per hour per server = ~$360 per month for 10 servers
- Connection Fee: One-time fee from Direct Connect partner ($1,000-$5,000 depending on location)
- Client VPN: ~$0.10 per client connection-hour (only during DR events)
- Total Monthly Cost: ~$872 plus one-time setup fee
- Additional cost during recovery testing: ~$500 per test

VPN-Only Solution Costs:
- VPN Connection: ~$0.05 per hour per connection = ~$73 per month (for 2 tunnels)
- Data Transfer: ~$0.09 per GB out from AWS = ~$180 per month for 2TB
- DRS Service fee: ~$0.028 per GB = ~$56 per month for 2TB
- Storage costs: ~$0.10 per GB per month = ~$200 per month for 2TB
- Staging area compute: ~$0.05 per hour per server = ~$360 per month for 10 servers
- Total Monthly Cost: ~$869 per month
- Additional cost during recovery testing: ~$500 per test

Cost Difference Analysis:
- Base Monthly Difference: ~$3 ($872 vs $869)
- Annual Difference: ~$36
- One-time Direct Connect setup fee: $1,000-$5,000
- Higher data transfer costs for VPN: ~$140 more per month for VPN ($180 vs $40)

Return on Investment Considerations:
- Direct Connect provides ~80% savings on ongoing data transfer costs
- The minimal monthly premium provides:
  - Approximately 30-50% lower latency
  - Guaranteed bandwidth of up to 10Gbps compared to VPN's practical limit of 1.25Gbps
  - Consistent performance without internet congestion impact
  - Enhanced security by avoiding public internet for critical data transfers
  - Improved recovery times and more reliable DR testing
  - Higher SLA (99.99% vs 99.95% for VPN)
  - Better support for regulatory compliance requirements

While the hybrid option has a higher initial setup cost compared to the VPN-only solution, the ongoing monthly costs are comparable when considering the data transfer savings. The enhanced reliability, performance, security, and compliance advantages provide significant value for banking institutions with stringent recovery requirements.

Deployment Requirements

To implement the hybrid connectivity approach:

1. Select Direct Connect Location: Choose an AWS Direct Connect location geographically close to your data center
2. Engage Network Provider: Work with an AWS Direct Connect Partner to establish the physical connection
3. Configure On-premises Router: Set up BGP and prepare your router for Direct Connect termination
4. Complete Letter of Authorization (LOA): Required for cross-connect within the colocation facility

For technical implementation details including Terraform code and deployment instructions, please refer to the [Terraform Implementation Documentation](docs/terraform-implementation.md).

Benefits Summary

The hybrid connectivity approach offers significant advantages for banking DR:

1. Enhanced Reliability:
   - SLA-backed connectivity ensures replication consistency
   - Reduced dependence on internet quality and availability
   - Minimized risk of replication interruptions

2. Superior Performance:
   - Dedicated bandwidth for replication traffic
   - Consistent low latency for critical data transfer
   - Better support for high-transaction banking workloads

3. Stronger Security:
   - Private network connectivity for sensitive banking data
   - Reduced attack surface by avoiding public internet
   - Enhanced compliance with financial industry regulations

4. Operational Excellence:
   - Predictable replication performance
   - More consistent recovery times
   - Better support for tight RPO/RTO requirements

Conclusion

The hybrid connectivity approach combining AWS Direct Connect for replication and AWS Client VPN for user access delivers an optimal balance of performance, security, and reliability for banking disaster recovery. This enhanced solution is particularly valuable for financial institutions with stringent recovery requirements, high-transaction workloads, and strict regulatory compliance obligations.

---

This document describes Option 2 (AWS DRS with Direct Connect + VPN) of our banking DR solution. For a simpler, cost-effective approach, see the [DRS with VPN Proposal](DRS-proposal.md).