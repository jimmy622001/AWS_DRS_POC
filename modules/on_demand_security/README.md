# On-Demand Security Module

This module provides cost-efficient, on-demand security for AWS DR environments. It implements advanced security capabilities that activate ONLY during an actual DR failover, avoiding unnecessary ongoing costs during normal operations.

## Features

### Pre-provisioned but dormant security resources
- AWS WAF WebACL: Configured but not associated with any resources until activated
- GuardDuty Detector: Created in a disabled state, activated only during failover
- Shield Advanced Protection: Pre-configured but not active until needed

### Lambda Functions for Security Management
- `EnableSecurityLambda`: Activates WAF, GuardDuty, and Shield during DR failover
- `DisableSecurityLambda`: Deactivates these services when returning to normal operations

### Security Features Included
- **AWS WAF with Banking-Specific Rules**:
  - SQL Injection protection
  - Cross-site scripting protection
  - Banking-specific rules like large money transfer inspection
- **GuardDuty with Financial Threat Detection**:
  - Threat detection for banking workloads
  - Unusual access pattern detection
  - Cryptocurrency threat detection
- **Shield Advanced Protection**:
  - DDoS protection for critical banking interfaces
  - Automatic application layer DDoS mitigation

## Usage

```hcl
module "on_demand_security" {
  source = "./modules/on_demand_security"

  environment        = var.environment
  load_balancer_arn  = module.compute.load_balancer_arn
  waf_web_acl_name   = "dr-banking-web-acl"
  
  # Shield Advanced Configuration
  create_shield_protection = true
  shield_resource_arn      = module.compute.load_balancer_arn
  
  tags = var.tags
}
```

## Integration with Recovery Orchestration

To integrate with your Step Functions workflow for DR recovery:

1. **Pre-Recovery Security Activation**:
   - Add a Lambda task state in your Step Functions workflow that invokes the `enable_security_lambda`
   
2. **Post-Recovery Security Validation**:
   - Add a validation step to verify security services are properly configured
   
3. **Cleanup Security Step**:
   - Add a Lambda task state that invokes the `disable_security_lambda` when returning to normal operations

## Cost Benefits

This approach provides:
- Zero ongoing costs for WAF inspection until activated during failover
- No GuardDuty costs during normal operations
- No Shield Advanced costs during normal operations
- Full security coverage when the DR environment becomes active

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| waf_web_acl_name | Name for the WAF WebACL | `string` | `"dr-banking-web-acl"` | no |
| load_balancer_arn | ARN of the load balancer to associate with the WAF WebACL during failover | `string` | n/a | yes |
| create_shield_protection | Whether to create Shield Advanced protection | `bool` | `true` | no |
| shield_resource_arn | ARN of the resource to protect with Shield Advanced | `string` | `""` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| web_acl_id | ID of the WAF WebACL |
| web_acl_arn | ARN of the WAF WebACL |
| guardduty_detector_id | ID of the GuardDuty detector |
| enable_security_lambda_arn | ARN of the Lambda function for enabling security services |
| disable_security_lambda_arn | ARN of the Lambda function for disabling security services |