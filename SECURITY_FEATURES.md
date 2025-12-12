# Cost-Efficient, On-Demand Security for AWS DR Environment

This document describes our implementation of cost-efficient, on-demand security for the AWS DR Environment.

## Overview

We've successfully implemented a solution that provides advanced security capabilities that activate ONLY during an actual DR failover, avoiding unnecessary ongoing costs. This approach ensures comprehensive security during failover when you need it, without the ongoing costs during normal operation.

## Architecture Components

### 1. On-Demand Security Module

This module manages advanced security features that are:
- Pre-provisioned but dormant: Resources are defined in Terraform but not actively consuming billable resources
- Automatically activated during DR: Part of the DR recovery workflow
- Automatically deactivated after DR ends: To prevent ongoing costs

The module includes:
- **AWS WAF WebACL**: Configured but not associated with any resources until activated
- **GuardDuty Detector**: Created in a disabled state, activated only during failover
- **Shield Advanced Protection**: Pre-configured but not active until needed

### 2. Lambda Functions for Security Management

Two Lambda functions manage the activation/deactivation of security services:
- **EnableSecurityLambda**: Activates WAF, GuardDuty, and Shield during DR failover
- **DisableSecurityLambda**: Deactivates these services when returning to normal operations

### 3. Integration with Recovery Orchestration

The recovery workflow includes:
- **Pre-Recovery Security Activation**: As one of the first steps in recovery
- **Post-Recovery Security Validation**: Ensures security services are running
- **Cleanup Security Step**: Deactivates security services if DR environment is decommissioned

### 4. Cost Benefits

This approach provides:
- Zero ongoing costs for WAF inspection until activated during failover
- No GuardDuty costs during normal operations
- No Shield Advanced costs during normal operations
- Full security coverage when the DR environment becomes active

## Security Features Details

### AWS WAF with Banking-Specific Rules:
- SQL Injection protection
- Cross-site scripting protection
- Banking-specific rules like large money transfer inspection

### GuardDuty with Financial Threat Detection:
- Threat detection for banking workloads
- Unusual access pattern detection
- Cryptocurrency threat detection

### Shield Advanced Protection:
- DDoS protection for critical banking interfaces
- Automatic application layer DDoS mitigation

## How It Works in Practice

### Normal Operations:
- Security resources are defined in Terraform but remain inactive
- No costs are incurred for WAF, GuardDuty, or Shield

### During DR Failover:
1. Step Functions workflow executes the `EnableSecurityLambda`
2. Lambda activates WAF, GuardDuty, and associates Shield protections
3. Full security posture is established before applications become available

### During DR Operations:
- All security services are active and protecting the environment
- Normal security costs apply during this period (but only during failover)

### When Returning to Production:
1. `DisableSecurityLambda` deactivates the security services
2. Costs for these services stop accruing

## Implementation Details

The implementation consists of:

1. A dedicated Terraform module (`on_demand_security`) that defines the security resources
2. Lambda functions for enabling and disabling security services
3. Integration with the existing recovery orchestration Step Function
4. Updates to IAM policies for proper permissions

## Usage

The on-demand security module is integrated directly into the main Terraform configuration and requires no additional steps to deploy. The security services will automatically activate during a DR failover event.

## Conclusion

This on-demand security approach provides the best of both worlds - comprehensive security during failover when you need it, without the ongoing costs during normal operation. It ensures that your DR environment is fully protected only when it becomes active, following security best practices while optimizing costs.