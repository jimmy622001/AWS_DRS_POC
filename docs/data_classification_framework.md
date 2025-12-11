# Data Classification and Protection Framework for Banking DR

## Overview

This document outlines the data classification and protection framework for our banking disaster recovery solution. It establishes guidelines for identifying, classifying, and protecting data based on its sensitivity and regulatory requirements.

## Data Classification Levels

### Level 1: Public
**Definition**: Information explicitly approved for public distribution with no restrictions.

**Examples**:
- Marketing materials
- Public financial reports
- Press releases
- Public interest rates

**Required Controls**:
- No special controls required
- Standard backup and recovery

### Level 2: Internal
**Definition**: Non-sensitive information intended for use within the organization but not for public distribution.

**Examples**:
- Internal procedures and policies
- Non-sensitive internal communications
- Training materials
- Internal announcements

**Required Controls**:
- Basic access controls
- Standard encryption in transit
- Standard backup and DR replication
- Retention according to general policy

### Level 3: Confidential
**Definition**: Sensitive business information that could cause harm to the organization if disclosed.

**Examples**:
- Strategic plans
- Proprietary algorithms
- Detailed financial information
- Aggregated customer data (non-PII)
- Vendor contracts

**Required Controls**:
- Strong access controls (role-based)
- Encryption in transit and at rest
- Enhanced monitoring and logging
- Restricted DR site access
- Data loss prevention scanning

### Level 4: Restricted
**Definition**: Highly sensitive information subject to regulatory requirements or that could cause significant harm if disclosed.

**Examples**:
- Personally Identifiable Information (PII)
- Customer financial data
- Authentication credentials
- Payment card information
- Regulatory examination results

**Required Controls**:
- Strict least-privilege access
- Strong encryption in transit and at rest
- Comprehensive audit logging
- Enhanced DLP monitoring
- Special handling procedures during DR
- Geographic restrictions on data residency
- Additional authentication for access

## Data Tagging Requirements

All data and resources in the AWS DRS environment must be tagged with the following:

### Required Tags

| Tag Key | Description | Possible Values | Enforcement |
|---------|-------------|----------------|------------|
| Classification | Data sensitivity level | Public, Internal, Confidential, Restricted | AWS Config rule |
| ComplianceReq | Primary compliance requirement | PCI, GDPR, GLBA, SOX, None | AWS Config rule |
| DataOwner | Business unit responsible | Finance, Lending, Retail, Operations, IT, etc. | Tagging policy |
| DataSteward | Individual responsible | Email alias | Tagging policy |
| RetentionPeriod | Required retention | 1Y, 3Y, 5Y, 7Y, 10Y, Indefinite | S3 lifecycle policy |

### Automation of Tagging

1. **Inherited Tags**: Resources created from or associated with classified resources inherit the same classification
2. **Default Classification**: All data is classified as "Confidential" by default if not explicitly classified
3. **AWS Config Rules**: Enforce tagging compliance across DR environment

## Data Protection Controls by Classification

### Encryption Requirements

| Classification | In Transit | At Rest | Key Management |
|---------------|------------|---------|---------------|
| Public | Optional | Optional | N/A |
| Internal | Required (TLS 1.2+) | Optional | AWS Managed Keys |
| Confidential | Required (TLS 1.2+) | Required | Customer Managed Keys |
| Restricted | Required (TLS 1.3+) | Required | Customer Managed Keys with rotation |

### Access Controls

| Classification | Authentication | Authorization | Monitoring |
|---------------|----------------|--------------|-----------|
| Public | Standard | Standard | Standard |
| Internal | Standard | Role-based | Standard |
| Confidential | MFA Required | Strict Role-based | Enhanced |
| Restricted | MFA + Context | Just-in-time, least privilege | Comprehensive |

## Data Protection in DR Scenarios

### Data-at-Rest Protection

1. **Encryption Requirements**:
   - All EBS volumes containing sensitive data must be encrypted with customer-managed KMS keys
   - S3 buckets must have encryption enabled
   - Database instances must use encrypted storage

2. **Key Management**:
   - KMS keys must be available in the AWS target region
   - Key usage must be restricted by IAM policies
   - Key rotation must be enabled for all keys used for Restricted data

### Data-in-Transit Protection

1. **Encryption Requirements**:
   - All API calls must use HTTPS
   - All replication traffic must be encrypted
   - VPN or Direct Connect must be used for on-premises connectivity

2. **Network Controls**:
   - Traffic flow monitoring with VPC Flow Logs
   - Security Groups limiting traffic to necessary ports
   - Network Access Control Lists as additional security layer

### Data Access Controls

1. **Authentication**:
   - MFA required for console access to DR environment
   - Service-specific credentials with automatic rotation
   - Temporary credentials for emergency access

2. **Authorization**:
   - Least-privilege IAM policies
   - Resource-based policies for S3 and other services
   - SCPs to enforce organizational controls

## Data Loss Prevention Controls

### Automated Detection

1. **Amazon Macie** for sensitive data detection:
   - Automatic scanning of S3 buckets in the DR environment
   - Custom data identifiers for banking-specific information
   - Integration with AWS Security Hub

2. **Custom Detection** for application-specific data:
   - CloudWatch Logs pattern matching
   - Application-level scanning
   - API Gateway request/response filtering

### Prevention Controls

1. **Automated remediation** workflows:
   - Quarantine of potentially exposed data
   - Automated encryption of unencrypted resources
   - Automated blocking of public access

2. **DLP Guardrails**:
   - Prevention of unencrypted data storage
   - Blocking of unapproved cross-region data transfers
   - Prevention of data exfiltration

## Data Residency and Sovereignty

### Regional Controls

1. **Data Residency Requirements**:
   - Customer data must remain in approved regions
   - Restricted data may have country-specific requirements
   - DR configuration must respect regional restrictions

2. **Technical Controls**:
   - Regional IAM permissions
   - Service control policies restricting region usage
   - KMS key policies restricting cross-region operations

### Compliance Documentation

1. **Data Location Tracking**:
   - Inventory of data locations maintained
   - Documentation of data flows between regions
   - Regular auditing of data location compliance

## Implementation in AWS DRS

### Resource Tagging

All resources in the DR environment must be tagged according to the classification framework:

```terraform
resource "aws_instance" "banking_app" {
  # ... other configuration ...
  
  tags = {
    Name           = "banking-app-server"
    Classification = "Confidential"
    ComplianceReq  = "GLBA"
    DataOwner      = "Retail"
    DataSteward    = "retail-data@example.com"
    RetentionPeriod = "7Y"
  }
}
```

### Automated Classification

1. **AWS Macie** for data discovery and classification:

```terraform
resource "aws_macie2_classification_job" "sensitive_data_discovery" {
  job_type = "ONE_TIME"
  name     = "banking-sensitive-data-discovery"
  
  s3_job_definition {
    bucket_definitions {
      account_id = var.account_id
      buckets    = [aws_s3_bucket.dr_data.name]
    }
  }
}
```

2. **Config Rules** for enforcing classification tags:

```terraform
resource "aws_config_config_rule" "required_classification_tags" {
  name        = "required-classification-tags"
  description = "Checks that resources have required classification tags"
  
  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  
  input_parameters = jsonencode({
    tag1Key = "Classification"
  })
}
```

## Validation and Compliance

### Regular Review Process

1. **Quarterly Classification Review**:
   - Verify classification of all data in DR environment
   - Update tags as business needs change
   - Validate compliance with framework

2. **Automated Scanning**:
   - Weekly sensitive data scans
   - Daily compliance checks
   - Real-time monitoring of classification changes

### Compliance Reporting

1. **Regular Reports**:
   - Data classification inventory
   - Compliance status by classification level
   - Remediation actions for non-compliant resources

## Training and Awareness

1. **Data Classification Training**:
   - Required for all staff with DR responsibilities
   - Annual refresher training
   - Role-specific training for data stewards

2. **Classification Decision Tree**:
   - Flowchart to help determine appropriate classification
   - Documentation with examples
   - Regular updates based on regulatory changes