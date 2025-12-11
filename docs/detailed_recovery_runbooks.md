# Detailed Recovery Runbooks for Banking Applications

## Overview

This document provides detailed, step-by-step procedures for recovering specific banking applications and systems using AWS DRS. These runbooks are designed to be followed during both DR testing and actual disaster recovery events.

## Table of Contents

1. [Core Banking System Recovery](#core-banking-system-recovery)
2. [Payment Processing System Recovery](#payment-processing-system-recovery)
3. [Customer Portal Recovery](#customer-portal-recovery)
4. [Database Recovery and Validation](#database-recovery-and-validation)
5. [Infrastructure Services Recovery](#infrastructure-services-recovery)
6. [Post-Recovery Validation](#post-recovery-validation)

## Core Banking System Recovery

### Prerequisites
- Verified DRS replication status (RPO < 15 minutes)
- Network connectivity between components established
- Authentication services available
- DR declaration approved by authorized personnel

### Recovery Steps

#### Automated Recovery (Preferred Method)
1. **Initiate Automated Recovery**
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <DR_ORCHESTRATION_STEP_FUNCTION_ARN> \
     --input '{"applicationGroup": "core-banking", "sourceServerIDs": ["<SERVER_ID_1>", "<SERVER_ID_2>", "<SERVER_ID_3>"]}'
   ```

2. **Monitor Recovery Progress**
   ```bash
   aws stepfunctions describe-execution \
     --execution-arn <EXECUTION_ARN>
   ```

3. **Verify Automated Post-Recovery Checks**
   - Review CloudWatch Logs for post-recovery validation Lambda function
   - Confirm all health checks passed
   - Verify application endpoints are responding

#### Manual Recovery (Fallback Method)

1. **Initiate Recovery for Core Banking DB Server**
   ```bash
   aws drs start-recovery \
     --source-server-id <CORE_BANKING_DB_SERVER_ID>
   ```

2. **Monitor Recovery Job**
   ```bash
   aws drs describe-jobs \
     --filters jobIDs=<JOB_ID>
   ```

3. **Initiate Recovery for Core Banking App Servers**
   ```bash
   aws drs start-recovery \
     --source-server-id <CORE_BANKING_APP_SERVER_ID_1>
   ```

4. **Verify Database Consistency**
   - Connect to database server
   - Run integrity checks
   ```sql
   -- Example: Check database consistency
   DBCC CHECKDB (CoreBankingDB) WITH NO_INFOMSGS;
   
   -- Example: Verify transaction log
   DBCC LOGINFO;
   ```

5. **Verify Application Server Function**
   - Connect to application server
   - Check services are running
   ```bash
   systemctl status core-banking-service
   ```
   
6. **Verify Connectivity Between Servers**
   ```bash
   # Test database connectivity from application server
   nc -zv <DB_SERVER_PRIVATE_IP> 1433
   ```

7. **Initialize Application Services**
   ```bash
   sudo systemctl start core-banking-service
   ```

8. **Perform Application-Specific Health Checks**
   - Run the core banking diagnostic script
   ```bash
   /opt/banking/scripts/diagnostic.sh
   ```

## Payment Processing System Recovery

### Prerequisites
- Core Banking System successfully recovered
- Network security groups configured properly
- Encryption keys accessible

### Recovery Steps

1. **Initiate Automated Recovery**
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <DR_ORCHESTRATION_STEP_FUNCTION_ARN> \
     --input '{"applicationGroup": "payments", "sourceServerIDs": ["<PAYMENT_SERVER_ID_1>", "<PAYMENT_SERVER_ID_2>"]}'
   ```

2. **Verify Payment Gateway Connectivity**
   ```bash
   # Test connection to payment gateway
   curl -k -v https://<PAYMENT_GATEWAY_ENDPOINT>/health
   ```

3. **Test Payment Processing Functions**
   - Execute payment verification script
   ```bash
   /opt/banking/scripts/verify-payment-system.sh
   ```

4. **Verify PCI Compliance of Recovered Environment**
   - Confirm encryption of card data at rest
   - Verify network segmentation
   - Run compliance scan
   ```bash
   /opt/banking/scripts/pci-compliance-check.sh
   ```

## Customer Portal Recovery

### Prerequisites
- Core banking system operational
- Authentication services available
- Content delivery network configured

### Recovery Steps

1. **Recover Web Server Instances**
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <DR_ORCHESTRATION_STEP_FUNCTION_ARN> \
     --input '{"applicationGroup": "customer-portal", "sourceServerIDs": ["<WEB_SERVER_ID_1>", "<WEB_SERVER_ID_2>"]}'
   ```

2. **Verify Web Server Configuration**
   ```bash
   # Check web server status
   systemctl status nginx
   
   # Check SSL certificate validity
   openssl x509 -noout -dates -in /etc/ssl/certs/portal.pem
   ```

3. **Test Authentication Services**
   ```bash
   curl -k -v https://localhost/auth/health
   ```

4. **Verify Content Integrity**
   ```bash
   # Run content validation script
   /opt/banking/scripts/validate-web-content.sh
   ```

5. **Update DNS Records (if required)**
   ```bash
   aws route53 change-resource-record-sets \
     --hosted-zone-id <HOSTED_ZONE_ID> \
     --change-batch file://dns-changes.json
   ```

## Database Recovery and Validation

### Prerequisites
- Storage volumes recovered and attached
- Network connectivity established
- Required IAM permissions available

### Recovery Steps

1. **Verify Database Instance Recovery**
   ```bash
   # Check instance status
   aws ec2 describe-instance-status \
     --instance-ids <DB_INSTANCE_ID>
   ```

2. **Check Database Service Status**
   ```bash
   # For SQL Server
   sudo systemctl status mssql-server
   
   # For Oracle
   sudo systemctl status oracle-xe
   ```

3. **Verify Database Consistency**
   ```sql
   -- For SQL Server
   DBCC CHECKDB (BankingDB) WITH NO_INFOMSGS;
   
   -- For Oracle
   SELECT * FROM V$DATABASE_BLOCK_CORRUPTION;
   ```

4. **Validate Data Replication Status**
   - Check last transaction timestamp
   - Verify no data loss
   ```sql
   -- Example SQL Server query to check last transaction time
   SELECT MAX(transaction_date) FROM transactions;
   ```

5. **Verify Database Connectivity from Application Servers**
   ```bash
   # From application server
   nc -zv <DB_SERVER_IP> <DB_PORT>
   ```

6. **Perform Database-Specific Recovery Procedures**
   ```bash
   # Run database recovery script
   /opt/banking/scripts/database-recovery.sh
   ```

## Infrastructure Services Recovery

### Prerequisites
- Network connectivity established
- IAM roles and permissions configured
- DNS resolution functional

### Recovery Steps

1. **Recover Active Directory Services**
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <DR_ORCHESTRATION_STEP_FUNCTION_ARN> \
     --input '{"applicationGroup": "infra", "sourceServerIDs": ["<AD_SERVER_ID>"]}'
   ```

2. **Verify Domain Controller Status**
   ```powershell
   # PowerShell command to check DC status
   dcdiag /test:replications
   ```

3. **Recover File Services**
   ```bash
   aws stepfunctions start-execution \
     --state-machine-arn <DR_ORCHESTRATION_STEP_FUNCTION_ARN> \
     --input '{"applicationGroup": "infra", "sourceServerIDs": ["<FILE_SERVER_ID>"]}'
   ```

4. **Verify File Share Accessibility**
   ```powershell
   # PowerShell command to check shares
   Get-SmbShare
   ```

5. **Test Authentication Against Recovered AD**
   ```bash
   # Linux command to test AD authentication
   realm list
   kinit testuser@EXAMPLE.COM
   ```

## Post-Recovery Validation

### Complete System Health Check

1. **Verify All Applications are Running**
   ```bash
   # Run health check across all servers
   ansible-playbook -i dr-inventory.ini health-check.yml
   ```

2. **Validate Inter-Application Communication**
   - Verify service mesh connectivity
   - Test API endpoints

3. **Security Validation**
   ```bash
   # Run security validation script
   /opt/banking/scripts/security-validation.sh
   ```

4. **Performance Validation**
   ```bash
   # Run performance tests
   /opt/banking/scripts/performance-benchmark.sh
   ```

5. **Compliance Checks**
   ```bash
   # Run compliance validation
   /opt/banking/scripts/compliance-check.sh --standards PCI,GDPR,GLBA
   ```

### Application-Specific Tests

Each application should have specific functionality tests executed to verify:

1. User authentication and authorization
2. Transaction processing
3. Data integrity and consistency
4. Integration with external systems
5. Reporting functionality

## DR Drill Completion Checklist

- [ ] All servers successfully recovered
- [ ] All applications operational
- [ ] Database consistency verified
- [ ] No security vulnerabilities introduced
- [ ] Compliance requirements maintained
- [ ] Performance within acceptable parameters
- [ ] External connectivity established
- [ ] DNS resolution functioning correctly
- [ ] Success criteria met

## Contact Information

| Role | Name | Contact | Escalation |
|------|------|---------|------------|
| DR Coordinator | Jane Smith | +1-555-0123, jane.smith@example.com | Primary |
| IT Operations | John Doe | +1-555-0124, john.doe@example.com | Level 1 |
| Database Team | Sarah Johnson | +1-555-0125, sarah.johnson@example.com | Level 2 |
| Security Team | Michael Brown | +1-555-0126, michael.brown@example.com | Level 2 |
| Executive Sponsor | David Wilson | +1-555-0127, david.wilson@example.com | Final |