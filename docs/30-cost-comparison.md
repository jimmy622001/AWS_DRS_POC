# Cost Comparison: DR Solution Options

This document provides a detailed cost comparison between the different disaster recovery options available in this solution.

## Cost Analysis Overview

Implementing a disaster recovery solution involves various cost components that should be considered when making a decision. This document compares the costs of the two primary options:

1. **Option 1: AWS DRS with VPN**
2. **Option 2: AWS DRS with Direct Connect + VPN**

## Cost Components

### Common Cost Components

Both options include the following common cost components:

1. **AWS Elastic Disaster Recovery Service**:
   - Replication charges per server
   - EBS storage for replication
   - EC2 instances for staging servers

2. **Compute Resources**:
   - EC2 instances during recovery testing or actual recovery
   - Elastic Load Balancers during recovery

3. **Storage Resources**:
   - EBS volumes
   - S3 storage
   - EFS storage (if applicable)

4. **Security Services**:
   - KMS key usage
   - AWS Shield (if activated)
   - AWS WAF (if activated)
   - Security Hub (if activated)

5. **Management and Monitoring**:
   - CloudWatch
   - Config
   - CloudTrail

### Option-Specific Cost Components

#### Option 1: AWS DRS with VPN

- **VPN Connection**: Monthly charges for VPN connections
- **Data Transfer**: Data transfer costs over VPN
- **Transit Gateway**: If used for complex networking

#### Option 2: AWS DRS with Direct Connect + VPN

- **Direct Connect Port**: Monthly charges for Direct Connect port
- **Direct Connect Partner Charges**: Fees charged by the Direct Connect partner
- **Cross-Connect Fees**: One-time and recurring charges for physical cross-connects
- **VPN Connection**: Monthly charges for backup VPN
- **Data Transfer**: Data transfer costs over Direct Connect
- **Transit Gateway**: If used for complex networking

## Monthly Cost Components

### Common Components (Both Options)

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| DRS Service | £0.022 per GB | Based on replicated storage volume |
| EBS Storage | £0.078 per GB | For replicated data |
| Staging Area EC2 | £0.039 per hour per server | t3.small instances for staging |
| Recovery EC2 | £0 | Only charged during DR testing/events |

### Option 1: AWS DRS with VPN

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| Site-to-Site VPN | £0.039 per connection-hour<br>(£28.47 per month) | Per VPN connection |
| Client VPN | £0.078 per connection-hour | Only during DR events |
| Data Transfer (Internet) | £0.070 per GB | For outbound traffic |

### Option 2: AWS DRS with Direct Connect + VPN (Hybrid)

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| Direct Connect (1Gbps) | £0.234 per hour<br>(£170.82 per month) | Dedicated port |
| Client VPN | £0.078 per connection-hour | Only during DR events |
| Data Transfer (Direct Connect) | £0.016 per GB | For outbound traffic (significantly cheaper) |
| Cross-Connect Fee | £78-£390 | One-time fee, varies by facility |

## Detailed Cost Analysis

The following tables provide a detailed breakdown of estimated monthly costs for each option, based on different sized deployments.

### Assumptions

- Region: Ireland (eu-west-1)
- Recovery testing performed quarterly
- DR activation: Not included in monthly cost (separate calculation)

### Small Banking Environment
- 10 servers, 1TB total replicated data
- 50GB daily change rate
- 10 users during DR events

| Component | Option 1 (VPN) | Option 2 (Hybrid) |
|-----------|--------------|------------------|
| Connectivity | £28.47 | £170.82 |
| DRS Service | £21.84 | £21.84 |
| Storage | £78.00 | £78.00 |
| Staging EC2 | £280.80 | £280.80 |
| Data Transfer | £105.30 | £23.40 |
| Monthly Total | £514.41 | £574.86 |
| Annual Cost | £6,172.92 | £6,898.32 |
| Cost Difference | - | +11.7% |

### Medium Banking Environment
- 25 servers, 5TB total replicated data
- 200GB daily change rate
- 50 users during DR events

| Component | Option 1 (VPN) | Option 2 (Hybrid) |
|-----------|--------------|------------------|
| Connectivity | £56.94 | £170.82 |
| DRS Service | £109.20 | £109.20 |
| Storage | £390.00 | £390.00 |
| Staging EC2 | £702.00 | £702.00 |
| Data Transfer | £421.20 | £93.60 |
| Monthly Total | £1,679.34 | £1,465.62 |
| Annual Cost | £20,152.08 | £17,587.44 |
| Cost Difference | - | -12.7% |

### Large Banking Environment (50 servers, 10TB total data)

| Component | Option 1 (VPN) | Option 2 (Hybrid) |
|-----------|--------------|------------------|
| Connectivity | £113.88 | £170.82 |
| DRS Service | £218.40 | £218.40 |
| Storage | £780.00 | £780.00 |
| Staging EC2 | £1,404.00 | £1,404.00 |
| Data Transfer | £1,053.00 | £234.00 |
| Monthly Total | £3,569.28 | £2,807.22 |
| Annual Cost | £42,831.36 | £33,686.64 |
| Cost Difference | - | -21.4% |

### Option 1: AWS DRS with VPN (Large Environment)

| Component | Details | Monthly Cost (GBP) |
|-----------|---------|-------------------|
| **AWS DRS** | | |
| - Replication | 50 servers × £0.022 per hour | £786.24 |
| - EBS Storage | 10TB × £0.078 per GB | £780.00 |
| **Networking** | | |
| - VPN Connection | 2 tunnels × £0.039 per hour | £56.16 |
| - Data Transfer | 1TB daily change × 30 days × £0.070 per GB | £2,106.00 |
| **Security Services** | | |
| - KMS Keys | 4 keys × £0.78 per month | £3.12 |
| - CloudTrail | Standard logging | £2.34 |
| - Config | 50 resources × £0.002 per configuration item | £3.51 |
| **Monitoring** | | |
| - CloudWatch | Basic monitoring | £19.50 |
| **Total Monthly Cost** | | **£3,756.87** |

### Option 2: AWS DRS with Direct Connect + VPN (Large Environment)

| Component | Details | Monthly Cost (GBP) |
|-----------|---------|-------------------|
| **AWS DRS** | | |
| - Replication | 50 servers × £0.022 per hour | £786.24 |
| - EBS Storage | 10TB × £0.078 per GB | £780.00 |
| **Networking** | | |
| - Direct Connect Port | 1Gbps dedicated connection × £0.234 per hour | £168.48 |
| - Direct Connect Partner | Varies by partner (estimated) | £390.00 |
| - VPN Connection (Backup) | 2 tunnels × £0.039 per hour | £56.16 |
| - Data Transfer | 1TB daily change × 30 days × £0.016 per GB | £468.00 |
| **Security Services** | | |
| - KMS Keys | 4 keys × £0.78 per month | £3.12 |
| - CloudTrail | Standard logging | £2.34 |
| - Config | 50 resources × £0.002 per configuration item | £3.51 |
| **Monitoring** | | |
| - CloudWatch | Basic monitoring | £19.50 |
| **Total Monthly Cost** | | **£2,677.35** |

## DR Testing Costs (Per Test)

Additional costs incurred during quarterly recovery tests:

| Component | Option 1 (VPN) | Option 2 (Hybrid) |
|-----------|--------------|------------------|
| Recovery EC2 (24h) | £374.40 | £374.40 |
| Client VPN (24h) | £18.72 | £18.72 |
| Data Transfer | £70.20 | £15.60 |
| Total Per Test | £463.32 | £408.72 |
| Annual (4 tests) | £1,853.28 | £1,634.88 |

| Component | Details | Cost per Test (GBP) |
|-----------|---------|---------------------|
| EC2 Instances | 50 servers × avg £0.078 per hour × 24 hours | £93.60 |
| EBS Volumes | 10TB × £0.078 per GB × 3 days | £78.00 |
| Elastic Load Balancer | £0.0195 per hour × 24 hours | £0.47 |
| Data Transfer | 500GB × £0.070 per GB | £35.10 |
| **Total Cost per Test** | | **£207.17** |

### Actual DR Event Costs

Costs for an actual DR event (2 weeks of operation):

| Component | Details | Cost for 2 Weeks (GBP) |
|-----------|---------|------------------------|
| EC2 Instances | 50 servers × avg £0.078 per hour × 336 hours | £1,310.40 |
| EBS Volumes | 10TB × £0.078 per GB × 14 days | £364.26 |
| Elastic Load Balancer | £0.0195 per hour × 336 hours | £6.55 |
| Data Transfer Out | 5TB × £0.070 per GB | £351.00 |
| **Total DR Event Cost** | | **£2,032.21** |

## Total Cost of Ownership (3-Year)

### Small Banking Environment

| Cost Component | Option 1 (VPN) | Option 2 (Hybrid) |
|----------------|--------------|------------------|
| Monthly Operational | £514.41 | £574.86 |
| 3-Year Operational | £18,518.76 | £20,694.96 |
| DR Testing (12 tests) | £5,559.84 | £4,904.64 |
| Implementation | £7,800.00 | £11,700.00 |
| Direct Connect Setup | £0.00 | £390.00 |
| 3-Year TCO | £31,878.60 | £37,689.60 |
| Monthly Equivalent | £885.52 | £1,046.93 |
| Cost Difference | - | +18.2% |

### Medium Banking Environment

| Cost Component | Option 1 (VPN) | Option 2 (Hybrid) |
|----------------|--------------|------------------|
| Monthly Operational | £1,679.34 | £1,465.62 |
| 3-Year Operational | £60,456.24 | £52,762.32 |
| DR Testing (12 tests) | £5,559.84 | £4,904.64 |
| Implementation | £11,700.00 | £15,600.00 |
| Direct Connect Setup | £0.00 | £390.00 |
| 3-Year TCO | £77,716.08 | £73,656.96 |
| Monthly Equivalent | £2,158.78 | £2,046.03 |
| Cost Difference | - | -5.2% |

### Large Banking Environment

| Cost Component | Option 1 (VPN) | Option 2 (Hybrid) |
|----------------|--------------|------------------|
| Monthly Operational | £3,569.28 | £2,807.22 |
| 3-Year Operational | £128,494.08 | £101,059.92 |
| DR Testing (12 tests) | £5,559.84 | £4,904.64 |
| Implementation | £15,600.00 | £19,500.00 |
| Direct Connect Setup | £0.00 | £390.00 |
| 3-Year TCO | £149,653.92 | £125,854.56 |
| Monthly Equivalent | £4,157.05 | £3,495.96 |
| Cost Difference | - | -15.9% |

## Cost-Benefit Analysis

### Option 1: AWS DRS with VPN

**Advantages**:
- Lower initial setup costs
- No long-term commitments
- Flexibility to adjust or cancel
- Simpler implementation
- Faster deployment timeline

**Disadvantages**:
- Higher data transfer costs
- Potentially lower performance
- No SLA for connectivity

**Best for**:
- Organizations with lower replication volumes
- Budget-conscious implementations
- Environments where performance is not critical
- Small banking environments

### Option 2: AWS DRS with Direct Connect + VPN

**Advantages**:
- Lower data transfer costs
- Better performance and reliability
- SLA for connectivity
- More consistent RPO/RTO
- Enhanced security and compliance

**Disadvantages**:
- Higher initial setup costs
- Longer lead time for implementation
- Long-term commitment required

**Best for**:
- Organizations with higher replication volumes
- Performance-sensitive implementations
- Environments requiring guaranteed bandwidth
- Medium to large banking environments

## Non-Financial Factors

| Factor | Option 1 (VPN) | Option 2 (Hybrid) |
|--------|--------------|------------------|
| Performance | Good | Excellent |
| Reliability | Good | Excellent |
| Implementation Complexity | Lower | Higher |
| Regulatory Compliance | Good | Excellent |
| Replication Consistency | Good | Excellent |
| SLA Backing | No | Yes |

## Risk Considerations

| Risk Factor | Option 1 (VPN) | Option 2 (Hybrid) |
|-------------|--------------|------------------|
| Internet Dependency | High | Low |
| Replication Interruption | Medium | Low |
| Recovery Time Variability | Medium | Low |
| Bandwidth Competition | High | Low |
| Compliance Risk | Medium | Low |

## Cost Optimization Strategies

### For Option 1: VPN

1. **Optimize Replication**:
   - Configure replication to run during off-peak hours
   - Implement bandwidth throttling
   - Optimize change rate through data lifecycle management

2. **Reduce Storage Costs**:
   - Use tiered storage for less critical data
   - Implement lifecycle policies for snapshots
   - Right-size EBS volumes

3. **Network Optimization**:
   - Compress data before transmission
   - Optimize application data changes
   - Consider VPN accelerators

### For Option 2: Direct Connect

1. **Optimize Direct Connect Usage**:
   - Choose appropriate port speed
   - Share Direct Connect across multiple applications
   - Use Direct Connect Gateway for multiple regions

2. **Hybrid Approach**:
   - Use Direct Connect for initial replication
   - Consider switching to VPN for ongoing replication

3. **Right-Size Resources**:
   - Optimize EC2 instance types for replication servers
   - Scale resources based on replication volume

## Generating Detailed Cost Projections

For a customized cost projection tailored to your specific environment:

```powershell
# For Option 1 (VPN-only)
./dr-cost-projection.ps1 -Option vpn-only -Environment custom -Servers 15 -DataVolume 3TB

# For Option 2 (Hybrid with Direct Connect)
./dr-cost-projection.ps1 -Option hybrid-connect -Environment custom -Servers 15 -DataVolume 3TB
```

## Conclusion

### Cost Summary

- **Option 1 (VPN)**: Higher ongoing costs due to data transfer pricing, but lower initial investment
- **Option 2 (Direct Connect)**: Higher initial investment but lower ongoing costs, especially for large data volumes

### Recommendation Framework

- For data volumes **under 1TB daily change rate**: Option 1 (VPN) may be more cost-effective
- For data volumes **over 1TB daily change rate**: Option 2 (Direct Connect) becomes more cost-effective
- For **performance-critical** applications: Option 2 provides better performance guarantees
- For **budget-constrained** implementations with moderate performance needs: Option 1 is suitable

### Final Considerations

When selecting between the two options, consider:

1. **Total Cost of Ownership**: Not just monthly costs, but 3-year TCO
2. **Performance Requirements**: Impact of network performance on recovery objectives
3. **Compliance Requirements**: Some regulations may require dedicated connectivity
4. **Future Growth**: Consider future data growth and changing requirements
5. **Risk Tolerance**: Higher investment in Option 2 may be justified by reduced risk
6. **Environment Size**: Direct Connect becomes more cost-effective as environment size increases
7. **Long-term Strategy**: Direct Connect provides better foundation for future expansion

For detailed implementation instructions, refer to the [Terraform Implementation](20-terraform-implementation.md) and [Deployment Guide](21-deployment-guide.md) documents.