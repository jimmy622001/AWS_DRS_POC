# AWS Regions for Banking DR Solution

This document outlines the regions used in this AWS Disaster Recovery Solution.

## Primary Region: Ireland (eu-west-1)

The primary AWS region for this solution is **Ireland (eu-west-1)**. This region hosts:

- The replication setup and configuration
- DRS staging area resources
- Monitoring and management components

Key availability zones used:
- eu-west-1a
- eu-west-1b

## Failover Region: London (eu-west-2)

The failover AWS region for disaster recovery is **London (eu-west-2)**. This region is used:

- As the target for recovery operations
- During disaster recovery testing
- For running recovered workloads during a DR event

Key availability zones used:
- eu-west-2a
- eu-west-2b

## Region Selection Rationale

These regions were selected based on several factors:

1. **Geographic Proximity**: 
   - Close enough for low-latency replication
   - Sufficient distance for disaster isolation

2. **Regulatory Compliance**: 
   - Both regions are located in Europe, supporting data sovereignty requirements
   - Helps meet financial industry regulatory requirements

3. **Service Availability**:
   - All required AWS services are available in both regions
   - DRS and related services are fully supported

4. **Network Connectivity**:
   - Direct Connect locations available in both regions
   - High-bandwidth, low-latency connections between regions

## Implementing Failover

To implement a failover to the London region:

1. Update your primary AWS region variable:
   ```hcl
   aws_region = "eu-west-2"  # London
   availability_zones = ["eu-west-2a", "eu-west-2b"]
   ```

2. Run the recovery process as detailed in the disaster recovery runbook

3. Update DNS and network routing to point to the recovered environment

## Testing Across Regions

It's recommended to regularly test the disaster recovery process by failing over to the London region:

1. Schedule quarterly DR tests
2. Validate that all components function correctly in the failover region
3. Document and address any region-specific issues that arise during testing

## Cost Considerations

When using these regions, consider:

- Data transfer costs between Ireland and London regions
- Potential differences in pricing between regions
- Additional costs during DR testing or actual failover events