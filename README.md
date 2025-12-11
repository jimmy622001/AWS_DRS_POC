# AWS Disaster Recovery Solution (DRS) POC

This project provides two distinct disaster recovery (DR) options for banking environments, designed to meet different requirements and budget considerations. The solution uses **Ireland (eu-west-1)** as the primary region and **London (eu-west-2)** as the failover region.

DR Solution Options

| Feature | Option 1: AWS DRS with VPN | Option 2: AWS DRS with Direct Connect + VPN (Hybrid) |
|---------|----------------------------|-----------------------------------------------------|
| Connectivity | Site-to-Site VPN | Direct Connect + Client VPN |
| Performance | Good | Excellent |
| Reliability | Standard | High (99.99% SLA) |
| Cost | Lower | Higher |
| Complexity | Simple | Moderate |
| Documentation | [DRS-proposal.md](DRS-proposal.md) | [hybrid-proposal.md](hybrid-proposal.md) |

Option 1: AWS DRS with VPN

![AWS DRS with VPN Architecture](https://d1.awsstatic.com/product-marketing/CloudEndure/CloudEndureDRDiagram.78c10efbc9be0e086d6c496e54efb0b70513b1af.png)

A simple, cost-effective solution using AWS Elastic Disaster Recovery Service (DRS) with VPN connectivity for replication and access:

- Site-to-Site VPN for connectivity between on-premises and AWS
- Client VPN for remote user access during DR events
- Block-level replication with sub-second RPO
- Minutes RTO for critical systems
- Non-disruptive testing capabilities

Best for: Organizations prioritizing cost-effectiveness with moderate recovery time requirements.

Option 2: AWS DRS with Direct Connect + VPN (Hybrid)

![AWS DRS Hybrid Architecture](docs/hybrid-architecture.png)

An enhanced DR solution combining the benefits of Direct Connect and VPN:

- AWS Direct Connect for dedicated, high-performance replication
- Client VPN for flexible user access during DR events
- SLA-backed connectivity (99.99% availability)
- Enhanced security with private network connectivity
- Better regulatory compliance for financial institutions

Best for: Organizations requiring the highest reliability, performance, and regulatory compliance.

Cost Comparison

Review our [cost comparison document](docs/cost-comparison.md) to understand the financial implications of each option.

Project Structure

```
AWS_DRS_POC/
├── README.md                 # This overview document
├── DRS-proposal.md           # Option 1: VPN-only solution details
├── HYBRID-PROPOSAL.md        # Option 2: Hybrid with Direct Connect details
├── INFRASTRUCTURE.md         # Infrastructure setup instructions
├── docs/                     # Additional documentation
│   ├── cost-comparison.md    # Cost comparison between options
│   ├── terraform-implementation.md # Technical implementation details
│   ├── regions.md            # Details about primary and failover regions
│   ├── architecture.md       # Architecture documentation
│   ├── hybrid_connectivity.md # Hybrid connectivity details
│   └── replication_strategy.md # Replication strategy documentation
└── modules/                  # Terraform modules
    ├── drs/                  # AWS Elastic DR Service module
    ├── networking/           # VPC, subnets, VPN configuration
    ├── compute/              # Compute resources configuration
    ├── database/             # Database resources configuration 
    ├── storage/              # Storage resources configuration
    ├── monitoring/           # Monitoring setup
    ├── direct_connect/       # Direct Connect configuration
    ├── security/             # Security configuration
    ├── logging/              # Logging configuration
    └── security_compliance/  # Security compliance
```

Getting Started

1. Review both DR options in their respective documentation
2. Compare the cost implications using the [cost comparison document](docs/cost-comparison.md)
3. Select the most appropriate option based on your requirements
4. Review the [technical implementation details](docs/terraform-implementation.md) for Terraform code
5. Understand the [region configuration](docs/regions.md) for primary (Ireland) and failover (London) regions
6. Follow the implementation instructions in the [infrastructure setup document](INFRASTRUCTURE.md)

This project is configured to use:
- **Primary region**: Ireland (eu-west-1)
- **Failover region**: London (eu-west-2)

These regions were selected for their proximity, compliance with European data regulations, and complete service availability.

## Recent Updates

### Module Removals
Several modules have been removed to streamline the architecture and focus on core DR functionality:

- **Analytics Module**: Removed as analytics workloads are not relevant in a DR environment
- **CICD Module**: Removed as CI/CD pipelines are not typically needed in DR scenarios
- **Infracost Module**: Removed as it's a development utility rather than core infrastructure

See [MODULE_REMOVALS.md](MODULE_REMOVALS.md) for detailed information about these changes and their benefits.