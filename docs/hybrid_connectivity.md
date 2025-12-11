Banking DR Hybrid Connectivity Solution

Overview

This document outlines the hybrid connectivity approach for the banking DR solution, which combines AWS Direct Connect for system replication and AWS Client VPN for remote user access. This approach optimizes performance, security, and cost-efficiency for the disaster recovery environment.

Architecture

The hybrid connectivity architecture uses dedicated connections for different types of traffic:

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

Connectivity Components

1. AWS Direct Connect

Purpose: High-performance, dedicated connection between on-premises data center and AWS for system replication and failover traffic.

Key Features:
- Dedicated 1Gbps or 10Gbps connection
- Consistent, predictable network performance
- Lower latency compared to VPN (30-50% reduction)
- SLA-backed availability (99.99%)
- Private connectivity (traffic doesn't traverse the public internet)

Configuration:
- Direct Connect location: Selected based on proximity to on-premises data center
- Private Virtual Interface (VIF) to connect to the DR VPC
- BGP for dynamic routing between on-premises and AWS
- Redundant connections for critical environments

Benefits for Replication:
- Consistent replication performance leads to better RPO
- Higher bandwidth allows for more frequent replication points
- Reliable connection reduces risks of replication failures
- Isolated from internet congestion and public network issues

2. AWS Client VPN

Purpose: Secure remote access for users to connect to DR systems during a disaster recovery event.

Key Features:
- Certificate-based authentication
- Integration with existing identity providers
- Split tunneling to optimize network traffic
- Scalable to support entire workforce
- End-to-end encryption

Configuration:
- Client CIDR block: Dedicated IP range for VPN clients
- Authentication: Certificate-based with optional multi-factor authentication
- Authorization: Fine-grained control over resource access
- Connection logging: For security monitoring and compliance

Benefits for Remote Users:
- Direct, secure access to recovered systems
- Consistent experience regardless of user location
- Scalable to support entire organization during DR event
- Does not require routing through on-premises infrastructure

Why This Hybrid Approach?

1. Optimized for Different Traffic Types

- System Replication Traffic:
  - High volume, continuous data transfer
  - Requires consistent performance
  - Critical for maintaining low RPO
  - Benefits from dedicated bandwidth

- User Access Traffic:
  - Intermittent, variable demand
  - Geographically dispersed
  - Interactive sessions requiring responsiveness
  - Needs flexibility for any user location

2. Cost Efficiency

- Direct Connect:
  - Higher base cost justified by performance benefits for critical replication
  - Lower data transfer costs compared to internet-based transfer
  - Predictable monthly expenses

- Client VPN:
  - Pay-per-connection model aligns with actual usage
  - No need for expensive hardware VPN infrastructure
  - Scales up only during actual DR events

3. Security Benefits

- Segmentation of Traffic Types:
  - System replication isolated on private connection
  - User traffic secured through encrypted VPN tunnels
  - Different security policies can be applied to each pathway

- Reduced Attack Surface:
  - Replication traffic never traverses the public internet
  - VPN provides encrypted access for users without exposing DR systems

4. Operational Flexibility

- Independent Scaling:
  - Direct Connect capacity for replication is consistent and predictable
  - VPN can scale based on number of active users during DR event

- Simplified Management:
  - Each connection type can be managed based on its specific requirements
  - Clearer troubleshooting paths for different types of connectivity issues

Implementation

The hybrid connectivity approach is implemented through:

1. Direct Connect Module:
   - Provisions and configures AWS Direct Connect
   - Sets up Virtual Interfaces and routing
   - Integrates with the banking DR VPC

2. VPN Configuration in Networking Module:
   - Client VPN endpoint creation
   - Authentication and authorization rules
   - Integration with existing identity systems

3. Monitoring and Alerting:
   - CloudWatch metrics for both connection types
   - Alerts for connection status and performance
   - Dashboards for overall connectivity health

Cost Considerations

Direct Connect Costs

- Connection fee: $1,000-$3,000+ per month (depending on bandwidth)
- Data transfer out: $0.02 per GB (vs. $0.09 per GB for internet data transfer)
- Virtual interface: No additional cost

Client VPN Costs

- Endpoint association: $0.10 per hour
- Client connections: $0.05 per client connection per hour
- Data transfer: Standard EC2 data transfer rates

Cost Optimization Strategies

- Right-size Direct Connect based on replication volume
- Use Client VPN only during DR events or tests
- Consider using Direct Connect Hosted Connection for lower costs in some scenarios

Conclusion

The hybrid connectivity approach combines the best of both worlds:
- High-performance, reliable Direct Connect for critical system replication
- Flexible, secure Client VPN for user access during DR events

This approach ensures optimal performance for replication while providing a seamless experience for users during a disaster recovery scenario, all while maintaining cost efficiency by using each connection type for its most appropriate purpose.