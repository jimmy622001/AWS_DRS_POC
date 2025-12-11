# Modern Disaster Recovery: AWS DRS vs. Traditional Off-Site Solutions

## Slide 1: Title Slide

- **Title:** Modern Disaster Recovery: AWS DRS vs. Traditional Off-Site Solutions
- **Subtitle:** Leveraging Terraform for Seamless Implementation
- **Presented by:** [Your Name/Company]
- **Date:** [Presentation Date]

## Slide 2: Agenda

- Introduction to Disaster Recovery
- Overview of AWS DRS
- Traditional On-Premise Off-Site DR Solutions
- Comparative Analysis
- Terraform Project Overview
- Next Steps & Q&A

## Slide 3: The Importance of Disaster Recovery

- Business continuity and risk mitigation
- Common threats: hardware failure, cyberattacks, natural disasters
- Recovery objectives: RTO (Recovery Time Objective), RPO (Recovery Point Objective)

## Slide 4: What is AWS DRS?

- AWS Elastic Disaster Recovery Service: cloud-native DR solution
- Continuous replication, automated failover/failback
- Block-level replication with sub-second RPO
- Supports physical, virtual, and cloud workloads
- Minutes RTO for critical systems

## Slide 5: Traditional On-Premise Off-Site DR

- Requires duplicate infrastructure at a remote location
- Manual replication and recovery processes
- High upfront and ongoing costs
- Limited scalability and flexibility
- Complex maintenance and testing

## Slide 6: Comparative Analysis – AWS DRS vs. Traditional DR


| Feature        | AWS DRS                          | Traditional Off-Site DR       |
| -------------- | -------------------------------- | ----------------------------- |
| Cost           | Pay-as-you-go, no hardware       | High upfront, ongoing costs   |
| Scalability    | Easily scales with needs         | Limited by physical resources |
| Automation     | Automated replication & failover | Manual processes              |
| Recovery Speed | Near real-time, fast failover    | Slower, manual intervention   |
| Security       | Encrypted, AWS compliance        | Varies, often less robust     |
| Management     | Centralized AWS Console          | Multiple tools, manual checks |

## Slide 7: Key Benefits of AWS DRS

- Rapid recovery to AWS in minutes
- No need for duplicate infrastructure
- Simplified management and monitoring
- Integration with AWS ecosystem (EC2, VPC, IAM, etc.)
- Cost-effective and secure
- Non-disruptive testing capabilities

## Slide 8: Terraform Project Overview

- Infrastructure as Code approach
- AWS DRS implemented via Terraform modules
- Two implementation options:
  - Option 1: AWS DRS with VPN (cost-effective)
  - Option 2: AWS DRS with Direct Connect + VPN (hybrid, enhanced performance)
- Automated resource provisioning and configuration

## Slide 9: Implementation Workflow

- Assess current environment
- Choose connectivity option (VPN or Hybrid with Direct Connect)
- Deploy AWS DRS via Terraform
- Configure replication settings
- Test failover and failback
- Ongoing monitoring and optimization

## Slide 10: Cost Comparison


| Environment Size    | AWS DRS (VPN) | AWS DRS (Hybrid) | Traditional DR |
| ------------------- | ------------- | ---------------- | -------------- |
| Small (10 servers)  | £527/month   | £590/month      | £1,200+/month |
| Medium (25 servers) | £1,722/month | £1,503/month    | £3,200+/month |
| Large (50 servers)  | £3,661/month | £2,879/month    | £6,400+/month |


## Slide 11: Detailed Cost Components (in British Pounds)


| Cost Component       | AWS DRS (VPN)      | AWS DRS (Hybrid)    | Traditional DR |
| -------------------- | ------------------ | ------------------- | -------------- |
| Monthly Connectivity | £29 - £117       | £175               | £400+         |
| DRS Service          | £0.022 per GB     | £0.022 per GB      | N/A            |
| Storage Costs        | £0.08 per GB      | £0.08 per GB       | £0.15+ per GB |
| Staging Environment  | Pay as you use     | Pay as you use      | Always on      |
| Data Transfer        | £0.07 per GB      | £0.016 per GB      | Varies         |
| Implementation       | £8,000 - £16,000 | £12,000 - £20,000 | £20,000+      |

*Converted to British Pounds from original USD pricing*

## Slide 12: Project Architecture

```
                                         +-----------------+
                                         |                 |
                                +------->| CloudWatch      |
                                |        | Monitoring      |
                                |        +-----------------+
                                |                                            
+------------------+            |        +-----------------+        +------------------+
|                  |            |        |                 |        |                  |
|  On-Premise      |            +------->| AWS Site-to-Site|<------>| AWS VPC          |
|  Data Center     |    Replication      | VPN Connection  |        | (DR Environment) |
|                  |<------------------------>             |        |                  |
+--------+---------+                     +-----------------+        +--------+---------+
         |                                                                   |
         v                                                                   v
+------------------+                                              +------------------+
|                  |                                              |                  |
| VM Servers       |-----------> AWS Elastic Disaster --------->| EC2 Instances    |
| (Applications)   |            Recovery (DRS)                    | (DR Replicas)    |
|                  |                                              |                  |
+------------------+                                              +------------------+
```

## Slide 13: Terraform Implementation

```hcl
module "drs" {
  source = "./modules/drs"
  
  enabled                = true
  vpc_id                 = module.networking.vpc_id
  subnet_ids             = module.networking.private_subnet_ids
  security_group_ids     = [module.networking.security_group_id]
  dr_activated           = false
  app_server_count       = 5
  db_server_count        = 2
  file_server_count      = 1
  app_server_instance_type = "t3.medium"
  db_server_instance_type  = "m5.large"
  file_server_instance_type = "t3.large"
  total_server_count     = 8
  avg_server_size_gb     = 500
}
```

## Slide 14: 3-Year TCO Comparison (British Pounds)


| Environment    | AWS DRS (VPN) | AWS DRS (Hybrid) | Traditional DR |
| -------------- | ------------- | ---------------- | -------------- |
| Small Banking  | £32,696      | £38,656         | £56,000+      |
| Medium Banking | £79,709      | £75,546         | £120,000+     |
| Large Banking  | £153,491     | £129,082        | £240,000+     |

*3-year total cost of ownership including implementation and testing costs*

## Slide 15: Next Steps

- Proposal for pilot or proof-of-concept
- Assess your current environment requirements
- Select appropriate connectivity option
- Schedule implementation planning
- Define testing and validation strategy
- Open floor for questions

## Slide 16: Q&A

- Any questions about AWS DRS?
- Terraform implementation details?
- Cost considerations?
- Migration strategies?
- Thank you for your time!
